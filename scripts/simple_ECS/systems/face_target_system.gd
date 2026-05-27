## 朝向目标系统
## 每帧遍历拥有 FaceTargetData 的实体，旋转朝向目标组中最近的节点
extends Node


func _process(delta: float) -> void:
	for eid in EcsWorld.query_entities([FaceTargetData]):
		var node := EcsWorld.get_entity_node(eid) as Node2D
		var data := EcsWorld.get_component(eid, FaceTargetData) as FaceTargetData
		if not node or not data:
			continue

		var target := _find_nearest_in_group(node, data.target_group)
		if not target:
			continue

		var dir := node.global_position.direction_to(target.global_position)
		node.rotation = dir.angle() + data.offset_angle


## 查找目标组中最近的节点
func _find_nearest_in_group(node: Node2D, group: String) -> Node2D:
	var nodes := get_tree().get_nodes_in_group(group)
	if nodes.is_empty():
		return null
	var nearest: Node2D = null
	var min_dist_sq := INF
	var my_pos := node.global_position
	for n in nodes:
		var n2 := n as Node2D
		if not n2:
			continue
		var d_sq := my_pos.distance_squared_to(n2.global_position)
		if d_sq < min_dist_sq:
			min_dist_sq = d_sq
			nearest = n2
	return nearest
