## 射击数据组件（纯数据）
## 存储敌人射击参数，由 ShooterSystem 驱动
class_name ShooterData
extends Resource

## 射击间隔（秒）
@export var fire_interval: float = 1.5
## 射击方向（度，0=右, 90=下）
@export var fire_angle: float = 90.0
## 子弹数据
@export var bullet_data: BulletData
## 散弹数量
@export var spread_count: int = 1
## 散弹扩散角（度）
@export var spread_angle: float = 0.0

## 射击计时器
var fire_timer: float = 0.0
## 是否启用射击
var enabled: bool = false
