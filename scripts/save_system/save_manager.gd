## SaveManager 存档管理类单例[br]
## 提供多存档管理功能，每个存档存储在独立文件中
extends Node

## 存档目录路径
const SAVE_PATH: String = "user://saves/"
## 元数据文件名
const META_FILE: String = "save_system_data"
## 存档文件前缀
const SAVE_FILE_PREFIX: String = "save_"
## 存档文件扩展名
const SAVE_EXTENSION: String = ".json"
## 存档版本
const SAVE_VERSION: String = "1.0"

## 当前活动的存档
var _current_item: SaveItem = null
## 存档系统元数据
var _system_data: SaveSystemData = null
## 存档缓存（已加载的存档）
var _loaded_items: Dictionary[int, SaveItem] = {}

func _init() -> void:
	_load_system_data()

func _ready() -> void:
	pass

## 创建新的存档[br]
## save_name: 存档名称
## 返回值: 新创建的存档项
func new_save_data(save_name: String = "") -> SaveItem:
	# 创建新存档项
	var item: SaveItem = SaveItem.new()
	item.save_id = _system_data.curr_id
	_system_data.curr_id += 1
	_system_data.item_ids.append(item.save_id)
	
	# 设置存档名称
	if save_name == "":
		save_name = "新存档 " + str(item.save_id)
	item.save_name = save_name
	
	# 设置时间戳
	item.create_time = int(Time.get_unix_time_from_system())
	item.modify_time = item.create_time
	
	# 设置版本信息
	item.game_version = GameManager.GAME_VERSION
	item.save_version = SAVE_VERSION
	
	# 初始化存档数据结构
	item.save_data = {}
	
	# 缓存并设为当前存档
	_loaded_items[item.save_id] = item
	_current_item = item
	
	# 保存元数据和存档文件
	_save_system_data()
	_save_item(item)
	
	print("SaveManager: 创建新存档 %d" % item.save_id)
	return item

## 将数据保存到当前活动的存档中
## _key: 数据键名
## _value: 数据值
func save_data(_key: String, _value: Variant, _is_write: bool = true) -> void:
	if _current_item == null:
		print("SaveManager: 当前没有活动的存档")
		return
	_current_item.modify_time = int(Time.get_unix_time_from_system())
	_current_item.save_any_data(_key, _value)
	# print("SaveManager: 保存存档 %d" % _current_item.save_id)
	if _is_write:
		_save_item(_current_item)

## 手动保存当前活动的存档到文件
func save_item() -> void:
	_save_item(_current_item)

## 从当前活动的存档中加载数据
## _key: 数据键名
## 返回值: 数据值（如果键不存在则返回null）
func load_data(_key: String) -> Variant:
	return _current_item.load_any_data(_key)

## 加载存档[br]
## save_id: 存档ID
## 返回值: 存档项
func load_save_data(save_id: int) -> SaveItem:
	# 检查缓存
	if _loaded_items.has(save_id):
		_current_item = _loaded_items[save_id]
		return _current_item
	
	# 从文件加载
	var item: SaveItem = _load_item(save_id)
	if item == null:
		print("SaveManager: 加载存档 %d 失败" % save_id)
		return null
	
	_loaded_items[save_id] = item
	_current_item = item
	return item

## 获取当前存档[br]
## 返回值: 当前活动的存档项
func get_current_save() -> SaveItem:
	return _current_item

## 获取所有存档列表（仅元数据）[br]
## 返回值: 存档ID数组
func get_all_save_ids() -> Array[int]:
	return _system_data.item_ids.duplicate()

## 删除存档[br]
## save_id: 存档ID
func delete_save_data(save_id: int) -> void:
	# 从元数据中移除
	_system_data.item_ids.erase(save_id)
	
	# 从缓存中移除
	_loaded_items.erase(save_id)
	
	# 如果删除的是当前存档，清空当前存档
	if _current_item and _current_item.save_id == save_id:
		_current_item = null
	
	# 删除存档文件
	var file_path = _get_item_file_path(save_id)
	if FileAccess.file_exists(file_path):
		DirAccess.remove_absolute(file_path)
	
	# 保存元数据
	_save_system_data()
	print("SaveManager: 删除存档 %d" % save_id)

## 删除所有存档[br]
## 重置存档元数据
func clear_all_save_data() -> void:
	## 删除所有存档文件
	var save_ids = get_all_save_ids()
	for save_id in save_ids:
		delete_save_data(save_id)
	
	## 重置元数据
	_system_data = SaveSystemData.new()
	_save_system_data()
	print("SaveManager: 删除所有存档，重置元数据")
	

#region 私有方法

## 新建子数据
func _new_data(_key: String) -> Variant:
	_current_item.save_data[_key] = null
	return _current_item.save_data[_key]

## 保存存档系统元数据
func _save_system_data() -> void:
	_ensure_save_directory()
	var file_path = _get_meta_file_path()
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if file == null:
		print("SaveManager: 无法保存元数据文件")
		return
	file.store_string(JSON.stringify(_system_data.serialize(), "  "))
	file.close()

## 加载存档系统元数据
func _load_system_data() -> void:
	var file_path = _get_meta_file_path()
	if not FileAccess.file_exists(file_path):
		print("SaveManager: 元数据文件不存在，创建新元数据")
		_system_data = SaveSystemData.new()
		_save_system_data()
		return
	
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		print("SaveManager: 无法打开元数据文件")
		return
	
	var json = JSON.new()
	var error = json.parse(file.get_as_text())
	file.close()
	
	if error != OK:
		print("SaveManager: 元数据解析失败")
		return
		
	_system_data = SaveSystemData.new()
	_system_data.deserialize(json.data)

## 保存单个存档文件
func _save_item(item: SaveItem) -> void:
	_ensure_save_directory()
	var file_path = _get_item_file_path(item.save_id)
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if file == null:
		print("SaveManager: 无法保存存档文件")
		return
	file.store_string(JSON.stringify(item.serialize(), "  "))
	file.close()
	return

## 加载单个存档文件
func _load_item(save_id: int) -> SaveItem:
	var file_path = _get_item_file_path(save_id)
	if not FileAccess.file_exists(file_path):
		print("SaveManager: 存档文件不存在 %s" % file_path)
		return null
	
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		print("SaveManager: 无法打开存档文件")
		return null
	
	var json = JSON.new()
	var error = json.parse(file.get_as_text())
	file.close()
	
	if error != OK:
		print("SaveManager: 存档解析失败")
		return null
	
	var item = SaveItem.new()
	item.deserialize(json.data)
	return item

## 确保存档目录存在
func _ensure_save_directory() -> void:
	var dir = DirAccess.open("user://")
	if dir and not dir.dir_exists("saves"):
		dir.make_dir("saves")

## 获取元数据文件路径
func _get_meta_file_path() -> String:
	return SAVE_PATH + META_FILE + SAVE_EXTENSION

## 获取存档文件路径
func _get_item_file_path(save_id: int) -> String:
	return SAVE_PATH + SAVE_FILE_PREFIX + str(save_id) + SAVE_EXTENSION

#endregion
