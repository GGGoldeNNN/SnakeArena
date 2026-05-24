## 自动瞄准射击系统
## 每帧遍历拥有 AutoShooterData 的实体：自动瞄准、射击、触发绘制
extends Node


func _process(delta: float) -> void:
	for eid in EcsWorld.query_entities([AutoShooterData]):
		var node := EcsWorld.get_entity_node(eid) as Node2D
		var data := EcsWorld.get_component(eid, AutoShooterData) as AutoShooterData
		if not node or not data:
			continue

		data.attack_timer -= delta

		# 检查失控状态
		var move_data := EcsWorld.get_component(eid, PlayerMovementData) as PlayerMovementData
		if move_data and move_data.stun_timer > 0:
			node.queue_redraw()
			continue

		_auto_aim(node, delta)
		_auto_attack(node, data)
		node.queue_redraw()


## 自动转向最近敌人
func _auto_aim(node: Node2D, delta: float) -> void:
	var target := _find_nearest_enemy(node)
	if not target:
		return
	var dir := node.global_position.direction_to(target.global_position)
	var target_rot := dir.angle() + PI / 2
	node.rotation = lerp_angle(node.rotation, target_rot, 8.0 * delta)


## 自动射击（仅攻击范围内敌人）
func _auto_attack(node: Node2D, data: AutoShooterData) -> void:
	if data.attack_timer > 0:
		return
	var target := _find_nearest_enemy_in_range(node, data.range)
	if not target:
		return
	_fire_bullet(node, data, target)
	data.attack_timer = data.cooldown


## 查找最近敌人（任何距离）
func _find_nearest_enemy(node: Node2D) -> Node2D:
	var enemies := get_tree().get_nodes_in_group("enemy")
	if enemies.is_empty():
		return null
	var nearest: Node2D = null
	var min_dist_sq := INF
	var my_pos := node.global_position
	for e in enemies:
		var d_sq := my_pos.distance_squared_to(e.global_position)
		if d_sq < min_dist_sq:
			min_dist_sq = d_sq
			nearest = e
	return nearest


## 查找攻击范围内最近敌人
func _find_nearest_enemy_in_range(node: Node2D, range_val: float) -> Node2D:
	var enemies := get_tree().get_nodes_in_group("enemy")
	if enemies.is_empty():
		return null
	var nearest: Node2D = null
	var min_dist_sq := range_val * range_val
	var my_pos := node.global_position
	for e in enemies:
		var d_sq := my_pos.distance_squared_to(e.global_position)
		if d_sq < min_dist_sq:
			min_dist_sq = d_sq
			nearest = e
	return nearest


## 发射子弹
func _fire_bullet(node: Node2D, data: AutoShooterData, target: Node2D) -> void:
	var bm := _find_bullet_manager()
	if not bm:
		return

	var dir := node.global_position.direction_to(target.global_position)
	var bullet_data := BulletData.new()
	bullet_data.speed = data.bullet_speed
	bullet_data.damage = data.bullet_damage
	bullet_data.lifetime = data.bullet_max_distance / data.bullet_speed

	var bullet := bm.spawn_player_bullet(bullet_data) as Bullet
	if not bullet:
		return
	bullet.global_position = node.global_position
	bullet.init(dir, data.bullet_damage)
	SignalManager.player_shot.emit(bullet, target.global_position)
	AudioManager.play_sfx("bullet")


func _find_bullet_manager() -> BulletManager:
	var root := get_tree().current_scene
	if root:
		var n := root.find_child("BulletManager", true, false)
		if n:
			return n as BulletManager
	return null
