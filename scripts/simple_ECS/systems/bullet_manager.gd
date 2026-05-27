## 子弹管理器
## 管理玩家子弹和敌人子弹的对象池，挂载在 GameNode 下
class_name BulletManager
extends Node

const _OPool = preload("res://scripts/manager/object_pool.gd")
const _BulletData = preload("res://scripts/simple_ECS/components/bullet_data.gd")
const _HitSparkScene = preload("res://scenes/effects/hit_spark.tscn")
const _RingEffectScene = preload("res://scenes/effects/ring_effect.tscn")

## 玩家子弹池
var _player_pool
## 敌人子弹池
var _enemy_pool
## 命中火花池
var _hit_spark_pool: ObjectPool
## 环形特效池（传送门 / 死亡线圈）
var _ring_effect_pool: ObjectPool

var _initialized: bool = false
var _player_bullet_root: Node
var _enemy_bullet_root: Node


func _ready() -> void:
	_player_bullet_root = self
	_enemy_bullet_root = self
	_hit_spark_pool = ObjectPool.new(_HitSparkScene, self, 10)
	_ring_effect_pool = ObjectPool.new(_RingEffectScene, self, 5)


## 初始化池子
## @param player_bullet_scene  玩家子弹场景
## @param enemy_bullet_scene   敌人子弹场景
## @param prewarm              每种子弹预创建数量
func initialize(player_bullet_scene: PackedScene, enemy_bullet_scene: PackedScene, prewarm: int = 50) -> void:
	_player_pool = _OPool.new(player_bullet_scene, _player_bullet_root, prewarm)
	_enemy_pool = _OPool.new(enemy_bullet_scene, _enemy_bullet_root, prewarm)
	_initialized = true


## 生成一颗玩家子弹（collision_layer=1，mask=2 → 命中 Layer 2 的敌人）
func spawn_player_bullet(data: Resource) -> Node2D:
	if not _initialized or not _player_pool:
		return null
	var bullet := _player_pool.acquire() as Node2D
	if bullet:
		bullet._manager = self
		bullet.speed = data.speed
		bullet.max_distance = data.speed * data.lifetime
		bullet.collision_layer = 1
		bullet.collision_mask = 2
	return bullet


## 生成一颗敌人子弹（collision_layer=4=Layer 3，mask=1 → 命中 Layer 1 的玩家）
func spawn_enemy_bullet(data: Resource) -> Node2D:
	if not _initialized or not _enemy_pool:
		return null
	var bullet := _enemy_pool.acquire() as Node2D
	if bullet:
		bullet._manager = self
		bullet.is_from_player = false
		bullet.collision_layer = 4
		bullet.collision_mask = 1
		if data:
			bullet.speed = data.speed
			bullet.max_distance = data.speed * data.lifetime
	return bullet


## 回收子弹
func release_bullet(bullet: Node2D, is_player: bool) -> void:
	if is_player:
		_player_pool.release(bullet)
	else:
		_enemy_pool.release(bullet)


## 在指定位置生成命中火花
func spawn_hit_spark(pos: Vector2) -> void:
	var spark := _hit_spark_pool.acquire() as HitSpark
	if spark:
		spark.pool = _hit_spark_pool
		spark.play(pos)


## 在指定位置生成传送门效果（敌人生成）
func spawn_portal_effect(pos: Vector2, color: Color = Color(0.3, 0.7, 1.0, 0.8), max_radius: float = 60.0, duration: float = 0.4) -> void:
	var ring := _ring_effect_pool.acquire() as RingEffect
	if ring:
		ring.pool = _ring_effect_pool
		ring.play_portal(pos, color, max_radius, duration)


## 在指定位置生成死亡线圈 + 破碎粒子效果
func spawn_death_ring_effect(pos: Vector2, max_radius: float = 80.0, duration: float = 0.5) -> void:
	var ring := _ring_effect_pool.acquire() as RingEffect
	if ring:
		ring.pool = _ring_effect_pool
		ring.play_death_rings(pos, max_radius, duration)
