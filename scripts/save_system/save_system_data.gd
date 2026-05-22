## SaveSystemData 存档系统元数据[br]
## 只存储存档列表的元信息，实际存档数据存储在单独文件中
class_name SaveSystemData
extends RefCounted

## 当前可用的存档ID
var curr_id: int = 0
## 所有存档ID列表
var item_ids: Array[int] = []

## 序列化元数据[br]
## 返回值: 元数据字典
func serialize() -> Dictionary:
	return {
		"curr_id": curr_id,
		"item_ids": item_ids
	}

## 反序列化元数据[br]
## json: 从文件加载的JSON数据
func deserialize(json: Dictionary) -> void:
	curr_id = json.get("curr_id", 0)
	item_ids.clear()
	for id in json.get("item_ids", []):
		item_ids.append(id)
