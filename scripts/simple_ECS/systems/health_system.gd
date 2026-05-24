## 生命值系统
## 每帧遍历拥有 HealthData 的实体：递减无敌计时、检测死亡
extends Node


func _process(delta: float) -> void:
	for eid in EcsWorld.query_entities([HealthData]):
		var data := EcsWorld.get_component(eid, HealthData) as HealthData
		if not data or data.is_dead:
			continue

		# 递减无敌计时
		if data.invincible_timer > 0:
			data.invincible_timer -= delta

		# 检测死亡
		if data.current_hp <= 0:
			data.is_dead = true
			var node := EcsWorld.get_entity_node(eid) as Node
			if node and is_instance_valid(node):
				# 优先调用实体自身的销毁回调
				if node.has_method("on_destroyed"):
					node.on_destroyed()
				else:
					node.queue_free()
