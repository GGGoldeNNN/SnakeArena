## Boss 身体单节节点
## 每节身体独立处理伤害、独立销毁
## 被摧毁时发出 destroyed 信号，让 Boss 控制器重新拼接
class_name MonsterNode
extends Area2D

signal destroyed(node: MonsterNode)

## 目标显示尺寸（宽度，等比缩放）
@export var display_size: float = 150.0

## ECS 实体 ID
var entity_id: int = -1
## 是否由对象池管理（为 true 时 on_destroyed 不调用 queue_free）
var is_pooled: bool = false


func _ready() -> void:
	add_to_group("enemy")
	_update_scale()
	_init_ecs()


func _init_ecs() -> void:
	entity_id = EcsWorld.register(self)
	var health := HealthData.new()
	health.max_hp = 3.0
	health.invincible_time = 0.5
	health.current_hp = 3.0
	EcsWorld.add_component(entity_id, health)

	# 移动组件（由 SpawnSystem._apply_enemy_data 配置具体参数）
	EcsWorld.add_component(entity_id, MovementData.new())

	# 射击组件（由 SpawnSystem._apply_enemy_data 开启/配置）
	EcsWorld.add_component(entity_id, ShooterData.new())


## 等比缩放到目标尺寸
func set_display_size(pixels: float) -> void:
	display_size = pixels
	_update_scale()


func _update_scale() -> void:
	var sprite := $Sprite2D as Sprite2D
	if sprite and sprite.texture:
		var tex_w := sprite.texture.get_width()
		if tex_w > 0 and display_size < tex_w:
			var ratio := display_size / tex_w
			sprite.scale = Vector2(ratio, ratio)
			var shadow := $Shadow as Sprite2D
			if shadow:
				shadow.scale = Vector2(ratio, ratio)
				var shadow_offset := display_size * 0.06
				shadow.position = Vector2(shadow_offset, shadow_offset)
	_resize_collision()


func _resize_collision() -> void:
	var col := $CollisionShape2D as CollisionShape2D
	if col and col.shape:
		var cs := col.shape as CircleShape2D
		if cs:
			cs.radius = display_size * 0.5


## 从对象池重新激活时重置状态
func reset() -> void:
	modulate = Color.WHITE
	var health := EcsWorld.get_component(entity_id, HealthData) as HealthData
	if health:
		health.current_hp = health.max_hp
		health.invincible_timer = 0.0
		health.is_dead = false


## 受击闪红效果
func flash_hit() -> void:
	modulate = Color(1, 0.3, 0.3, 1)
	var tween := create_tween()
	tween.tween_property(self, "modulate", Color.WHITE, 0.12)


## HealthSystem 检测到 HP ≤ 0 时调用的销毁回调
func on_destroyed() -> void:
	destroyed.emit(self)
	SignalManager.enemy_killed.emit(self, global_position)
	if not is_pooled:
		queue_free()
