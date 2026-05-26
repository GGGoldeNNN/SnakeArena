extends Node

## 场景字典 - 所有游戏场景在此注册
const SCENE: Dictionary[String, PackedScene] = {
	"main_menu": preload("res://scenes/main_menu/main_menu.tscn"),
	"game_scene": preload("res://scenes/game_scene/game_scene.tscn")
}

## 窗口预制体
const WINDOW: Dictionary[String, PackedScene] = {
	"win": preload("res://scenes/ui/win_window.tscn"),
	"fail": preload("res://scenes/ui/fail_window.tscn")
}

func _ready() -> void:
	Debug.Log("GlobalManager: 初始化完成，已注册 %d 个场景、%d 个窗口" % [SCENE.size(), WINDOW.size()])
