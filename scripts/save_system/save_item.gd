## 单个存档
class_name SaveItem
extends RefCounted

## 存档ID
var save_id: int = 0
## 存档名称
var save_name: String = "新存档"
## 创建时间
var create_time: int = 0
## 修改时间
var modify_time: int = 0
## 游戏版本
var game_version: String = ""
## 存档版本
var save_version: String = "1.0"
## 游戏数据
var save_data: Dictionary = {}

## 序列化存档数据[br]
## 返回值: 存档数据字典
func serialize() -> Dictionary:
	return {
		"save_id": save_id,
		"save_name": save_name,
		"create_time": create_time,
		"modify_time": modify_time,
		"game_version": game_version,
		"save_version": save_version,
		"save_data": save_data
	}
## 反序列化存档数据[br]
## json: 从文件加载的JSON数据
func deserialize(json: Dictionary) -> void:
	save_id = json.get("save_id", 0)
	save_name = json.get("save_name", "新存档")
	create_time = json.get("create_time", 0)
	modify_time = json.get("modify_time", 0)
	game_version = json.get("game_version", "")
	save_version = json.get("save_version", "1.0")
	save_data = json.get("save_data", {})

## 将数据保存到当前活动的存档中
## _key: 数据键名
## _value: 数据值
func save_any_data(_key: String, _value: Variant) -> void:
	# 检查键是否存在
	if save_data.has(_key):
		var existing_value = save_data[_key]
		var existing_type = typeof(existing_value)
		var new_type = typeof(_value)
		
		# 如果现有值是字典，新值也是字典，则合并更新
		if existing_type == TYPE_DICTIONARY and new_type == TYPE_DICTIONARY:
			_merge_dictionary(existing_value, _value)
		# 如果现有值是数组，新值也是数组，则合并更新
		elif existing_type == TYPE_ARRAY and new_type == TYPE_ARRAY:
			_merge_array(existing_value, _value)
		else:
			# 其他情况直接赋值
			save_data[_key] = _value
	else:
		# 键不存在，直接赋值
		save_data[_key] = _value

## 加载数据从当前活动的存档中
## _key: 数据键名
## 返回值: 数据值（如果键不存在则返回null）
func load_any_data(_key: String) -> Variant:
	return save_data.get(_key, null)


## 合并字典（递归更新）
func _merge_dictionary(target: Dictionary, source: Dictionary) -> void:
	for key in source.keys():
		if target.has(key):
			var target_type = typeof(target[key])
			var source_type = typeof(source[key])
			# 如果都是字典，递归合并
			if target_type == TYPE_DICTIONARY and source_type == TYPE_DICTIONARY:
				_merge_dictionary(target[key], source[key])
			# 如果都是数组，合并数组
			elif target_type == TYPE_ARRAY and source_type == TYPE_ARRAY:
				_merge_array(target[key], source[key])
			else:
				target[key] = source[key]
		else:
			target[key] = source[key]


## 合并数组
func _merge_array(target: Array, source: Array) -> void:
	# 清空原数组并添加新元素
	target.clear()
	target.append_array(source)
