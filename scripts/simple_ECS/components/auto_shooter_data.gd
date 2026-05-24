## 自动瞄准射击数据组件（纯数据）
## 存储玩家自动瞄准/射击参数，由 AutoShootSystem 驱动
class_name AutoShooterData
extends Resource

## 攻击范围（像素）
@export var range: float = 500.0
## 攻击间隔（秒）
@export var cooldown: float = 0.25
## 子弹速度
@export var bullet_speed: float = 800.0
## 子弹伤害
@export var bullet_damage: float = 1.0
## 子弹最大飞行距离
@export var bullet_max_distance: float = 3000.0

## 攻击计时器
var attack_timer: float = 0.0
