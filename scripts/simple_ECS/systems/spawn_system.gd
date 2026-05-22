## 敌人生成系统
## 管理敌人波次、生成逻辑，挂载在 GameNode 下
class_name SpawnSystem
extends Node

signal wave_started(wave: int)
signal wave_cleared(wave: int)

## 默认敌人生成间隔（秒）
@export var spawn_interval: float = 2.0
## 是否自动开始
@export var auto_start: bool = true

var _enemy_pool: ObjectPool
var _current_wave: int = 0
var _active_enemies: Array[Node] = []
var _spawn_timer: float = 0.0
var _spawning: bool = false

## 当前波次配置（由外部填充）
var wave_queue: Array[Array] = []


func _ready() -> void:
	if auto_start:
		start()


## 初始化敌人对象池
func initialize(enemy_scene: PackedScene, prewarm: int = 10) -> void:
	_enemy_pool = ObjectPool.new(enemy_scene, self, prewarm)


func _process(delta: float) -> void:
	if not _spawning or not _enemy_pool:
		return

	_spawn_timer += delta
	if _spawn_timer >= spawn_interval:
		_spawn_timer = 0.0
		_try_spawn()


func _try_spawn() -> void:
	if wave_queue.is_empty():
		_spawning = false
		return

	var entry: Array = wave_queue[0]
	var enemy_data: EnemyData = entry[0]
	var count: int = entry[1]

	if count <= 0:
		wave_queue.pop_front()
		_current_wave += 1
		wave_cleared.emit(_current_wave)
		return

	var enemy: Node2D = _enemy_pool.acquire() as Node2D
	if enemy:
		_active_enemies.append(enemy)
		_apply_enemy_data(enemy, enemy_data)
		var cam: Camera2D = get_viewport().get_camera_2d()
		if cam:
			var screen: Vector2 = get_viewport().size
			var world_pos: Vector2 = cam.global_position - screen / 2 + Vector2(
				randf_range(50, screen.x - 50),
				-50
			)
			enemy.global_position = world_pos
		entry[1] -= 1


## 将 EnemyData 应用到敌人实例上
func _apply_enemy_data(enemy: Node2D, data: EnemyData) -> void:
	var hc: HealthComponent = _find_component(enemy, "HealthComponent") as HealthComponent
	if hc:
		hc.max_hp = data.max_hp
		hc.reset()

	var mc: MovementComponent = _find_component(enemy, "MovementComponent") as MovementComponent
	if mc:
		mc.speed = data.speed
		mc.pattern = data.move_pattern as int
		mc.amplitude = data.amplitude
		mc.frequency = data.frequency
		mc.reset()

	var sc: ShooterComponent = _find_component(enemy, "ShooterComponent") as ShooterComponent
	if sc:
		if data.has_weapon and data.bullet_data:
			sc.bullet_data = data.bullet_data
			sc.fire_interval = data.fire_interval
			sc.fire_angle = data.fire_angle
			sc.reset()
			sc.start()
		else:
			sc.stop()


## 递归查找子节点中的组件
func _find_component(root: Node, component_class: String) -> Node:
	for child in root.get_children():
		if child.is_class(component_class):
			return child
		var found: Node = _find_component(child, component_class)
		if found:
			return found
	return null


## 开始生成
func start() -> void:
	_spawning = true
	_spawn_timer = 0.0


## 停止生成
func stop() -> void:
	_spawning = false


## 添加波次
func add_wave(enemy_data: EnemyData, count: int) -> void:
	wave_queue.append([enemy_data, count])


## 敌人被销毁时调用
func on_enemy_destroyed(enemy: Node) -> void:
	_active_enemies.erase(enemy)
	_enemy_pool.release(enemy)
