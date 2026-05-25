## Boss 头部
## 负责视觉缩放、朝向移动方向
## 头部被攻击不会受伤
class_name MonsterHead
extends Area2D

## 目标显示尺寸（宽度，等比缩放）
@export var display_size: float = 150.0

## ECS 实体 ID（无组件，仅用于子弹碰撞查询）
var entity_id: int = -1


func _ready() -> void:
	add_to_group("enemy")
	_update_scale()
	entity_id = EcsWorld.register(self)
	Debug.Log("MonsterHead: 头部初始化完成")


## 等比缩放到目标尺寸
func set_display_size(pixels: float) -> void:
	display_size = pixels
	_update_scale()


func _update_scale() -> void:
	# 缩放精灵和阴影
	var sprite: Sprite2D = $Sprite2D
	if sprite and sprite.texture:
		var tex_w := sprite.texture.get_width()
		if tex_w > 0 and display_size < tex_w:
			var ratio := display_size / tex_w
			sprite.scale = Vector2(ratio, ratio)
			var shadow: Sprite2D = $Shadow
			if shadow:
				shadow.scale = Vector2(ratio, ratio)
				var shadow_offset := display_size * 0.06
				shadow.position = Vector2(shadow_offset, shadow_offset)

	# 直接修改碰撞体尺寸
	_resize_collision()


## 受击闪红效果
func flash_hit() -> void:
	modulate = Color(1, 0.3, 0.3, 1)
	var tween := create_tween()
	tween.tween_property(self, "modulate", Color.WHITE, 0.12)


func _resize_collision() -> void:
	var col := $CollisionShape2D as CollisionShape2D
	if col and col.shape:
		var cs := col.shape as CircleShape2D
		if cs:
			cs.radius = display_size * 0.25
			Debug.Log("MonsterHead: 碰撞体半径 => %.0f" % cs.radius)
		else:
			Debug.Log("MonsterHead: 碰撞体不是 CircleShape2D，类型=" + str(typeof(col.shape)))
	else:
		Debug.Log("MonsterHead: 找不到碰撞体或 shape 为空")
