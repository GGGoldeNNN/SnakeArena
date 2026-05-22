## 生命值组件
## 挂在实体上，管理 HP、受伤、死亡逻辑
class_name HealthComponent
extends Node

signal died
signal damage_taken(amount: float, current_hp: float)

## 最大生命值
@export var max_hp: float = 3.0
## 初始生命值（-1 表示满血）
@export var initial_hp: float = -1.0
## 无敌时间（秒），受伤后短暂无敌
@export var invincible_time: float = 0.5

var current_hp: float
var is_invincible: bool = false
var _invincible_timer: float = 0.0


func _ready() -> void:
	current_hp = initial_hp if initial_hp > 0 else max_hp


func _process(delta: float) -> void:
	if _invincible_timer > 0:
		_invincible_timer -= delta
		if _invincible_timer <= 0:
			is_invincible = false


## 受到伤害
## @return true=还活着, false=已死亡
func take_damage(amount: float) -> bool:
	if is_invincible or current_hp <= 0:
		return current_hp > 0

	current_hp -= amount
	damage_taken.emit(amount, current_hp)

	if current_hp <= 0:
		died.emit()
		return false

	# 进入无敌
	if invincible_time > 0:
		is_invincible = true
		_invincible_timer = invincible_time

	return true


## 回血
func heal(amount: float) -> void:
	current_hp = min(current_hp + amount, max_hp)


## 重置到满血
func reset() -> void:
	current_hp = max_hp
	is_invincible = false
	_invincible_timer = 0.0
