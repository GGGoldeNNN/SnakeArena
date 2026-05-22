## 玩家飞机
## 惯性移动 + 碰撞检测
class_name Player
extends Area2D

## === 尺寸控制（等比缩放） ===
## 目标宽度（像素），自动等比计算高度
@export var width: float = 64.0

## === 移动参数 ===
@export var acceleration: float = 500.0   # 加速度
@export var friction: float = 150.0        # 摩擦力（减速）
@export var max_speed: float = 500.0       # 最大速度
@export var drag: float = 0.1             # 惯性阻尼（越小越滑）

## === 世界边界（游戏区域） ===
@export var world_boundary: Rect2 = Rect2(0, 0, 3000, 3000)

## === 击退参数 ===
@export var knockback_force: float = 500.0    # 击退力度
@export var knockback_stun: float = 0.35       # 失控时间（秒）

## 当前速度向量
var velocity: Vector2 = Vector2.ZERO

## 击退失控计时
var _stun_timer: float = 0.0


func _ready() -> void:
	add_to_group("player")
	_update_scale()
	# 相机跳过首帧平滑过渡
	var cam: Camera2D = $Camera2D
	if cam:
		cam.reset_smoothing()
	Debug.Log_Success("Player: 玩家飞机初始化完成")


func _process(delta: float) -> void:
	if _stun_timer > 0:
		_stun_timer -= delta  # 失控倒计时，不处理输入
	else:
		_handle_input(delta)
	_apply_movement(delta)
	_clamp_to_screen()


## 根据目标宽度等比缩放
func _update_scale() -> void:
	var sprite: Sprite2D = $Sprite
	if sprite and sprite.texture:
		var tex_width := sprite.texture.get_width()
		if tex_width > 0 and width < tex_width:
			var ratio := width / tex_width
			sprite.scale = Vector2(ratio, ratio)
			# 同步阴影
			var shadow: Sprite2D = $Shadow
			if shadow:
				shadow.scale = Vector2(ratio, ratio)


## 外部设置尺寸（用于生成时动态指定）
func set_width(pixels: float) -> void:
	width = pixels
	_update_scale()


## 处理输入 - 惯性移动
func _handle_input(delta: float) -> void:
	var input_dir: Vector2 = Vector2.ZERO

	# 键盘输入
	if Input.is_action_pressed("ui_right") or Input.is_key_pressed(KEY_D):
		input_dir.x += 1
	if Input.is_action_pressed("ui_left") or Input.is_key_pressed(KEY_A):
		input_dir.x -= 1
	if Input.is_action_pressed("ui_down") or Input.is_key_pressed(KEY_S):
		input_dir.y += 1
	if Input.is_action_pressed("ui_up") or Input.is_key_pressed(KEY_W):
		input_dir.y -= 1

	# 归一化对角线速度
	if input_dir.length() > 0:
		input_dir = input_dir.normalized()
		# 加速
		velocity += input_dir * acceleration * delta
		# 限速
		if velocity.length() > max_speed:
			velocity = velocity.normalized() * max_speed
	else:
		# 无输入时：摩擦力减速
		var speed := velocity.length()
		if speed > 0:
			var friction_amount := friction * delta
			if speed > friction_amount:
				velocity = velocity.normalized() * (speed - friction_amount)
			else:
				velocity = Vector2.ZERO


## 应用移动
func _apply_movement(_delta: float) -> void:
	position += velocity * _delta
	# 锁定整数像素坐标，消除子像素闪烁
	position = position.round()


## 限制在世界边界内（碰墙触发击退）
func _clamp_to_screen() -> void:
	var b := world_boundary
	var bx := b.position.x
	var by := b.position.y
	var br := b.position.x + b.size.x
	var bb := b.position.y + b.size.y

	var hit_wall := false
	var bounce_dir := velocity  # 基于当前速度方向做镜面反射

	if position.x < bx:
		position.x = bx
		bounce_dir.x = -bounce_dir.x
		hit_wall = true
	elif position.x > br:
		position.x = br
		bounce_dir.x = -bounce_dir.x
		hit_wall = true

	if position.y < by:
		position.y = by
		bounce_dir.y = -bounce_dir.y
		hit_wall = true
	elif position.y > bb:
		position.y = bb
		bounce_dir.y = -bounce_dir.y
		hit_wall = true

	if hit_wall and bounce_dir.length_squared() > 0:
		_apply_knockback(bounce_dir.normalized())


## 击退（来自碰撞体位置）
func knockback(from_position: Vector2) -> void:
	_apply_knockback((global_position - from_position).normalized())

## 击退（指定方向）
func knockback_dir(dir: Vector2) -> void:
	_apply_knockback(dir)

## 击退核心逻辑
func _apply_knockback(dir: Vector2) -> void:
	velocity = dir * knockback_force
	_stun_timer = knockback_stun
	take_damage()
	Debug.Log("Player: 击退，方向=%s 失控 %.2f 秒" % [str(dir), knockback_stun])


## 被击中时调用（扣血等逻辑）
func take_damage() -> void:
	Debug.Log("Player: 受到伤害")
	# TODO: 减血、闪烁、无敌帧等


## 碰撞检测 - 进入区域
func _on_area_entered(area: Area2D) -> void:
	Debug.Log("Player: 碰撞到 " + area.name)
	knockback(area.global_position)


## 碰撞检测 - 进入物体
func _on_body_entered(body: Node2D) -> void:
	Debug.Log("Player: 碰撞到 " + body.name)
	knockback(body.global_position)
