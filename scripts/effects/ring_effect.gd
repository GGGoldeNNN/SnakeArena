## 环形特效 — 出生传送门 / 死亡扩散线圈 + 破碎粒子
## 纯 _draw 渲染，支持对象池回收
class_name RingEffect
extends Node2D

## 所属对象池
var pool: ObjectPool = null

var _portal_progress: float = 0.0
var _portal_rotation: float = 0.0
var _portal_color: Color = Color(0.3, 0.7, 1.0, 0.8)
var _portal_max_radius: float = 60.0

# 死亡线圈
var _ring_radius: Array[float] = []
var _ring_alpha: Array[float] = []
# 破碎粒子
var _part_angle: Array[float] = []
var _part_dist: Array[float] = []
var _part_alpha: Array[float] = []
var _part_size: Array[float] = []
var _part_color: Array[Color] = []

var _is_active: bool = false
var _tweens: Array[Tween] = []


func _process(_delta: float) -> void:
	if _is_active:
		queue_redraw()


## 对象池复位
func reset() -> void:
	_is_active = false
	for t in _tweens:
		if is_instance_valid(t):
			t.kill()
	_tweens.clear()


## 启动传送门效果
func play_portal(pos: Vector2, color: Color = Color(0.3, 0.7, 1.0, 0.8), max_radius: float = 60.0, duration: float = 0.4) -> void:
	global_position = pos
	_portal_color = color
	_portal_max_radius = max_radius
	_portal_progress = 0.001
	_portal_rotation = 0.0
	_is_active = true
	_tweens.clear()

	var tween := create_tween()
	_tweens.append(tween)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "_portal_progress", 1.0, duration)
	tween.parallel().tween_property(self, "_portal_rotation", PI * 4, duration)
	tween.parallel().tween_method(_set_portal_alpha, 0.8, 0.0, duration * 0.7).set_delay(duration * 0.3)
	tween.finished.connect(_finish)


func _set_portal_alpha(alpha: float) -> void:
	_portal_color.a = alpha


## 启动死亡效果：2 层粗线圈 + 12 个破碎粒子
func play_death_rings(pos: Vector2, max_radius: float = 80.0, duration: float = 0.5) -> void:
	global_position = pos
	_is_active = true
	_tweens.clear()

	# — 线圈 —
	_ring_radius.resize(2)
	_ring_alpha.resize(2)
	for i in 2:
		_ring_radius[i] = 0.0
		_ring_alpha[i] = 1.0
		var tween := create_tween()
		_tweens.append(tween)
		tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween.tween_method(_set_ring_radius.bind(i), 0.0, max_radius, duration).set_delay(i * 0.1)
		tween.parallel().tween_method(_set_ring_alpha.bind(i), 1.0, 0.0, duration * 0.5).set_delay(i * 0.1 + duration * 0.5)

	# — 破碎粒子 —
	var rng := RandomNumberGenerator.new()
	var count := 12
	var colors := [Color(1.0, 0.85, 0.4), Color(1.0, 0.6, 0.1), Color(1.0, 0.95, 0.7), Color(1.0, 1.0, 1.0)]
	_part_angle.resize(count)
	_part_dist.resize(count)
	_part_alpha.resize(count)
	_part_size.resize(count)
	_part_color.resize(count)
	for i in count:
		_part_angle[i] = rng.randf_range(0.0, TAU)
		_part_dist[i] = 0.0
		_part_alpha[i] = 1.0
		_part_size[i] = rng.randf_range(4.0, 9.0)
		_part_color[i] = colors[rng.randi_range(0, colors.size() - 1)]
		var speed := rng.randf_range(60.0, 180.0)
		var delay := rng.randf_range(0.0, 0.06)
		var pt := create_tween()
		_tweens.append(pt)
		pt.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		pt.tween_method(_set_part_dist.bind(i), 0.0, speed, duration * 1.6).set_delay(delay)
		pt.parallel().tween_method(_set_part_alpha.bind(i), 1.0, 0.0, duration * 1.4).set_delay(delay)
		pt.parallel().tween_method(_set_part_size.bind(i), _part_size[i], 0.0, duration * 1.2).set_delay(delay)

	var cleanup := create_tween()
	_tweens.append(cleanup)
	cleanup.tween_callback(_finish).set_delay(duration * 1.6 + 0.4)


func _set_ring_radius(value: float, idx: int) -> void:
	_ring_radius[idx] = value


func _set_ring_alpha(value: float, idx: int) -> void:
	_ring_alpha[idx] = value


func _set_part_dist(value: float, idx: int) -> void:
	_part_dist[idx] = value


func _set_part_alpha(value: float, idx: int) -> void:
	_part_alpha[idx] = value


func _set_part_size(value: float, idx: int) -> void:
	_part_size[idx] = value


## 修复可能残留的旧 tween 连接
func _finish() -> void:
	_is_active = false
	if pool:
		pool.release(self)
	else:
		queue_free()


func _draw() -> void:
	if _portal_progress > 0 and _portal_progress < 1.0:
		var r := _portal_max_radius * _portal_progress
		# 外圈顺时针旋转
		draw_arc(Vector2.ZERO, r, _portal_rotation, _portal_rotation + PI * 2 * _portal_progress, 48, _portal_color, 2.0)
		# 内圈逆时针旋转
		draw_arc(Vector2.ZERO, r * 0.6, -_portal_rotation, -_portal_rotation + PI * 2 * _portal_progress, 36,
			Color(_portal_color.r, _portal_color.g, _portal_color.b, _portal_color.a * 0.5), 1.5)

	# 死亡线圈（白色，粗线条）
	for i in _ring_radius.size():
		var radius: float = _ring_radius[i]
		var alpha: float = _ring_alpha[i]
		if radius > 2.0 and alpha > 0.01:
			draw_arc(Vector2.ZERO, radius, 0, TAU, 48, Color(1, 1, 1, alpha), 3.5)

	# 破碎粒子（亮色碎片飞散）
	for i in _part_angle.size():
		if _part_alpha[i] <= 0.01:
			continue
		var offset := Vector2(cos(_part_angle[i]), sin(_part_angle[i])) * _part_dist[i]
		var col: Color = _part_color[i]
		col.a = _part_alpha[i]
		draw_circle(offset, _part_size[i], col)
