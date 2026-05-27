## 基础敌人 — ECS 实体
## 注册 HealthData + MovementData(CHASE) + FaceTargetData，支持对象池回收
extends Enemy

class_name BaseEnemy


func _init_ecs() -> void:
	entity_id = EcsWorld.register(self)

	var health := HealthData.new()
	health.max_hp = 3.0
	health.invincible_time = 0.5
	health.current_hp = 3.0
	EcsWorld.add_component(entity_id, health)

	var movement := MovementData.new()
	movement.speed = 200.0
	movement.pattern = MovementData.Pattern.CHASE
	EcsWorld.add_component(entity_id, movement)

	var face_target := FaceTargetData.new()
	face_target.target_group = "player"
	face_target.offset_angle = PI / 2
	EcsWorld.add_component(entity_id, face_target)
