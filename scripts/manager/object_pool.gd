## 通用对象池
## 管理可复用对象的获取与归还，避免频繁创建/销毁
class_name ObjectPool
extends RefCounted

## 池中缓存的空闲对象
var _pool: Array[Node] = []
## 对象原型场景
var _scene: PackedScene
## 挂载父节点（所有池对象都挂在此节点下）
var _parent: Node
## 池是否自动扩容（acquire 时无空闲对象则创建新的）
var auto_grow: bool = true


## 创建对象池
## @param scene     对象场景（PackedScene）
## @param parent    挂载父节点
## @param prewarm   预创建数量
func _init(scene: PackedScene, parent: Node, prewarm: int = 0) -> void:
	_scene = scene
	_parent = parent
	for i in prewarm:
		var obj := _create()
		_deactivate(obj)
		_pool.append(obj)


## 从池中获取一个对象
## 返回空闲对象，自动激活并调用其 reset() 方法（如果存在）
func acquire() -> Node:
	var obj: Node
	if _pool.is_empty():
		if auto_grow:
			obj = _create()
		else:
			push_error("ObjectPool: 对象池已耗尽，auto_grow=false")
			return null
	else:
		obj = _pool.pop_back()

	_activate(obj)
	if obj.has_method("reset"):
		obj.reset()
	return obj


## 将对象归还池中
func release(obj: Node) -> void:
	if not obj:
		return
	_deactivate(obj)
	if obj.get_parent() != _parent:
		obj.get_parent().remove_child(obj)
		_parent.add_child(obj)
	_pool.append(obj)


## 预创建对象
func prewarm(count: int) -> void:
	for i in count:
		var obj := _create()
		_deactivate(obj)
		_pool.append(obj)


## 池中空闲对象数量
func get_free_count() -> int:
	return _pool.size()


## 总创建数（空闲 + 使用中）
var _total_created: int = 0
func get_total_created() -> int:
	return _total_created


## —————— 内部方法 ——————

func _create() -> Node:
	var obj := _scene.instantiate()
	_parent.add_child(obj)
	_total_created += 1
	return obj


func _activate(obj: Node) -> void:
	obj.set_process(true)
	obj.set_physics_process(true)
	obj.process_mode = Node.PROCESS_MODE_INHERIT
	if obj is CanvasItem:
		obj.visible = true


func _deactivate(obj: Node) -> void:
	obj.set_process(false)
	obj.set_physics_process(false)
	obj.process_mode = Node.PROCESS_MODE_DISABLED
	if obj is CanvasItem:
		obj.visible = false
	# 移出屏幕，避免 PhysicsServer 残留检测
	if obj is Node2D:
		obj.position = Vector2(-9999, -9999)
