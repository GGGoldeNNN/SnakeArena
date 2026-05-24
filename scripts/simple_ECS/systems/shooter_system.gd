## 射击系统
## 每帧遍历拥有 ShooterData 的实体，按配置发射子弹
extends Node


func _process(delta: float) -> void:
	for eid in EcsWorld.query_entities([ShooterData]):
		var node := EcsWorld.get_entity_node(eid) as Node2D
		var data := EcsWorld.get_component(eid, ShooterData) as ShooterData
		if not node or not data or not data.enabled or not data.bullet_data:
			continue

		data.fire_timer += delta
		if data.fire_timer >= data.fire_interval:
			data.fire_timer -= data.fire_interval
			_fire(node, data)


func _fire(node: Node2D, data: ShooterData) -> void:
	var bm := _find_bullet_manager()
	if not bm:
		return

	var base_rad: float = deg_to_rad(data.fire_angle)
	var count: int = maxi(1, data.spread_count)

	for i in count:
		var offset_rad: float = 0.0
		if count > 1:
			offset_rad = deg_to_rad(data.spread_angle) * (i - (count - 1) / 2.0)

		var dir := Vector2(cos(base_rad + offset_rad), sin(base_rad + offset_rad))
		var bullet := bm.spawn_enemy_bullet(data.bullet_data) as Bullet
		if bullet:
			bullet.global_position = node.global_position
			bullet.init(dir, data.bullet_data.damage)


func _find_bullet_manager() -> BulletManager:
	var root := get_tree().current_scene
	if root:
		var n := root.find_child("BulletManager", true, false)
		if n:
			return n as BulletManager
	return null
