## 玩家移动数据组件（纯数据）
## 存储玩家移动/击退参数，由 PlayerMovementSystem 驱动
class_name PlayerMovementData
extends Resource

## 加速度
@export var acceleration: float = 500.0
## 摩擦力（减速）
@export var friction: float = 150.0
## 最大速度
@export var max_speed: float = 500.0
## 世界边界
@export var world_boundary: Rect2 = Rect2(0, 0, 3000, 3000)
## 击退力度
@export var knockback_force: float = 500.0
## 失控时间（秒）
@export var knockback_stun: float = 0.35

## 当前速度
var velocity: Vector2 = Vector2.ZERO
## 击退失控计时
var stun_timer: float = 0.0


## 击退（来自碰撞体位置）
func apply_knockback(from_position: Vector2, node_position: Vector2) -> void:
	var dir := (node_position - from_position).normalized()
	velocity = dir * knockback_force
	stun_timer = knockback_stun
