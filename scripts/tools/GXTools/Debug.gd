## 调试工具[br]
## 提供打印日志的功能
extends Node
class_name Debug

const IS_OPEN: bool = true

## 打印普通日志[br]
## content: 日志内容
static func Log(content: String):
	if !IS_OPEN:
		return
	print(content)

## 打印成功日志[br]
## 颜色: 绿色
## content: 日志内容
static func Log_Success(content: String):
	if !IS_OPEN:
		return
	content = "[color=#00FF00]" + content + "[/color]"
	print_rich(content)

## 打印错误日志[br]
## 颜色: 红色
## content: 日志内容
static func Log_Error(content: String):
	if !IS_OPEN:
		return
	content = "[color=#FF0000]" + content + "[/color]"
	print_rich(content)

## 打印警告日志[br]
## 颜色: 黄色
## content: 日志内容
static func Log_Warning(content: String):
	if !IS_OPEN:
		return
	content = "[color=#FFFF00]" + content + "[/color]"
	print_rich(content)

## 打印错误日志并强行停止游戏[br]
## 颜色: 红色
## content: 日志内容
static func Log_Error_Stop(content: String):
	if !IS_OPEN:
		return
	content = "❌❌❌" + "[color=#FF0000]" + content + "[/color]"
	print_rich(content)
	Engine.get_main_loop().quit(1) # 停止游戏
