## ECS 世界核心
## 实体注册/组件管理/批量查询，全局 Autoload 单例
extends Node

## entity_id → Node
var _entities: Dictionary = {}
## entity_id → {class_name_string : Resource}
var _components: Dictionary = {}
var _next_id: int = 0


## 注册实体，返回 entity_id
func register(node: Node) -> int:
	var eid: int = _next_id
	_next_id += 1
	_entities[eid] = node
	_components[eid] = {}
	node.tree_exiting.connect(_on_entity_exiting.bind(eid))
	return eid


## 注销实体（自动清理）
func unregister(eid: int) -> void:
	_entities.erase(eid)
	_components.erase(eid)


## 为实体添加组件（Resource 纯数据）
func add_component(eid: int, component: Resource) -> void:
	var comps: Dictionary = _components.get(eid) as Dictionary
	if comps != null:
		comps[_class_name(component)] = component


## 获取实体的指定类型组件（传入 class_name，如 HealthData）
func get_component(eid: int, type_script) -> Resource:
	var comps: Dictionary = _components.get(eid) as Dictionary
	if comps == null:
		return null
	var key: String = _key_from_type(type_script)
	return comps.get(key) as Resource


## 实体是否拥有指定组件
func has_component(eid: int, type_script) -> bool:
	return get_component(eid, type_script) != null


## 查询拥有所有指定组件类型的实体 ID 列表
func query_entities(types: Array) -> Array[int]:
	var result: Array[int] = []
	var keys: Array[String] = []
	for t in types:
		keys.append(_key_from_type(t))

	for eid in _entities.keys():
		var comps: Dictionary = _components.get(eid) as Dictionary
		if comps == null:
			continue
		var match_all: bool = true
		for k in keys:
			if not comps.has(k):
				match_all = false
				break
		if match_all:
			result.append(eid)
	return result


## 通过 entity_id 获取实体节点
func get_entity_node(eid: int) -> Node:
	return _entities.get(eid) as Node


func _on_entity_exiting(eid: int) -> void:
	unregister(eid)


# —————— 内部辅助 ——————

## 从 Resource 提取 class_name 字符串
func _class_name(c: Resource) -> String:
	var script := c.get_script() as GDScript
	if script:
		return script.get_global_name()
	return ""


## 将类型参数统一为字符串键
func _key_from_type(t) -> String:
	if t is String:
		return t
	if t is GDScript:
		return t.get_global_name()
	return ""
