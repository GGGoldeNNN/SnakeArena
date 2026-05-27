extends Node

# 音频目录路径
const AUDIO_DIR: String = "res://assets/audio/"

# 支持的音频格式
const AUDIO_EXTENSIONS: Array[String] = [".wav", ".mp3", ".ogg"]

# 音效播放器池
var _sfx_pool: Array[AudioStreamPlayer] = [] # 音效播放器池
var _sfx_pool_size: int = 20 # 音效播放器池大小（同时播放上限）
var _active_sfx_count: int = 0 # 当前活跃的音效数量

# 背景音乐播放器（单一实例）
var _bgm_player: AudioStreamPlayer = null

# 音量设置
var _master_volume: float = 1.0 # 主音量 (0.0 - 1.0)
var _sfx_volume: float = 1.0 # 音效音量 (0.0 - 1.0)
var _bgm_volume: float = 1.0 # 背景音乐音量 (0.0 - 1.0)

# 点击音效开关状态
var _click_sound_enabled: bool = false # 默认为关

# 音效字典 - 存储所有音效资源
var _audio_dict: Dictionary = {}


func _ready() -> void:
	# 创建音效播放器池
	_create_sfx_pool()
	
	# 创建背景音乐播放器
	_bgm_player = AudioStreamPlayer.new()
	_bgm_player.name = "BGMPlayer"
	add_child(_bgm_player)
	
	# 设置初始音量
	_update_volumes()
	
	# 自动加载音频目录下的所有音频文件
	_load_audio_from_directory()
	
	Debug.Log_Success("AudioManager: 音频管理器初始化完成，共加载 %d 个音频文件，音效池大小: %d" % [_audio_dict.size(), _sfx_pool_size])


## 全局输入监听 - 检测点击事件播放音效
func _input(event: InputEvent) -> void:
	# 检测点击事件
	if _click_sound_enabled and event.is_action_pressed("click"):
		# 如果点击音效开关开启，播放音效
		play_sfx("鼠标点击音效")


## 创建音效播放器池
func _create_sfx_pool() -> void:
	for i in range(_sfx_pool_size):
		var player: AudioStreamPlayer = AudioStreamPlayer.new()
		player.name = "SFXPlayer_%d" % i
		# 连接播放完成信号，用于回收播放器
		player.finished.connect(_on_sfx_finished.bind(player))
		add_child(player)
		_sfx_pool.append(player)
	
	Debug.Log("AudioManager: 创建音效播放器池，大小: %d" % _sfx_pool_size)


## 音效播放完成回调
func _on_sfx_finished(_player: AudioStreamPlayer) -> void:
	# 减少活跃音效计数
	_active_sfx_count = max(0, _active_sfx_count - 1)
	# Debug.Log("AudioManager: 音效播放完成，当前活跃音效数: %d/%d" % [_active_sfx_count, _sfx_pool_size])


## 从音频目录加载所有音频文件（包括子目录）
func _load_audio_from_directory() -> void:
	# 递归加载音频目录及其子目录
	_load_audio_from_directory_recursive(AUDIO_DIR)


## 递归加载目录及其子目录中的音频文件
func _load_audio_from_directory_recursive(dir_path: String) -> void:
	var dir := DirAccess.open(dir_path)
	if not dir:
		Debug.Log_Error("AudioManager: 无法打开目录 - " + dir_path)
		return

	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		if file_name.begins_with("."):
			file_name = dir.get_next()
			continue

		var full_path := dir_path.path_join(file_name)
		if dir.current_is_dir():
			_load_audio_from_directory_recursive(full_path + "/")
		elif _is_audio_file(file_name):
			_load_audio_file(full_path)

		file_name = dir.get_next()
	dir.list_dir_end()


## 检查文件是否是音频文件
func _is_audio_file(file_name: String) -> bool:
	var extension: String = file_name.get_extension().to_lower()
	var full_extension: String = "." + extension
	return full_extension in AUDIO_EXTENSIONS


## 加载单个音频文件
func _load_audio_file(file_path: String) -> void:
	# 从完整路径中提取文件名（不含扩展名）作为key
	var file_name: String = file_path.get_file()
	var audio_name: String = file_name.get_basename()
	
	# 加载音频资源
	var audio_stream: AudioStream = load(file_path)
	
	# 检查是否加载成功
	if audio_stream == null:
		Debug.Log_Error("AudioManager: 无法加载音频文件 - " + file_path)
		return
	
	# 添加到音频字典
	_audio_dict[audio_name] = audio_stream
	Debug.Log("AudioManager: 加载音频 - %s (路径: %s)" % [audio_name, file_path])


## 播放音效（通过名称）
func play_sfx(audio_name: String) -> AudioStreamPlayer:
	# 检查音效是否存在
	if not _audio_dict.has(audio_name):
		Debug.Log_Error("AudioManager: 未找到音效 - " + audio_name)
		return null
	
	# 获取音效资源
	var audio_stream: AudioStream = _audio_dict[audio_name]
	
	# 播放音效
	return _play_sfx_stream(audio_stream, audio_name)


## 播放音效（直接传入音频资源）
func play_sfx_stream(audio_stream: AudioStream) -> AudioStreamPlayer:
	if audio_stream == null:
		Debug.Log_Error("AudioManager: 音频资源为空")
		return null
	
	return _play_sfx_stream(audio_stream, "unknown")


## 内部方法：播放音效流
func _play_sfx_stream(audio_stream: AudioStream, audio_name: String) -> AudioStreamPlayer:
	# 查找空闲的播放器
	var player: AudioStreamPlayer = _get_available_player()
	
	if player == null:
		Debug.Log_Warning("AudioManager: 音效池已满，无法播放音效 - %s (活跃: %d/%d)" % [audio_name, _active_sfx_count, _sfx_pool_size])
		return null
	
	# 设置音频流
	player.stream = audio_stream
	
	# 设置音量
	player.volume_db = linear_to_db(_master_volume * _sfx_volume)
	
	# 播放
	player.play()
	
	# 增加活跃音效计数
	_active_sfx_count += 1
	
	# Debug.Log("AudioManager: 播放音效 - %s (活跃: %d/%d)" % [audio_name, _active_sfx_count, _sfx_pool_size])
	
	return player


## 获取可用的播放器
func _get_available_player() -> AudioStreamPlayer:
	# 遍历播放器池，查找空闲的播放器
	for player in _sfx_pool:
		if not player.playing:
			return player
	
	# 所有播放器都在使用，返回null
	return null


## 播放背景音乐（通过名称）
func play_bgm(audio_name: String, loop: bool = true) -> void:
	# 检查音效是否存在
	if not _audio_dict.has(audio_name):
		Debug.Log_Error("AudioManager: 未找到背景音乐 - " + audio_name)
		return
	
	# 获取音频资源
	var audio_stream: AudioStream = _audio_dict[audio_name]
	
	# 设置循环播放
	if audio_stream is AudioStreamMP3:
		audio_stream.loop = loop
	
	# 播放背景音乐
	_bgm_player.stream = audio_stream
	_bgm_player.play()
	
	Debug.Log("AudioManager: 播放背景音乐 - " + audio_name)


## 停止背景音乐
func stop_bgm() -> void:
	_bgm_player.stop()


## 停止所有音效
func stop_all_sfx() -> void:
	for player in _sfx_pool:
		if player.playing:
			player.stop()
	_active_sfx_count = 0
	Debug.Log("AudioManager: 停止所有音效")


## 停止所有音频（包括背景音乐）
func stop_all() -> void:
	stop_all_sfx()
	stop_bgm()
	Debug.Log("AudioManager: 停止所有音频")


## 设置主音量
func set_master_volume(volume: float) -> void:
	_master_volume = clamp(volume, 0.0, 1.0)
	_update_volumes()


## 设置音效音量
func set_sfx_volume(volume: float) -> void:
	_sfx_volume = clamp(volume, 0.0, 1.0)
	_update_volumes()


## 设置背景音乐音量
func set_bgm_volume(volume: float) -> void:
	_bgm_volume = clamp(volume, 0.0, 1.0)
	_update_volumes()


## 更新音量设置
func _update_volumes() -> void:
	# 更新背景音乐音量
	_bgm_player.volume_db = linear_to_db(_master_volume * _bgm_volume)
	
	# 更新所有音效播放器的音量
	for player in _sfx_pool:
		player.volume_db = linear_to_db(_master_volume * _sfx_volume)


## 设置音效池大小（需要在_ready之前调用，或手动重新初始化）
func set_sfx_pool_size(size: int) -> void:
	_sfx_pool_size = max(1, size)
	Debug.Log("AudioManager: 设置音效池大小为 %d" % _sfx_pool_size)


## 添加新的音效到字典
func add_audio(audio_name: String, audio_stream: AudioStream) -> void:
	if audio_stream == null:
		Debug.Log_Error("AudioManager: 无法添加空音频资源")
		return
	
	_audio_dict[audio_name] = audio_stream
	Debug.Log("AudioManager: 添加音效 - " + audio_name)


## 检查音效是否存在
func has_audio(audio_name: String) -> bool:
	return _audio_dict.has(audio_name)


## 获取所有已加载的音频名称列表
func get_all_audio_names() -> Array[String]:
	return _audio_dict.keys()


## 获取当前主音量
func get_master_volume() -> float:
	return _master_volume


## 获取当前音效音量
func get_sfx_volume() -> float:
	return _sfx_volume


## 获取当前背景音乐音量
func get_bgm_volume() -> float:
	return _bgm_volume


## 获取当前活跃音效数量
func get_active_sfx_count() -> int:
	return _active_sfx_count


## 获取音效池大小
func get_sfx_pool_size() -> int:
	return _sfx_pool_size


## 切换点击音效开关
func toggle_click_sound() -> bool:
	_click_sound_enabled = not _click_sound_enabled
	Debug.Log("AudioManager: 点击音效开关已%s" % ["开启" if _click_sound_enabled else "关闭"])
	return _click_sound_enabled


## 设置点击音效开关状态
func set_click_sound_enabled(enabled: bool) -> void:
	_click_sound_enabled = enabled
	Debug.Log("AudioManager: 点击音效开关已%s" % ["开启" if _click_sound_enabled else "关闭"])


## 获取点击音效开关状态
func is_click_sound_enabled() -> bool:
	return _click_sound_enabled
