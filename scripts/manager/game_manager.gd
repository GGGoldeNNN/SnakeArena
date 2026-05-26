## 游戏状态管理器
## 统一管理游戏状态（进行中/胜利/失败）、窗口弹出、暂停
extends Node

const GAME_VERSION: String = "0.0.1"

enum State { PLAYING, WON, LOST }

## 当前游戏状态
var state: int = State.PLAYING


func _ready() -> void:
	SignalManager.boss_defeated.connect(_on_boss_defeated)
	SignalManager.player_died.connect(_on_player_died)
	Debug.Log("GameManager: 初始化完成（版本 %s）" % GAME_VERSION)


func _on_boss_defeated() -> void:
	if state != State.PLAYING:
		return
	state = State.WON
	Debug.Log_Success("GameManager: Boss 被击败，弹出胜利窗口")
	_pause_game()
	_show_window(GlobalManager.WINDOW.win)


func _on_player_died() -> void:
	if state != State.PLAYING:
		return
	state = State.LOST
	Debug.Log("GameManager: 玩家死亡，弹出失败窗口")
	_pause_game()
	_show_window(GlobalManager.WINDOW.fail)


func _pause_game() -> void:
	get_tree().paused = true


func _show_window(window_scene: PackedScene) -> void:
	var window = window_scene.instantiate()
	var game_scene = get_tree().root.find_child("GameScene", true, false)
	if game_scene:
		var game_ui := game_scene.get_node("GameUI") as CanvasLayer
		if game_ui:
			game_ui.add_child(window)
			window.show_window()
