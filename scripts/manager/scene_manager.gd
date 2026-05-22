extends Node

## 当前激活的场景
var current_active_scene: Node
## 游戏根节点
var game_root: Node

## 切换场景[br]
## _scene_name: 场景名称
func switch_scenes(_scene_name: String):
	if game_root == null:
		print_debug("SceneManager: 游戏根节点未设置")
		return
	if current_active_scene != null:
		current_active_scene.queue_free()
	var new_scene = GlobalManager.SCENE[_scene_name].instantiate()
	current_active_scene = new_scene
	game_root.add_child(new_scene)
	print("SceneManager: 场景切换至 %s"%_scene_name)
