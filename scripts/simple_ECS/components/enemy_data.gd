## 敌人数据定义
class_name EnemyData
extends Resource

## 显示名称
@export var display_name: String = "敌人"
## 敌人场景
@export var scene: PackedScene

## === 属性 ===
@export var max_hp: float = 3.0
@export var speed: float = 200.0
@export var score_value: int = 100

## === 移动模式 ===
enum MovePattern { LINEAR, SINE, CHASE, ORBIT }
@export var move_pattern: MovePattern = MovePattern.LINEAR
## 正弦/轨道幅度
@export var amplitude: float = 100.0
## 正弦/轨道频率
@export var frequency: float = 2.0

## === 武器 ===
@export var has_weapon: bool = false
## 子弹数据
@export var bullet_data: BulletData
## 射击间隔（秒）
@export var fire_interval: float = 1.5
## 射击方向（度，0=正下）
@export var fire_angle: float = 90.0
