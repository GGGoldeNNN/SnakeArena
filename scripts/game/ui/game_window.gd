extends Control

func _ready() -> void:
	process_mode = PROCESS_MODE_WHEN_PAUSED
	visible = false
	var btn := $Panel/Button as Button
	if btn:
		btn.pressed.connect(_on_restart)

func show_window() -> void:
	visible = true

func _on_restart() -> void:
	Debug.Log("点击了重新开始的按钮")
	get_tree().paused = false
	var err := get_tree().reload_current_scene()
	if err == OK:
		Debug.Log("重新开始")
	else:
		Debug.Log_Warning("重新开始失败")
