## 移动系统
## 每帧遍历拥有 MovementData 的实体，按预设模式更新位置
extends Node


func _process(delta: float) -> void:
	for eid in EcsWorld.query_entities([MovementData]):
		var node := EcsWorld.get_entity_node(eid) as Node2D
		var data := EcsWorld.get_component(eid, MovementData) as MovementData
		if not node or not data or data.pattern == MovementData.Pattern.STOP:
			continue

		data.time_elapsed += delta
		var offset := _compute_movement(data, node) * delta
		node.position += offset


## 计算本帧位移向量
func _compute_movement(data: MovementData, node: Node2D) -> Vector2:
	match data.pattern:
		MovementData.Pattern.LINEAR:
			return Vector2(cos(data.direction), sin(data.direction)) * data.speed

		MovementData.Pattern.SINE:
			var base := Vector2(cos(data.direction), sin(data.direction)) * data.speed
			var perp := Vector2(-sin(data.direction), cos(data.direction))
			var osc := perp * sin(data.time_elapsed * data.frequency * TAU) * data.amplitude * data.frequency
			return base + osc

		MovementData.Pattern.CHASE:
			var target := get_tree().get_first_node_in_group("player")
			if target:
				var dir: Vector2 = (target.global_position - node.global_position).normalized()
				return dir * data.speed
			return Vector2.DOWN * data.speed

		MovementData.Pattern.ORBIT:
			var angle := data.time_elapsed * data.frequency * TAU
			var offset := Vector2(cos(angle), sin(angle)) * data.amplitude
			return offset.normalized() * data.speed

	return Vector2.ZERO
