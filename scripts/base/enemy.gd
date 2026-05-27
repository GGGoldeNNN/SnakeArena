## 敌人类（基类）
## 提供 ECS 注册、缩放、对象池、受击反馈、碰撞组管理等通用功能
extends Node2D

class_name Enemy

## 目标显示宽度（像素），等比缩放
@export var display_size: float = 60.0

## ECS 实体 ID
var entity_id: int = -1

## 所属对象池（由生成器注入，on_destroyed 时自回收）
var pool: ObjectPool = null
## 特效中心偏移量（相对节点原点），用于校正贴图视觉中心不居中的情况
@export var effect_center_offset: Vector2 = Vector2.ZERO
## 是否由对象池管理
var is_pooled: bool = false


func _ready() -> void:
	_update_scale()
	_init_ecs()
	# 注意：add_to_group("enemy") 在 reset() 中执行
	# 避免预创建（prewarm）时离屏敌人被自动瞄准锁定


## 虚方法 — 子类在此注册 ECS 组件
func _init_ecs() -> void:
	pass


## 等比缩放到目标尺寸
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


## 特效中心（节点原点 + 偏移量）
func _get_effect_center() -> Vector2:
	return global_position + effect_center_offset


## 查找 BulletManager（获取特效池用）
static func _get_bullet_manager() -> BulletManager:
	var tree := Engine.get_main_loop() as SceneTree
	if tree:
		return tree.current_scene.find_child("BulletManager", true, false) as BulletManager
	return null


## 对象池复位（acquire 时自动调用）
func reset() -> void:
	add_to_group("enemy")
	var health := EcsWorld.get_component(entity_id, HealthData) as HealthData
	if health:
		health.current_hp = health.max_hp
		health.invincible_timer = 0.0
		health.is_dead = false
	var mov := EcsWorld.get_component(entity_id, MovementData) as MovementData
	if mov:
		mov.speed = mov.SPEED_DEFAULT
		mov.time_elapsed = 0.0
	modulate = Color.WHITE
	_update_scale()


## 出生特效 — 由生成器在设置位置后调用
func play_spawn_effect() -> void:
	# 传送门环（从 BulletManager 池获取）
	var bm := _get_bullet_manager()
	if bm:
		bm.spawn_portal_effect(_get_effect_center())

	# 敌人从门中弹出
	scale = Vector2.ZERO
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", Vector2.ONE, 0.35)


## HealthSystem 检测到死亡时调用的销毁回调
func on_destroyed() -> void:
	remove_from_group("enemy")
	SignalManager.enemy_killed.emit(self, global_position)
	_play_death_effect()


## 死亡特效 — 扩散线圈 + 破碎粒子 + 缩小淡出，结束后归还池中
func _play_death_effect() -> void:
	# 停止移动，让特效固定在死亡位置
	var mov := EcsWorld.get_component(entity_id, MovementData) as MovementData
	if mov:
		mov.speed = 0.0

	var center := _get_effect_center()
	# 以敌人实际尺寸计算特效范围（从 BulletManager 池获取）
	var bm := _get_bullet_manager()
	if bm:
		bm.spawn_death_ring_effect(center, max(display_size, 60.0))

	# 敌人自身缩小淡出
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "modulate", Color(1, 1, 1, 0), 0.25)
	tween.tween_property(self, "scale", Vector2.ZERO, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tween.finished.connect(_release_pool)


func _release_pool() -> void:
	if not is_instance_valid(self):
		return
	if pool:
		pool.release(self)
	elif not is_pooled:
		queue_free()


## 受击闪红
func flash_hit() -> void:
	modulate = Color(1, 0.3, 0.3, 1)
	var tween := create_tween()
	tween.tween_property(self, "modulate", Color.WHITE, 0.12)
