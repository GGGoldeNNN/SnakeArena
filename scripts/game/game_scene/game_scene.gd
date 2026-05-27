## 游戏主场景
## 管理玩家生成、Boss 生成、初始化子弹管理器
extends Node2D

var _health_bar: ProgressBar
var _health_label: Label

## 世界边界（由 _spawn_player 计算，用于敌人生成范围）
var world_boundary: Rect2

## 敌人生成
var _enemy_pool: ObjectPool
var _spawn_timer: float = 0.0
@export var enemy_spawn_interval: float = 2.5
@export var max_active_enemies: int = 30
## 小怪出生点距玩家的最小距离
@export var enemy_min_spawn_dist: float = 400.0


func _ready() -> void:
	GameManager.reset()
	_init_health_ui()
	SignalManager.player_damaged.connect(_on_player_damaged)
	_init_bullet_manager()
	_spawn_player()
	_init_enemy_pool()
	#_spawn_boss(200)
	_play_bgm()
	Debug.Log_Success("GameScene: 游戏场景初始化完成")


func _init_health_ui() -> void:
	_health_bar = $GameUI/PlayerStatus/HealthBar as ProgressBar
	_health_label = $GameUI/PlayerStatus/HealthBar/HealthNum as Label


func _on_player_damaged(hp: float, max_hp: float) -> void:
	if _health_bar:
		_health_bar.max_value = max_hp
		_health_bar.value = hp
	if _health_label:
		_health_label.text = "%d/%d" % [hp, max_hp]


func _play_bgm() -> void:
	AudioManager.play_bgm("game_bgm")


func _init_bullet_manager() -> void:
	var bm := preload("res://scenes/bullet/bullet_manager.tscn").instantiate()
	$GameNode.add_child(bm)
	var bullet_scene := preload("res://scenes/bullet/bullet.tscn")
	bm.initialize(bullet_scene, bullet_scene, 30)
	Debug.Log("GameScene: BulletManager 初始化完成")


func _spawn_player() -> void:
	var player_scene := preload("res://scenes/player/player.tscn")
	var player: Player = player_scene.instantiate()
	player.set_width(64)
	var screen_size := get_viewport_rect().size
	var spawn_pos := Vector2(screen_size.x / 2, screen_size.y / 2)
	player.position = spawn_pos
	# 先加入场景触发 player._ready → EcsWorld 注册 + 添加组件
	$GameNode.add_child(player)
	# 再设置世界边界
	var movement := EcsWorld.get_component(player.entity_id, PlayerMovementData) as PlayerMovementData
	if movement:
		world_boundary = Rect2(spawn_pos.x - 1500, spawn_pos.y - 1500, 3000, 3000)
		movement.world_boundary = world_boundary
	# 初始化血条显示
	var health := EcsWorld.get_component(player.entity_id, HealthData) as HealthData
	if health:
		SignalManager.player_damaged.emit(health.current_hp, health.max_hp)
	Debug.Log("GameScene: 玩家已生成，宽度=%d" % player.width)
	queue_redraw()


func _spawn_boss(body_count: int = 50) -> void:
	var boss_scene := preload("res://scenes/enemy/boss.tscn")
	var boss := boss_scene.instantiate()
	boss.body_count = body_count
	var marker := $GameNode/BossInitialPosition as Marker2D
	if marker:
		boss.global_position = marker.global_position
	$GameNode.add_child(boss)
	Debug.Log("GameScene: Boss 已生成，配置总节数=%d" % body_count)


# ===== 小怪生成 =====

func _init_enemy_pool() -> void:
	var scene := preload("res://scenes/enemy/base_enemy.tscn")
	var parent := $GameNode/Enemys
	_enemy_pool = ObjectPool.new(scene, parent, 10)
	Debug.Log("GameScene: 敌人生成池初始化完成")


func _process(delta: float) -> void:
	_spawn_timer += delta
	if _spawn_timer >= enemy_spawn_interval:
		_spawn_timer = 0.0
		_try_spawn_enemy()


func _try_spawn_enemy() -> void:
	if not _enemy_pool or $GameNode/Enemys.get_child_count() >= max_active_enemies:
		return

	var enemy := _enemy_pool.acquire() as BaseEnemy
	if not enemy:
		return

	enemy.pool = _enemy_pool
	enemy.is_pooled = true

	# world_boundary 内随机位置，距离玩家至少 enemy_min_spawn_dist
	var player := get_tree().get_first_node_in_group("player") as Node2D
	var player_pos: Vector2 = player.global_position if player else Vector2.ZERO
	var b := world_boundary
	var spawn_pos: Vector2
	var found := false
	for _attempt in 20:
		var x := randf_range(b.position.x + 50.0, b.position.x + b.size.x - 50.0)
		var y := randf_range(b.position.y + 50.0, b.position.y + b.size.y - 50.0)
		spawn_pos = Vector2(x, y)
		if player_pos.distance_squared_to(spawn_pos) >= enemy_min_spawn_dist * enemy_min_spawn_dist:
			found = true
			break
	if not found:
		spawn_pos = Vector2(b.position.x + 50, b.position.y + 50)

	enemy.global_position = spawn_pos
	enemy.play_spawn_effect()


func _draw() -> void:
	var p := get_tree().get_first_node_in_group("player") as Player
	if not p:
		return
	var movement := EcsWorld.get_component(p.entity_id, PlayerMovementData) as PlayerMovementData
	var wb := movement.world_boundary if movement else Rect2(0, 0, 3000, 3000)
	var l := wb.position.x
	var t := wb.position.y
	var r := wb.position.x + wb.size.x
	var b := wb.position.y + wb.size.y

	draw_rect(Rect2(l, t, r - l, b - t), Color(1, 1, 1, 0.06), true)

	var grid_col := Color(0, 0, 0, 0.05)
	var grid_step := 100.0
	var x: float = l + grid_step
	while x < r:
		draw_line(Vector2(x, t), Vector2(x, b), grid_col, 1.0, true)
		x += grid_step
	var y: float = t + grid_step
	while y < b:
		draw_line(Vector2(l, y), Vector2(r, y), grid_col, 1.0, true)
		y += grid_step

	var col := Color(0, 0, 0, 0.7)
	var w := 2.0
	draw_dashed_line(Vector2(l, t), Vector2(r, t), col, w, 8.0, 6.0, true)
	draw_dashed_line(Vector2(r, t), Vector2(r, b), col, w, 8.0, 6.0, true)
	draw_dashed_line(Vector2(l, b), Vector2(r, b), col, w, 8.0, 6.0, true)
	draw_dashed_line(Vector2(l, t), Vector2(l, b), col, w, 8.0, 6.0, true)
