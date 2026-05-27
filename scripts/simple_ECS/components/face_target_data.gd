## 朝向目标组件（纯数据）
## 存储追踪目标组和角度偏移，由 FaceTargetSystem 驱动
class_name FaceTargetData
extends Resource

## 要追踪的目标组名
@export var target_group: String = "player"
## 角度偏移（弧度），默认 PI/2 适配"上方为头部"的精灵
@export var offset_angle: float = PI / 2
