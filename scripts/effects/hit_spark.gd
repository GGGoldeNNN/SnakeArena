## 命中火花 — 子弹击中敌人时的爆炸粒子
## 纯 _draw 渲染，支持对象池回收
class_name HitSpark
extends Node2D

## 所属对象池（由 BulletManager 注入，_finish 时自回收）
var pool: ObjectPool = null

# 粒子数据
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
	# Kill 残留 tween，防止旧 _finish 回调重复回收
	for t in _tweens:
		if is_instance_valid(t):
			t.kill()
	_tweens.clear()


## 播放命中火花
func play(pos: Vector2, duration: float = 0.2) -> void:
	global_position = pos
	_is_active = true
	_tweens.clear()

	var rng := RandomNumberGenerator.new()
	var count := 8
	var colors := [Color(1.0, 0.95, 0.6), Color(1.0, 0.7, 0.2), Color(1.0, 1.0, 0.8)]
	_part_angle.resize(count)
	_part_dist.resize(count)
	_part_alpha.resize(count)
	_part_size.resize(count)
	_part_color.resize(count)

	for i in count:
		_part_angle[i] = rng.randf_range(0.0, TAU)
		_part_dist[i] = 0.0
		_part_alpha[i] = 1.0
		_part_size[i] = rng.randf_range(2.5, 5.0)
		_part_color[i] = colors[rng.randi_range(0, colors.size() - 1)]
		var speed := rng.randf_range(30.0, 90.0)
		var delay := rng.randf_range(0.0, 0.03)
		var pt := create_tween()
		_tweens.append(pt)
		pt.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		pt.tween_method(_set_part_dist.bind(i), 0.0, speed, duration * 0.9).set_delay(delay)
		pt.parallel().tween_method(_set_part_alpha.bind(i), 1.0, 0.0, duration * 0.8).set_delay(delay)
		pt.parallel().tween_method(_set_part_size.bind(i), _part_size[i], 0.0, duration * 0.6).set_delay(delay)

	var cleanup := create_tween()
	_tweens.append(cleanup)
	cleanup.tween_callback(_finish).set_delay(duration + 0.15)


func _set_part_dist(value: float, idx: int) -> void:
	_part_dist[idx] = value


func _set_part_alpha(value: float, idx: int) -> void:
	_part_alpha[idx] = value


func _set_part_size(value: float, idx: int) -> void:
	_part_size[idx] = value


func _finish() -> void:
	_is_active = false
	if pool:
		pool.release(self)
	else:
		queue_free()


func _draw() -> void:
	for i in _part_angle.size():
		if _part_alpha[i] <= 0.01:
			continue
		var offset := Vector2(cos(_part_angle[i]), sin(_part_angle[i])) * _part_dist[i]
		var col: Color = _part_color[i]
		col.a = _part_alpha[i]
		draw_circle(offset, _part_size[i], col)
