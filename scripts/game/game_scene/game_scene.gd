## 游戏主场景
## 管理玩家生成、Boss 生成、初始化子弹管理器
extends Node2D


func _ready() -> void:
	GameManager.reset()
	_init_bullet_manager()
	_spawn_player()
	_spawn_boss(200)
	_play_bgm()
	Debug.Log_Success("GameScene: 游戏场景初始化完成")


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
		movement.world_boundary = Rect2(spawn_pos.x - 1500, spawn_pos.y - 1500, 3000, 3000)
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
	Debug.Log("GameScene: Boss 已生成，身体节数=%d" % boss.body_count)


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
