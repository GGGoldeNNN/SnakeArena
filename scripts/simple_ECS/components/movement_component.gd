## 移动模式组件
## 控制实体按预设模式运动
class_name MovementComponent
extends Node

## 移动模式
enum Pattern { LINEAR, SINE, CHASE, ORBIT, STOP }

## 当前模式
@export var pattern: Pattern = Pattern.LINEAR
## 移动速度
@export var speed: float = 200.0
## 移动方向（弧度，0=右，PI/2=下）
@export var direction: float = PI / 2
## 正弦/轨道幅度
@export var amplitude: float = 100.0
## 正弦/轨道频率
@export var frequency: float = 2.0

var _time: float = 0.0
var _parent: Node2D
var _target: Node2D  # 追击目标（CHASE 模式用）


func _ready() -> void:
	_parent = owner if owner is Node2D else get_parent()
	# 尝试自动寻找玩家作为追击目标
	if pattern == Pattern.CHASE:
		_target = get_tree().get_first_node_in_group("player")


## 每帧更新移动
func apply(delta: float) -> Vector2:
	if not _parent or pattern == Pattern.STOP:
		return Vector2.ZERO

	_time += delta
	var move_vec := Vector2.ZERO

	match pattern:
		Pattern.LINEAR:
			move_vec = Vector2(cos(direction), sin(direction)) * speed

		Pattern.SINE:
			var base := Vector2(cos(direction), sin(direction)) * speed
			var perp := Vector2(-sin(direction), cos(direction))
			var osc := perp * sin(_time * frequency * TAU) * amplitude * frequency
			move_vec = base + osc

		Pattern.CHASE:
			if _target and is_instance_valid(_target):
				var dir := (_target.global_position - _parent.global_position).normalized()
				move_vec = dir * speed
			else:
				move_vec = Vector2.DOWN * speed

		Pattern.ORBIT:
			var center := _parent.global_position
			var angle := _time * frequency * TAU
			var offset := Vector2(cos(angle), sin(angle)) * amplitude
			move_vec = (offset - _parent.global_position + center).normalized() * speed

	return move_vec * delta


## 设置追击目标
func set_target(node: Node2D) -> void:
	_target = node


## 重置
func reset() -> void:
	_time = 0.0
	if pattern == Pattern.CHASE:
		_target = get_tree().get_first_node_in_group("player")
