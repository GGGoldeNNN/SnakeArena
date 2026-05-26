## 胜利/失败窗口通用脚本
## 控制显示/隐藏和重新开始按钮
extends Control

## 重启时切换的场景名
@export var restart_scene: String = "game_scene"


func _ready() -> void:
	# 默认隐藏，由 GameScene 控制何时显示
	visible = false
	var btn := $Panel/Button as Button
	if btn:
		btn.pressed.connect(_on_restart)


func show_window() -> void:
	visible = true


func _on_restart() -> void:
	get_tree().paused = false
	SceneManager.switch_scenes(restart_scene)
