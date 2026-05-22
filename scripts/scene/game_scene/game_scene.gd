## 游戏主场景
## 管理玩家生成、敌人生成等游戏逻辑
extends Node2D


func _ready() -> void:
	_spawn_player()
	Debug.Log_Success("GameScene: 游戏场景初始化完成")


func _spawn_player() -> void:
	var player_scene := preload("res://scenes/player/player.tscn")
	var player: Player = player_scene.instantiate()
	# 设置飞机大小（64像素宽，等比缩放）
	player.set_width(64)
	# 在 add_child（即 _ready 触发）前先设好位置，相机才能 snap 到正确位置
	var screen_size := get_viewport_rect().size
	var spawn_pos := Vector2(screen_size.x / 2, screen_size.y / 2)
	player.position = spawn_pos
	# 以玩家为中心设置 3000x3000 的世界区域
	player.world_boundary = Rect2(spawn_pos.x - 1500, spawn_pos.y - 1500, 3000, 3000)
	$GameNode.add_child(player)
	Debug.Log("GameScene: 玩家已生成，宽度=%d" % player.width)
	queue_redraw()


func _draw() -> void:
	# 通过分组查找玩家（可能在 GameNode 下）
	var p := get_tree().get_first_node_in_group("player") as Player
	if not p:
		return
	var wb := p.world_boundary
	var l := wb.position.x
	var t := wb.position.y
	var r := wb.position.x + wb.size.x
	var b := wb.position.y + wb.size.y

	# 可移动区域填充
	draw_rect(Rect2(l, t, r - l, b - t), Color(1, 1, 1, 0.06), true)

	# 黑色网格线（3000 可被 100 整除，无半格）
	var grid_col := Color(0, 0, 0, 0.12)
	var grid_step := 100.0
	# 竖线
	var x: float = l + grid_step
	while x < r:
		draw_line(Vector2(x, t), Vector2(x, b), grid_col, 1.0, true)
		x += grid_step
	# 横线
	var y: float = t + grid_step
	while y < b:
		draw_line(Vector2(l, y), Vector2(r, y), grid_col, 1.0, true)
		y += grid_step

	# 四边虚线边框
	var col := Color(0, 0, 0, 0.7)
	var w := 2.0
	draw_dashed_line(Vector2(l, t), Vector2(r, t), col, w, 8.0, 6.0, true)   # 上
	draw_dashed_line(Vector2(r, t), Vector2(r, b), col, w, 8.0, 6.0, true)   # 右
	draw_dashed_line(Vector2(l, b), Vector2(r, b), col, w, 8.0, 6.0, true)   # 下
	draw_dashed_line(Vector2(l, t), Vector2(l, b), col, w, 8.0, 6.0, true)   # 左
