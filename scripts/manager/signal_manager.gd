## 全局信号总线单例
## 所有跨系统的全局信号都在这里定义和中转
extends Node

## 玩家受损
signal player_damaged(hp: float, max_hp: float)
## 玩家死亡
signal player_died()
## 玩家发射子弹
signal player_shot(bullet: Node2D, target_pos: Vector2)
## 子弹命中敌人
signal bullet_hit_enemy(bullet: Node2D, enemy: Node2D)
## 敌人死亡
signal enemy_killed(enemy: Node2D, pos: Vector2)
