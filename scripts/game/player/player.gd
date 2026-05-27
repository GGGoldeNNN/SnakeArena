## 玩家飞机 - 协调器
## 组合 PlayerMovementData + AutoShooterData + HealthData（通过 EcsWorld）
class_name Player
extends Area2D

## 目标宽度（像素），自动等比计算高度
@export var width: float = 64.0

## ECS 实体 ID
var entity_id: int = -1

func _ready() -> void:
	add_to_group("player")
	_update_scale()
	_init_ecs()
	var cam := $Camera2D as Camera2D
	if cam:
		cam.reset_smoothing()
	Debug.Log_Success("Player: 玩家飞机初始化完成")


func _init_ecs() -> void:
	entity_id = EcsWorld.register(self)

	# 生命值
	var health := HealthData.new()
	health.max_hp = 5.0
	health.invincible_time = 0.5
	health.current_hp = 5.0
	EcsWorld.add_component(entity_id, health)

	# 移动
	var movement := PlayerMovementData.new()
	movement.acceleration = 500.0
	movement.friction = 150.0
	movement.max_speed = 500.0
	EcsWorld.add_component(entity_id, movement)

	# 自动瞄准射击
	var shooter := AutoShooterData.new()
	shooter.range = 500.0
	shooter.cooldown = 0.25
	shooter.bullet_speed = 800.0
	shooter.bullet_damage = 1.0
	shooter.bullet_max_distance = 3000.0
	EcsWorld.add_component(entity_id, shooter)


## 根据目标宽度等比缩放
func _update_scale() -> void:
	var sprite := $Sprite as Sprite2D
	if sprite and sprite.texture:
		var tex_width := sprite.texture.get_width()
		if tex_width > 0 and width < tex_width:
			var ratio := width / tex_width
			sprite.scale = Vector2(ratio, ratio)
			var shadow := $Shadow as Sprite2D
			if shadow:
				shadow.scale = Vector2(ratio, ratio)
			var col := $CollisionShape2D as CollisionShape2D
			if col and col.shape:
				var cs := col.shape as CapsuleShape2D
				if cs:
					cs.radius = width * 0.3
					cs.height = sprite.texture.get_height() * ratio


## 外部设置尺寸（用于生成时动态指定）
func set_width(pixels: float) -> void:
	width = pixels
	_update_scale()


# === 碰撞处理 ===

## 公开方法：从外部造成伤害（敌弹碰撞等）
func take_damage(from_position: Vector2) -> void:
	_try_damage_and_knockback(from_position)


func _try_damage_and_knockback(from_position: Vector2) -> void:
	var health := EcsWorld.get_component(entity_id, HealthData) as HealthData
	if health:
		if health.invincible_timer > 0:
			return
		health.take_damage(1.0)
		SignalManager.player_damaged.emit(health.current_hp, health.max_hp)
		if health.is_dead:
			SignalManager.player_died.emit()
	var movement := EcsWorld.get_component(entity_id, PlayerMovementData) as PlayerMovementData
	if movement:
		movement.apply_knockback(from_position, global_position)
	flash_hit()


## 受击闪烁（公开方法，供外部系统调用）
func flash_hit() -> void:
	modulate = Color(1, 0.3, 0.3, 1)
	var tw := create_tween()
	tw.tween_property(self, "modulate", Color.WHITE, 0.15)


func _on_area_entered(area: Area2D) -> void:
	Debug.Log("Player: 碰撞到 " + area.name)
	_try_damage_and_knockback(area.global_position)


func _on_body_entered(body: Node2D) -> void:
	Debug.Log("Player: 碰撞到 " + body.name)
	_try_damage_and_knockback(body.global_position)


# === 攻击范围绘制 ===

func _draw() -> void:
	var data := EcsWorld.get_component(entity_id, AutoShooterData) as AutoShooterData
	if not data or data.range <= 0:
		return
	draw_circle(Vector2.ZERO, data.range, Color(1, 1, 1, 0.04))
	draw_arc(Vector2.ZERO, data.range, 0, TAU, 64, Color(1, 1, 1, 0.25), 1.5, true)
