## 子弹管理器
## 管理玩家子弹和敌人子弹的对象池，挂载在 GameNode 下
class_name BulletManager
extends Node

## 玩家子弹池
var _player_pool: ObjectPool
## 敌人子弹池
var _enemy_pool: ObjectPool

var _initialized: bool = false
var _player_bullet_root: Node
var _enemy_bullet_root: Node


func _ready() -> void:
	_player_bullet_root = self
	_enemy_bullet_root = self


## 初始化池子
## @param player_bullet_scene  玩家子弹场景
## @param enemy_bullet_scene   敌人子弹场景
## @param prewarm              每种子弹预创建数量
func initialize(player_bullet_scene: PackedScene, enemy_bullet_scene: PackedScene, prewarm: int = 50) -> void:
	_player_pool = ObjectPool.new(player_bullet_scene, _player_bullet_root, prewarm)
	_enemy_pool = ObjectPool.new(enemy_bullet_scene, _enemy_bullet_root, prewarm)
	_initialized = true


## 生成一颗玩家子弹
func spawn_player_bullet(data: BulletData) -> Bullet:
	if not _initialized or not _player_pool:
		return null
	var bullet := _player_pool.acquire() as Bullet
	if bullet:
		bullet._manager = self
		bullet.speed = data.speed
		bullet.max_distance = data.speed * data.lifetime
	return bullet


## 生成一颗敌人子弹
func spawn_enemy_bullet(_data: BulletData) -> Node2D:
	if not _initialized or not _enemy_pool:
		return null
	return _enemy_pool.acquire() as Node2D


## 回收子弹
func release_bullet(bullet: Node2D, is_player: bool) -> void:
	if is_player:
		_player_pool.release(bullet)
	else:
		_enemy_pool.release(bullet)
