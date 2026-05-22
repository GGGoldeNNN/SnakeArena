## 游戏根节点脚本
## 作为整个游戏的入口，初始化管理器系统并切换到首页
extends Node


func _ready() -> void:
	# 将自身注册为场景管理器的根节点
	SceneManager.game_root = self
	# 切换到游戏场景（开发模式，直接进游戏）
	SceneManager.switch_scenes("game_scene")
	Debug.Log_Success("GameRoot: 游戏根节点初始化完成")
