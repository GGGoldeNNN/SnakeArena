## 子弹数据定义
class_name BulletData
extends Resource

## 显示名称
@export var display_name: String = "子弹"
## 子弹场景
@export var scene: PackedScene
## 飞行速度
@export var speed: float = 600.0
## 伤害
@export var damage: float = 1.0
## 存活时间（秒），超时自动回收
@export var lifetime: float = 3.0
## 是否穿透（穿过敌人不消失）
@export var piercing: bool = false
