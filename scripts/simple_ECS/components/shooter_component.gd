## 射击组件
## 控制实体按预设模式发射子弹
class_name ShooterComponent
extends Node

signal shot(bullet: Node2D, direction: Vector2)

## 射击间隔（秒）
@export var fire_interval: float = 1.5
## 射击方向（度，0=右, 90=下）
@export var fire_angle: float = 90.0
## 子弹数据
@export var bullet_data: BulletData
## 散弹数量
@export var spread_count: int = 1
## 散弹扩散角（度）
@export var spread_angle: float = 0.0

var _timer: float = 0.0
var _enabled: bool = false
var _bullet_manager: Node  # 运行时是 BulletManager


func _ready() -> void:
	_bullet_manager = _find_bullet_manager()


func _process(delta: float) -> void:
	if not _enabled or not _bullet_manager or not bullet_data:
		return

	_timer += delta
	if _timer >= fire_interval:
		_timer -= fire_interval
		_fire()


## 开始射击
func start() -> void:
	_enabled = true


## 停止射击
func stop() -> void:
	_enabled = false
	_timer = 0.0


## 开火
func _fire() -> void:
	var base_rad: float = deg_to_rad(fire_angle)
	var count: int = maxi(1, spread_count)

	for i in count:
		var offset_rad: float = 0.0
		if count > 1:
			offset_rad = deg_to_rad(spread_angle) * (i - (count - 1) / 2.0)

		var dir: Vector2 = Vector2(cos(base_rad + offset_rad), sin(base_rad + offset_rad))
		var bullet: Node2D = _bullet_manager.spawn_enemy_bullet(bullet_data)
		if bullet:
			bullet.global_position = owner.global_position if owner else get_parent().global_position
			if bullet.has_method("launch"):
				bullet.launch(dir, bullet_data.speed)
			shot.emit(bullet, dir)


func _find_bullet_manager() -> Node:
	var root: Node = get_tree().current_scene
	if root:
		var node: Node = root.find_child("BulletManager", true, false)
		if node:
			return node
	return null


## 重置
func reset() -> void:
	_timer = 0.0
	_enabled = false
	_bullet_manager = _find_bullet_manager()
