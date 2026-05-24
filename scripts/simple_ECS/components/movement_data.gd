## 移动数据组件（纯数据）
## 存储敌人移动参数，由 MovementSystem 驱动
class_name MovementData
extends Resource

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

## 已运行时间（用于周期性运动）
var time_elapsed: float = 0.0
