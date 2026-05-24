## 子弹
## 自动追踪目标方向飞行，命中敌人后造成伤害并消失
class_name Bullet
extends Area2D

## 飞行速度
@export var speed: float = 800.0
## 最大飞行距离（超过后自毁）
@export var max_distance: float = 3000.0

var _direction: Vector2 = Vector2.RIGHT
var _distance_traveled: float = 0.0
var _damage: float = 1.0
## 所属 BulletManager（对象池回收用）
var _manager: BulletManager = null


func _ready() -> void:
	add_to_group("bullet")
	if not area_entered.is_connected(_on_area_entered):
		area_entered.connect(_on_area_entered)
	# 生成白色圆形纹理
	var sprite := $Sprite2D as Sprite2D
	if sprite and not sprite.texture:
		var image := Image.create(12, 12, false, Image.FORMAT_RGBA8)
		image.fill(Color(0, 0, 0, 0))
		for x in 12:
			for y in 12:
				var dx := x - 6
				var dy := y - 6
				if dx * dx + dy * dy <= 25:
					image.set_pixel(x, y, Color(1, 1, 1, 1))
		sprite.texture = ImageTexture.create_from_image(image)


## 对象池回收复位
func reset() -> void:
	_direction = Vector2.RIGHT
	_distance_traveled = 0.0
	_damage = 1.0
	rotation = 0.0
	position = Vector2.ZERO
	_manager = null
	if not area_entered.is_connected(_on_area_entered):
		area_entered.connect(_on_area_entered)


## 返回对象池或销毁
func _release() -> void:
	if _manager:
		_manager.release_bullet(self, true)
	else:
		queue_free()


func init(direction: Vector2, damage: float = 1.0, manager: BulletManager = null) -> void:
	_direction = direction.normalized()
	_damage = damage
	if manager:
		_manager = manager
	rotation = direction.angle()


func _process(delta: float) -> void:
	var step := _direction * speed * delta
	position += step
	_distance_traveled += step.length()
	if _distance_traveled >= max_distance:
		_release()


func _on_area_entered(area: Area2D) -> void:
	if not area.is_in_group("enemy"):
		return
	AudioManager.play_sfx("hit")
	if area_entered.is_connected(_on_area_entered):
		area_entered.disconnect(_on_area_entered)
	_damage_enemy(area)
	SignalManager.bullet_hit_enemy.emit(self, area)
	_release()


func _damage_enemy(area: Area2D) -> void:
	var eid := -1
	if "entity_id" in area:
		eid = area.entity_id as int
	if eid < 0:
		return
	var health := EcsWorld.get_component(eid, HealthData) as HealthData
	if health:
		health.take_damage(_damage)
		# 敌人已死亡 → 立即触发销毁回调
		if health.is_dead and area.has_method("on_destroyed"):
			area.on_destroyed()
			return
	if area.has_method("flash_hit"):
		area.flash_hit()
