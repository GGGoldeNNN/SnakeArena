## 调试工具[br]
## 提供打印日志的功能
extends Node
class_name Debug

const IS_OPEN: bool = true

## 打印普通日志[br]
## _content: 日志内容
static func Log(_content: String):
	if !IS_OPEN:
		return
	print(_content)

## 打印成功日志[br]
## 颜色: 绿色
## _content: 日志内容
static func Log_Success(_content: String):
	if !IS_OPEN:
		return
	_content = "[color=#00FF00]" + _content + "[/color]"
	print_rich(_content)

## 打印错误日志[br]
## 颜色: 红色
## _content: 日志内容
static func Log_Error(_content: String):
	if !IS_OPEN:
		return
	_content = "[color=#FF0000]" + _content + "[/color]"
	print_rich(_content)

## 打印警告日志[br]
## 颜色: 黄色
## _content: 日志内容
static func Log_Warning(_content: String):
	if !IS_OPEN:
		return
	_content = "[color=#FFFF00]" + _content + "[/color]"
	print_rich(_content)

## 打印错误日志并强行停止游戏[br]
## 颜色: 红色
## _content: 日志内容
static func Log_Error_Stop(_content: String):
	if !IS_OPEN:
		return
	_content = "❌❌❌" + "[color=#FF0000]" + _content + "[/color]"
	print_rich(_content)
	Engine.get_main_loop().quit(1) # 停止游戏
