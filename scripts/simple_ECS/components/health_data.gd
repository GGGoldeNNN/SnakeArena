## 生命值组件（纯数据）
## 存储 HP、无敌状态，由 HealthSystem 驱动
class_name HealthData
extends Resource

## 最大生命值
@export var max_hp: float = 3.0
## 无敌时间（秒），受伤后短暂无敌
@export var invincible_time: float = 0.5

## 当前生命值
var current_hp: float
## 无敌计时器
var invincible_timer: float = 0.0
## 是否已死亡（避免重复处理）
var is_dead: bool = false


## 受到伤害，返回 true 表示还活着
func take_damage(amount: float) -> bool:
	if invincible_timer > 0 or is_dead:
		return current_hp > 0

	current_hp -= amount
	if current_hp <= 0:
		is_dead = true
		return false

	if invincible_time > 0:
		invincible_timer = invincible_time
	return true


## 回血
func heal(amount: float) -> void:
	current_hp = min(current_hp + amount, max_hp)


## 重置到满血
func reset() -> void:
	current_hp = max_hp
	invincible_timer = 0.0
	is_dead = false
