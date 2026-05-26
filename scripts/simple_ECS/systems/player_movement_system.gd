## 玩家移动系统
## 每帧遍历拥有 PlayerMovementData 的实体：输入处理/惯性/边界/击退
extends Node


func _process(delta: float) -> void:
	for eid in EcsWorld.query_entities([PlayerMovementData]):
		var node := EcsWorld.get_entity_node(eid) as Node2D
		var data := EcsWorld.get_component(eid, PlayerMovementData) as PlayerMovementData
		if not node or not data:
			continue

		if data.stun_timer > 0:
			data.stun_timer -= delta
		else:
			_handle_input(data, delta)
		_apply_movement(data, node, delta)
		_clamp_to_screen(data, node, eid)


func _handle_input(data: PlayerMovementData, delta: float) -> void:
	var input_dir := Vector2.ZERO

	if Input.is_action_pressed("ui_right") or Input.is_key_pressed(KEY_D):
		input_dir.x += 1
	if Input.is_action_pressed("ui_left") or Input.is_key_pressed(KEY_A):
		input_dir.x -= 1
	if Input.is_action_pressed("ui_down") or Input.is_key_pressed(KEY_S):
		input_dir.y += 1
	if Input.is_action_pressed("ui_up") or Input.is_key_pressed(KEY_W):
		input_dir.y -= 1

	if input_dir.length() > 0:
		input_dir = input_dir.normalized()
		data.velocity += input_dir * data.acceleration * delta
		if data.velocity.length() > data.max_speed:
			data.velocity = data.velocity.normalized() * data.max_speed
	else:
		var spd := data.velocity.length()
		if spd > 0:
			var fric := data.friction * delta
			if spd > fric:
				data.velocity = data.velocity.normalized() * (spd - fric)
			else:
				data.velocity = Vector2.ZERO


func _apply_movement(data: PlayerMovementData, node: Node2D, delta: float) -> void:
	node.position += data.velocity * delta
	node.position = node.position.round()


func _clamp_to_screen(data: PlayerMovementData, node: Node2D, eid: int) -> void:
	var b := data.world_boundary
	var bx := b.position.x
	var by := b.position.y
	var br := b.position.x + b.size.x
	var bb := b.position.y + b.size.y

	var hit := false
	var bounce := data.velocity

	if node.position.x < bx:
		node.position.x = bx
		bounce.x = -bounce.x
		hit = true
	elif node.position.x > br:
		node.position.x = br
		bounce.x = -bounce.x
		hit = true

	if node.position.y < by:
		node.position.y = by
		bounce.y = -bounce.y
		hit = true
	elif node.position.y > bb:
		node.position.y = bb
		bounce.y = -bounce.y
		hit = true

	if hit and bounce.length_squared() > 0:
		data.velocity = bounce.normalized() * data.knockback_force
		data.stun_timer = data.knockback_stun

		# 边界碰撞造成伤害
		var health := EcsWorld.get_component(eid, HealthData) as HealthData
		if health and health.invincible_timer <= 0 and not health.is_dead:
			health.take_damage(1.0)
			SignalManager.player_damaged.emit(health.current_hp, health.max_hp)
			if health.is_dead:
				SignalManager.player_died.emit()
