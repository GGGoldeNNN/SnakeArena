## Boss 主控制器
## 贪吃蛇式结构：一个头部 + 多节身体
## 头部主导移动，身体沿轨迹跟随
## 身体可独立被摧毁，摧毁后头部和剩余身体回缩拼接
class_name Boss
extends Node2D

## Boss 状态
enum State { CHASING, RETREATING }

## 追逐速度
@export var chase_speed: float = 250.0
## 弧形摆动幅度（像素）
@export var arc_amplitude: float = 400.0
## 弧形摆动频率
@export var arc_frequency: float = 1.5
## 入场速度
@export var enter_speed: float = 150.0
## 身体节数
@export var body_count: int = 50
## 头部显示尺寸（宽度，等比）
@export var head_display_size: float = 200.0
## 身体节显示尺寸（宽度，等比）
@export var body_display_size: float = 100.0
## 身体节之间的中心距（由 display_size 自动计算）
var body_spacing: float
## 头部中心到第一节身体中心的距离（由 display_size 自动计算）
var head_to_body_spacing: float

var _head: MonsterHead
var _body_segments: Array[MonsterNode] = []
var _state: State = State.CHASING

## 头部移动轨迹（蛇形跟随用）
var _trail_positions: Array[Vector2] = []
var _trail_distances: Array[float] = []
## 弧形路径时间
var _arc_time: float = 0.0

## 缩带动画计时（>0 时暂停追击和身体更新，让 Tween 流畅过渡）
var _freeze_timer: float = 0.0


func _ready() -> void:
	_initialize_boss()


func _initialize_boss() -> void:
	_update_spacing()
	_create_head()
	_create_body_segments()
	_setup_entry()
	Debug.Log_Success("Boss: 初始化完成，共 %d 节身体" % body_count)


## 阴影在纹理中的偏移量（与 MonsterNode/Head 的 Shadow.position 对应）
const SHADOW_TEX_OFFSET: float = 30.0
const BODY_TEX_SIZE: float = 500.0

## 根据显示尺寸自动计算间距
func _update_spacing() -> void:
	var shadow_px := SHADOW_TEX_OFFSET * (body_display_size / BODY_TEX_SIZE)
	head_to_body_spacing = body_display_size * 0.5 + 50.0
	body_spacing = body_display_size * 0.5 + body_display_size * 0.5 + shadow_px


func _create_head() -> void:
	var head_scene := preload("res://scenes/enemy/monster_head.tscn")
	_head = head_scene.instantiate()
	_head.set_display_size(head_display_size)
	_head.z_index = body_count + 1
	add_child(_head)


func _create_body_segments() -> void:
	var node_scene := preload("res://scenes/enemy/monster_node.tscn")
	for i in body_count:
		var node := node_scene.instantiate() as MonsterNode
		node.set_display_size(body_display_size)
		node.z_index = body_count - i
		node.destroyed.connect(_on_body_destroyed)
		add_child(node)
		_body_segments.append(node)


func _setup_entry() -> void:
	_arc_time = 0.0
	# 从最远的轨迹点添加到头部当前位置，保证头部是最新轨迹点
	# 这样身体节在入口时在头部后方（上方）正确散布，不会因反向挤压而重叠
	for i in range(body_count + 2, -1, -1):
		var offset := 0.0 if i == 0 else head_to_body_spacing + (i - 1) * body_spacing
		var offset_pos := _head.global_position + Vector2(0, -offset)
		_add_trail_point(offset_pos)
	_head.rotation = PI
	Debug.Log("Boss: 初始位置 %s，开始追逐玩家" % str(_head.global_position))


func _process(_delta: float) -> void:
	if _freeze_timer > 0:
		_freeze_timer -= _delta
		_add_trail_point(_head.global_position)
		return

	match _state:
		State.CHASING:
			_process_chasing(_delta)
		State.RETREATING:
			_process_retreating(_delta)

	_add_trail_point(_head.global_position)
	_update_body_positions()
	_update_body_rotations()
	_prune_trail()


func _process_chasing(delta: float) -> void:
	var player := get_tree().get_first_node_in_group("player")
	if not player:
		return

	_arc_time += delta

	# 朝向玩家的方向
	var to_player: Vector2 = _head.global_position.direction_to(player.global_position)

	# 垂直向量，产生弧形摆动
	var perpendicular := Vector2(-to_player.y, to_player.x)
	var swing := sin(_arc_time * arc_frequency) * arc_amplitude
	var target: Vector2 = player.global_position + perpendicular * swing

	var dir: Vector2 = _head.global_position.direction_to(target)
	_head.global_position += dir * chase_speed * delta
	var target_rot := dir.angle() + PI / 2
	_head.rotation = lerp_angle(_head.rotation, target_rot, 5.0 * delta)


func _process_retreating(delta: float) -> void:
	_head.global_position.y -= enter_speed * delta * 1.5
	_head.rotation = 0.0

	var cam := get_viewport().get_camera_2d()
	if cam:
		var half := get_viewport_rect().size.y / 2
		if _head.global_position.y < cam.global_position.y - half - 500.0:
			queue_free()


# === 轨迹系统 ===

func _add_trail_point(pos: Vector2) -> void:
	if _trail_positions.is_empty():
		_trail_positions.append(pos)
		_trail_distances.append(0.0)
	else:
		var last := _trail_positions[-1]
		var dist := last.distance_to(pos)
		if dist > 1.0:
			_trail_positions.append(pos)
			_trail_distances.append(_trail_distances[-1] + dist)


func _get_position_on_trail(distance_from_end: float) -> Vector2:
	if _trail_positions.size() < 2:
		return _head.global_position

	var total := _trail_distances[-1]
	if distance_from_end >= total:
		return _trail_positions[0]

	var target := total - distance_from_end

	# 从尾部向前搜索
	for i in range(_trail_distances.size() - 2, -1, -1):
		if _trail_distances[i] <= target:
			var seg := _trail_distances[i + 1] - _trail_distances[i]
			if seg <= 0.001:
				return _trail_positions[i]
			var t := (target - _trail_distances[i]) / seg
			return _trail_positions[i].lerp(_trail_positions[i + 1], t)

	return _trail_positions[0]


func _update_body_positions() -> void:
	for i in _body_segments.size():
		var follow_dist := head_to_body_spacing + i * body_spacing
		var pos := _get_position_on_trail(follow_dist)
		_body_segments[i].global_position = pos


func _update_body_rotations() -> void:
	var prev_pos := _head.global_position
	for seg in _body_segments:
		var diff := prev_pos - seg.global_position
		if diff.length_squared() > 1.0:
			seg.rotation = diff.angle() + PI / 2
		prev_pos = seg.global_position


func _prune_trail() -> void:
	var max_dist := head_to_body_spacing + _body_segments.size() * body_spacing + body_spacing * 2.0
	if _trail_distances.size() > 2 and _trail_distances[-1] - _trail_distances[0] > max_dist:
		var prune_to := _trail_distances[-1] - max_dist
		var cut := 0
		for i in _trail_distances.size():
			if _trail_distances[i] >= prune_to:
				cut = i
				break
		if cut > 0:
			_trail_positions = _trail_positions.slice(cut)
			_trail_distances = _trail_distances.slice(cut)


# === 身体被摧毁 ===

func _on_body_destroyed(node: MonsterNode) -> void:
	var idx := _body_segments.find(node)
	if idx < 0:
		return
	_body_segments.remove_at(idx)

	# 冻结追击 + 身体更新，Tween 独占位置控制
	var duration := 0.2
	_freeze_timer = duration
	for i in range(idx, _body_segments.size()):
		var target_dist := head_to_body_spacing + i * body_spacing
		var target_pos := _get_position_on_trail(target_dist)
		var tw := create_tween()
		tw.tween_property(_body_segments[i], "global_position", target_pos, duration).set_ease(Tween.EASE_OUT)
		_body_segments[i].z_index = body_count - i

	Debug.Log("Boss: 一节身体被摧毁，剩余 %d 节" % _body_segments.size())

	if _body_segments.is_empty():
		_state = State.RETREATING
		Debug.Log("Boss: 所有身体节点被摧毁，撤退")
