# SnakeArena 项目规范

> Godot 4.6 STG（竖版射击）游戏项目 — 玩家操控飞机与 Boss 蛇形敌人战斗

---

## 技术栈

| 项目 | 值 |
|------|-----|
| 引擎 | Godot 4.6 (Forward Plus) |
| 语言 | GDScript |
| 渲染 | Forward Plus, MSAA 2x, D3D12 |
| 分辨率 | 1920×1080 设计分辨率，1280×720 窗口，canvas_items 拉伸 |
| 物理 | Jolt Physics (3D)，2D 使用 Godot 默认 PhysicsServer2D |

## 项目结构

```
res://
├── addons/                     # 编辑器插件
│   ├── godot_mcp/              #   Godot MCP 开发工具
│   └── post_processing/        #   后处理特效插件（20 种特效）
├── assets/                     # 资源文件（编辑器标粉色）
│   ├── audio/                  #   音频文件（自动加载）
│   │   ├── audio_effect/       #     音效（bullet.mp3, hit.mp3）
│   │   └── bgm/                #     背景音乐（game_bgm.mp3）
│   ├── fonts/                  #   字体文件
│   ├── image/                  #   贴图文件
│   │   ├── enemy/              #     敌人贴图（蛇头/蛇身）
│   │   └── player/             #     玩家飞机贴图
│   └── ui/                     #   UI 贴图
├── data/                       # 运行时数据（编辑器标黄色）
│   └── post_process/           #   后处理配置
├── scenes/                     # 场景文件（编辑器标紫色）
│   ├── bullet/
│   │   ├── bullet.tscn         #     子弹预制体（Area2D + Sprite2D + CollisionShape2D）
│   │   └── bullet_manager.tscn #     子弹管理器预制体
│   ├── enemy/
│   │   ├── boss.tscn           #     Boss 蛇形敌人（Node2D）
│   │   ├── monster_head.tscn   #     蛇头（Area2D）
│   │   └── monster_node.tscn   #     蛇身节点（Area2D）
│   ├── game_scene/
│   │   └── game_scene.tscn     #     游戏主场景
│   ├── main_menu/
│   │   └── main_menu.tscn      #     主菜单
│   ├── player/
│   │   └── player.tscn         #     玩家飞机预制体
│   ├── ui/
│   │   ├── win_window.tscn     #     胜利窗口
│   │   └── fail_window.tscn    #     失败窗口
│   └── game_root.tscn          #   游戏入口/根场景
├── scripts/                    # 脚本（编辑器标绿色）
│   ├── game/                   #   游戏实体逻辑
│   │   ├── bullet/bullet.gd    #     子弹（Area2D，class_name Bullet）
│   │   ├── enemy/
│   │   │   ├── boss.gd         #     Boss 控制器（贪吃蛇结构）
│   │   │   ├── monster_head.gd #     蛇头（仅视觉+碰撞，不受伤）
│   │   │   └── monster_node.gd #     蛇身节点（独立受击/销毁）
│   │   ├── game_scene/game_scene.gd # 游戏主场景（生成玩家/Boss/子弹管理器）
│   │   ├── player/player.gd    #     玩家飞机（class_name Player，协调器）
│   │   └── ui/window.gd        #     胜利/失败窗口通用逻辑
│   ├── manager/                #   全局管理器（autoload）
│   │   ├── audio_manager.gd    #     音频管理器
│   │   ├── game_manager.gd     #     游戏状态管理器
│   │   ├── global_manager.gd   #     全局引用入口
│   │   ├── object_pool.gd      #     通用对象池（class_name ObjectPool, RefCounted）
│   │   ├── scene_manager.gd    #     场景切换管理器
│   │   └── signal_manager.gd   #     全局信号总线
│   ├── save_system/            #   存档系统
│   │   ├── save_item.gd        #     存档条目（class_name SaveItem, RefCounted）
│   │   ├── save_manager.gd     #     存档管理器（Autoload）
│   │   └── save_system_data.gd #     存档元数据（class_name SaveSystemData, RefCounted）
│   ├── simple_ECS/             #   轻量 ECS 框架
│   │   ├── core/ecs_world.gd   #     EcsWorld（Autoload）
│   │   ├── components/         #     组件（纯数据 Resource）
│   │   │   ├── health_data.gd  #       生命值 （class_name HealthData）
│   │   │   ├── player_movement_data.gd # 玩家移动 （class_name PlayerMovementData）
│   │   │   ├── auto_shooter_data.gd    # 自动瞄准射击 （class_name AutoShooterData）
│   │   │   ├── movement_data.gd        # 敌人移动 （class_name MovementData）
│   │   │   ├── shooter_data.gd         # 敌人射击 （class_name ShooterData）
│   │   │   ├── bullet_data.gd          # 子弹属性 （class_name BulletData）
│   │   │   └── enemy_data.gd           # 敌人配置 （class_name EnemyData）
│   │   └── systems/            #     系统（场景树挂载，驱动逻辑）
│   │       ├── player_movement_system.gd # 玩家移动
│   │       ├── auto_shoot_system.gd      # 自动瞄准/射击
│   │       ├── movement_system.gd        # 敌人移动
│   │       ├── shooter_system.gd         # 敌人射击
│   │       ├── health_system.gd          # 生命值/无敌/死亡
│   │       ├── bullet_manager.gd         # 子弹对象池管理（class_name BulletManager）
│   │       └── spawn_system.gd           # 敌人生成/波次（class_name SpawnSystem）
│   └── tools/GXTools/Debug.gd  #   调试日志工具（class_name Debug）
└── project.godot               # Godot 项目配置
```

---

## Autoload 单例

所有 autoload 在 `project.godot` 的 `[autoload]` 段注册，全局可访问。

| 名称 | 脚本 | 作用 |
|------|------|------|
| `GlobalManager` | `scripts/manager/global_manager.gd` | 全局引用入口，持有场景字典和窗口预制体引用 |
| `SceneManager` | `scripts/manager/scene_manager.gd` | 场景切换（current_active_scene + instantiate/queue_free） |
| `SignalManager` | `scripts/manager/signal_manager.gd` | **全局信号总线**，所有跨系统信号在此定义 |
| `AudioManager` | `scripts/manager/audio_manager.gd` | 音频管理，自动加载 `res://assets/audio/` |
| `GameManager` | `scripts/manager/game_manager.gd` | 游戏状态管理（PLAYING/WON/LOST） |
| `SaveManager` | `scripts/save_system/save_manager.gd` | 多存档系统（JSON 序列化） |
| `EcsWorld` | `scripts/simple_ECS/core/ecs_world.gd` | **ECS 核心**，实体注册/组件管理/批量查询 |

### GlobalManager —— 全局引用

```gdscript
# 场景字典 — 所有游戏场景在此注册
const SCENE: Dictionary[String, PackedScene] = {
    "main_menu": preload("res://scenes/main_menu/main_menu.tscn"),
    "game_scene": preload("res://scenes/game_scene/game_scene.tscn")
}

# 窗口预制体
const WINDOW: Dictionary[String, PackedScene] = {
    "win": preload("res://scenes/ui/win_window.tscn"),
    "fail": preload("res://scenes/ui/fail_window.tscn")
}
```

### SceneManager —— 场景切换

```gdscript
var current_active_scene: Node   # 当前活跃场景
var game_root: Node              # 游戏根节点（由 game_root.gd 赋值）

func switch_scenes(scene_name: String) -> void
```

调用方：`SceneManager.switch_scenes("game_scene")`

### SignalManager —— 全局信号总线

所有跨系统的全局信号在此定义，避免直接耦合。

```gdscript
signal player_damaged(hp: float, max_hp: float)          # 玩家受损
signal player_died()                                       # 玩家死亡
signal boss_defeated()                                     # Boss 被击败（所有身体节点摧毁后触发）
signal player_shot(bullet: Node2D, target_pos: Vector2)   # 玩家发射子弹
signal bullet_hit_enemy(bullet: Node2D, enemy: Node2D)    # 子弹命中敌人
signal enemy_killed(enemy: Node2D, pos: Vector2)           # 敌人死亡
```

**使用原则**：
- 组件/系统内部通信优先用本地信号
- 跨实体/跨系统的通信必须走 `SignalManager`
- 监听方在 `_ready()` 中连接，在 `_exit_tree()` 中断开（或使用 `one_shot`）

### GameManager —— 游戏状态

```gdscript
enum State { PLAYING, WON, LOST }
var state: int = State.PLAYING
```

- `boss_defeated` → State.WON → 暂停 + 弹出胜利窗口
- `player_died` → State.LOST → 暂停 + 弹出失败窗口
- 窗口内点击 Button → `SceneManager.switch_scenes("game_scene")`

### AudioManager —— 音频

- 自动加载 `res://assets/audio/` 下所有 `.wav`/`.mp3`/`.ogg`（递归子目录）
- 音效池 20 个 `AudioStreamPlayer` 实例，池满时返回 `null`
- 支持点击音效开关（`toggle_click_sound()`），默认关闭

```gdscript
AudioManager.play_sfx("bullet")           # 播放音效（文件名不含扩展名）
AudioManager.play_sfx_stream(stream)       # 直接播放 AudioStream
AudioManager.play_bgm("game_bgm")          # 播放背景音乐（支持循环）
AudioManager.stop_bgm()                    # 停止背景音乐
AudioManager.stop_all_sfx()                # 停止所有音效
AudioManager.set_sfx_volume(0.8)           # 设置音量
AudioManager.toggle_click_sound()          # 切换点击音效
```

### SaveManager —— 存档

- 多存档系统，JSON 文件存储于 `user://saves/`
- 存档文件：`save_{id}.json`，元数据：`save_system_data.json`
- 支持增删改查、序列化/反序列化、字典/数组合并写入

```gdscript
SaveManager.new_save_data("存档名称")       # 创建新存档 → SaveItem
SaveManager.save_data("key", value)        # 写入数据
SaveManager.load_data("key")               # 读取数据
SaveManager.load_save_data(save_id)        # 切换加载指定存档
SaveManager.delete_save_data(save_id)      # 删除存档
SaveManager.get_all_save_ids()             # 获取所有存档 ID 列表
```

### EcsWorld —— ECS 核心

```gdscript
# 注册/注销
var eid := EcsWorld.register(node)              # 注册实体，返回 int ID
EcsWorld.unregister(eid)                        # 手动注销（通常自动处理）

# 组件操作
EcsWorld.add_component(eid, component)          # 添加组件（Resource）
var data := EcsWorld.get_component(eid, HealthData)  # 按类型获取
var has := EcsWorld.has_component(eid, HealthData)   # 判断是否存在

# 查询
var ids := EcsWorld.query_entities([HealthData, MovementData])  # 多组件组合查询
var node := EcsWorld.get_entity_node(eid)       # 获取实体节点
```

---

## ECS 模式规范

项目采用 **轻量 ECS 风格** —— 借鉴 ECS 的数据驱动思想，但按需使用，不追求纯 ECS 范式。

> **设计原则**：ECS 是工具不是目的。简单玩法用简单架构，不强行将每个实体都塞进 ECS。
> 目前注册情况：
> - **Player** — 完整注册（HealthData + PlayerMovementData + AutoShooterData）
> - **MonsterNode** — 完整注册（HealthData），对象池管理
> - **Boss** — 自包含，不注册 ECS
> - **MonsterHead** — 仅注册实体 ID（用于子弹碰撞查询），不挂载组件

### 三层定义

| 层 | 目录 | 形式 | 说明 |
|----|------|------|------|
| **Entity** | `scripts/game/` | 普通 `extends Node` 脚本 | 场景树中的节点。注册到 EcsWorld，持有 Components 的引用 |
| **Component** | `components/` | `class_name XData extends Resource` | **纯数据**，不包含逻辑。所有字段用 `@export` |
| **System** | `systems/` | `extends Node`，挂载到场景树 | **纯逻辑**，每帧遍历匹配的实体，读写 Component 数据 |

### 架构流程

```
1. Entity._ready()
   └→ EcsWorld.register(self) → 返回 entity_id
   └→ EcsWorld.add_component(eid, HealthData.new(...))
   └→ EcsWorld.add_component(eid, MovementData.new(...))

2. System._process(delta)
   └→ for eid in EcsWorld.query_entities([HealthData]):
       ├→ var data = EcsWorld.get_component(eid, HealthData)
       └→ 修改 data 或操作实体节点
```

### Component 规范

1. **必须继承 `Resource`**，class_name 以 `Data` 结尾
2. **只包含数据**，没有 `_process()`，不操控父节点
3. **允许简单的数据操作方法**（如 `take_damage()` 修改自己的字段）
4. **命名** — `*_data.gd`，class_name 用 `*Data`

```gdscript
class_name HealthData extends Resource

@export var max_hp: float = 3.0
@export var invincible_time: float = 0.5

# 运行时状态
var current_hp: float
var invincible_timer: float = 0.0
var is_dead: bool = false

func take_damage(amount: float) -> bool:
    if invincible_timer > 0 or is_dead:
        return false
    current_hp -= amount
    if current_hp <= 0:
        is_dead = true
        return false
    invincible_timer = invincible_time
    return true

func heal(amount: float) -> void:
    current_hp = min(current_hp + amount, max_hp)

func reset() -> void:
    current_hp = max_hp
    invincible_timer = 0.0
    is_dead = false
```

### System 规范

1. **必须继承 `extends Node`**，挂载到场景树中运行
2. **每帧查询指定 Component 组合**，遍历匹配的实体
3. **System 不直接调用其他 System**，通过 Component 数据驱动
4. **命名** — `*_system.gd`（无特殊 class_name，BulletManager 和 SpawnSystem 除外）

```gdscript
# health_system.gd
func _process(delta: float) -> void:
    for eid in EcsWorld.query_entities([HealthData]):
        var data := EcsWorld.get_component(eid, HealthData) as HealthData
        if not data or data.is_dead:
            continue
        if data.invincible_timer > 0:
            data.invincible_timer -= delta
        if data.current_hp <= 0:
            data.is_dead = true
            var node := EcsWorld.get_entity_node(eid)
            if node and is_instance_valid(node):
                if node.has_method("on_destroyed"):
                    node.on_destroyed()
                else:
                    node.queue_free()
```

### Entity 规范

1. **实体是场景树中的普通 Node**，可选择在 `_ready()` 中注册到 EcsWorld
2. **注册不是强制的** — Boss 等复杂实体保持自包含，不注册 ECS
3. **添加组件**：创建 `XData.new()`，设置属性，调用 `EcsWorld.add_component()`
4. **协调器角色**：实体脚本处理"实体特有"的逻辑（如碰撞回调），通用逻辑交给 System
5. **存储 eid**：实体维护 `var entity_id: int = -1` 供外部查找
6. **死亡回调**：如果实体实现了 `on_destroyed()` 方法，HealthSystem 会在检测到死亡时调用

```gdscript
# player.gd
class_name Player extends Area2D
var entity_id: int = -1

func _ready() -> void:
    entity_id = EcsWorld.register(self)
    var health := HealthData.new()
    health.max_hp = 5.0
    EcsWorld.add_component(entity_id, health)

func _on_area_entered(area: Area2D) -> void:
    _try_damage_and_knockback(area.global_position)

func _try_damage_and_knockback(from_position: Vector2) -> void:
    var health := EcsWorld.get_component(entity_id, HealthData) as HealthData
    if health and health.invincible_timer <= 0:
        health.take_damage(1.0)
        SignalManager.player_damaged.emit(health.current_hp, health.max_hp)
```

### 系统处理顺序

系统按场景树中兄弟节点的顺序执行。推荐顺序：

```
Systems (Node)
├── PlayerMovementSystem      # 先处理玩家输入
├── AutoShootSystem           # 再自动瞄准射击
├── MovementSystem            # 敌人移动
├── ShooterSystem             # 敌人射击
└── HealthSystem              # 最后处理死亡（无敌计时等）
```

---

## 对象池规范

`ObjectPool`（`class_name ObjectPool extends RefCounted`）是通用对象池实现。

### 使用方式

```gdscript
var pool := ObjectPool.new(scene, parent_node, prewarm_count=10)
var obj := pool.acquire()    # 获取（自动激活 + 调用 reset()）
pool.release(obj)            # 归还（自动停用）
pool.prewarm(count)          # 额外预创建
pool.get_free_count()        # 当前空闲数
pool.auto_grow = true        # 是否自动扩容（默认 true）
```

### 对象要求

被池管理的对象必须：
1. 实现 `reset()` 方法 — 对象被 `acquire()` 时自动调用，重置状态
2. 在 `_ready()` 中完成一次性初始化

### 生命周期

```
acquire() → _activate() → reset() → [使用] → release() → _deactivate() → 回到池
```

- `_activate()`: 启用 process、显示 visible、恢复 process_mode
- `_deactivate()`: 禁用 process、隐藏 visible、移出屏幕 (Vector2(-9999,-9999))、使用 `call_deferred("set_process_mode", PROCESS_MODE_DISABLED)` 避免物理回调报错

---

## Boss 蛇形敌人系统

Boss 采用**贪吃蛇式多节身体结构**，Boss 控制器（Node2D）+ 头部（MonsterHead, Area2D）+ N 节身体（MonsterNode, Area2D）。

### 状态机

```gdscript
enum State { CHASING, RETREATING }
```

- **CHASING**: 正弦弧形摆动追逐玩家，通过 trail 系统驱动身体跟随
- **RETREATING**: 所有身体被摧毁后向上退场，移出屏幕后 `queue_free()`

### 轨迹系统（Trail）

头部每帧记录位置到轨迹数组，身体按固定间距沿轨迹定位：

```
_trail_positions: Array[Vector2]  # 位置点
_trail_distances: Array[float]    # 累计距离
```

- `_add_trail_point()` — 每帧记录头部位置（距离 > 1px 时采样）
- `_get_position_on_trail(distance_from_end)` — 从轨迹尾部向前搜索指定距离的位置（线性插值）
- `_prune_trail()` — 修剪超出最大距离的旧轨迹点
- `_update_body_positions()` — 按 head_to_body_spacing + i * body_spacing 定位每节身体
- `_update_body_rotations()` — 每节身体朝向上一节位置

### 身体池化（Deferred Pooling）

采用**两阶段池化**避免初始化卡顿：
1. `_refill_pool()` — 每帧最多创建 5 个 MonsterNode，分散 `instantiate()` 开销
2. `_spawn_body_segments()` — 当 trail 够长时从池中取出并激活

### 被摧毁后的回缩

单节身体被摧毁时：
1. 从 `_body_segments` 中移除
2. 被摧毁节点归还对象池（`_pool_deactivate` + `_node_pool.append`）
3. 单 Tween 并行驱动剩余身体回缩拼接（`set_parallel(true)`）
4. `_freeze_timer` 暂停追击和身体更新
5. 所有身体被摧毁 → State.RETREATING → `SignalManager.boss_defeated.emit()`

### 身体节点（MonsterNode）

- 注册完整 ECS: HealthData（max_hp=3, invincible_time=0.5）
- 受击流程: bullet → `_damage_enemy` → `HealthData.take_damage` → HealthSystem 检测 → `on_destroyed()` → `destroyed` 信号 → Boss 控制器处理
- `is_pooled` 标志控制 `on_destroyed()` 中是否 `queue_free`（池化 = 不销毁）

### 头部（MonsterHead）

- 仅注册实体 ID（无组件），用于子弹碰撞查询
- 头部被子弹命中不会受伤（无 HealthData）
- 提供 `flash_hit()` 闪红效果（纯视觉）

---

## 子弹系统

### Bullet（class_name Bullet, extends Area2D）

- 运行中生成白色圆形纹理（12×12 像素 Image）
- 碰撞检测: area_entered → 检查 `is_in_group("enemy")` → 通过 entity_id 获取 HealthData → 造成伤害
- 碰撞后断开 area_entered 连接，防止重复触发
- 飞行超过 max_distance 后自动回收
- 如果目标已死亡（health.is_dead）且实现了 `on_destroyed()`，立即触发销毁回调

### BulletManager（class_name BulletManager, extends Node）

- 管理玩家和敌人两套对象池（prewarm=30）
- `spawn_player_bullet(data)` / `spawn_enemy_bullet(data)` — 从池中获取并配置
- `release_bullet(bullet, is_player)` — 回收

### 碰撞层

| 层 | 用途 | 掩码 |
|----|------|------|
| Layer 1 | 玩家子弹 | mask 2（敌人） |
| Layer 2 | 敌人 | mask 1（玩家子弹） |
| 默认 | 玩家自身、其他 | — |

---

## 玩家系统

### Player（class_name Player, extends Area2D）

- 协调器角色：注册 ECS，处理碰撞回调
- ECS 组件: `HealthData`（max_hp=5, invincible_time=0.5）+ `PlayerMovementData` + `AutoShooterData`
- 碰撞处理: `_try_damage_and_knockback(from_position)` → 受伤 + 击退 + 闪红
- 世界边界内碰撞墙壁触发击退+反弹+1点伤害
- 可配置的 `_draw()` 绘制攻击范围圈（range circle）

### PlayerMovementSystem

- 每帧遍历 `[PlayerMovementData]`
- 输入: WASD / 方向键（四方向，标准化向量）
- 惯性: acceleration/friction/max_speed
- 击退: knockback_force + stun_timer（失控期间不处理输入）
- 边界: world_boundary 约束 + 镜面反弹 + 碰撞伤害

### AutoShootSystem

- 每帧遍历 `[AutoShooterData]`
- 自动转向最近敌人（lerp_angle 平滑旋转）
- 攻击范围内有敌人时自动射击（cooldown 间隔）
- 失控（stun_timer > 0）时仅绘制不射击

---

## 敌人移动模式（MovementData）

```gdscript
enum Pattern { LINEAR, SINE, CHASE, ORBIT, STOP }
```

| 模式 | 行为 |
|------|------|
| `LINEAR` | 沿 `direction` 方向匀速直线运动 |
| `SINE` | 沿 `direction` 方向 + 垂直方向正弦摆动（amplitude/frequency） |
| `CHASE` | 追踪 `"player"` 组最近节点 |
| `ORBIT` | 以 amplitude 为半径做圆周运动 |
| `STOP` | 不动（被 system 跳过） |

### 敌人射击（ShooterSystem）

- 每帧遍历 `[ShooterData]`
- 支持散弹: spread_count + spread_angle
- 子弹从 BulletManager 对象池获取
- 通过 EnemyData 在 SpawnSystem 中配置

### 波次生成（SpawnSystem）

- 基于队列的波次系统: `wave_queue: Array[Array]`（[EnemyData, count] 对）
- 每 `spawn_interval` 秒从池中获取一个敌人，应用 EnemyData 配置
- 生成位置: 视口顶部随机 x（屏幕外上方 50px）
- 信号: `wave_started(wave)`, `wave_cleared(wave)`

---

## 游戏场景（game_scene.gd）

游戏主场景 `game_root.tscn → game_scene.tscn`（开发模式直接进入游戏）。

- `_ready()` 流程: 初始化 BulletManager → 生成 Player → 生成 Boss（body_count=200）→ 播放 BGM
- 使用 `BossInitialPosition` (Marker2D) 标记 Boss 生成位置
- 世界边界可视化: 3000×3000 区域，半透明填充 + 100px 网格 + 虚线边框（在 _draw 中随玩家位置渲染）
- 游戏根节点 `game_root.gd`: `SceneManager.game_root = self` + 直接切换到游戏场景

---

## UI 系统

### 主菜单场景（main_menu.tscn）

- 暂为占位场景，当前开发模式跳过主菜单直接进入游戏

### 胜利/失败窗口

- `window.gd`（extends Control）— 通用脚本
- Panel + Button（重新开始）
- 重新开始: `get_tree().paused = false` → `SceneManager.switch_scenes(restart_scene)`
- 由 GameManager 在检测到游戏结束时弹出

---

## 场景与预制体规范

### 原则

**场景结构在 .tscn 中定义，逻辑在 .gd 中定义。** 不要把节点创建逻辑写在代码中。

### 正确做法

- 在编辑器中创建 `Sprite2D`、`CollisionShape2D`、`AudioStreamPlayer` 等子节点
- 脚本只负责 `_ready()` 初始化、信号连接、运行时逻辑
- 使用 `preload("res://scenes/xxx.tscn")` 引用预制体

---

## 代码规范

### 命名

| 项 | 规范 | 示例 |
|----|------|------|
| 文件名 | snake_case | `bullet_manager.gd` |
| class_name | PascalCase | `class_name BulletManager` |
| 变量/函数 | snake_case | `var max_distance`, `func take_damage()` |
| 常量 | SCREAMING_SNAKE_CASE | `const AUDIO_DIR: String` |
| 私有成员 | `_` 前缀 | `var _pool: Array`, `func _deactivate()` |
| 信号 | snake_case | `signal player_died` |

### 类型标注

- **所有 `@export` 变量必须标注类型**
- **所有函数参数和返回值必须标注类型**（`-> void` 不能省略）
- **所有成员变量（member variables）标注类型**
- 局部变量尽量标注类型

### 代码风格

- 缩进：**Tab**（Godot 默认）
- 空行：函数之间一个空行，逻辑段之间一个空行
- 每行不超过 120 字符
- `if` / `elif` / `else` / `for` / `while` 等关键字后加空格
- 运算符两侧加空格：`var step := _direction * speed * delta`

### 类与继承

| 用途 | 继承 | 说明 |
|------|------|------|
| Component（数据） | `extends Resource` | class_name 以 `Data` 结尾，无逻辑 |
| System | `extends Node` | 挂载到场景树，`_process()` 驱动 |
| 实体 Node | `extends Node2D/Area2D` | 场景实体脚本，不需要 class_name（用路径引用） |
| 工具类 | `extends Node` + `class_name` | 静态工具方法 |
| 对象池 | `extends RefCounted` | Resource 之外的可复用对象 |

### 信号使用

- 跨系统信号：定义在 `SignalManager` 中
  ```gdscript
  SignalManager.bullet_hit_enemy.emit(self, area)
  ```
- 本地信号：直接在脚本中定义
  ```gdscript
  signal destroyed(node: MonsterNode)
  ```
- 连接信号时先检查是否已连接
  ```gdscript
  if not area_entered.is_connected(_on_area_entered):
      area_entered.connect(_on_area_entered)
  ```

### 字符串格式化

- 使用 `%` 操作符，不用模板字符串
  ```gdscript
  Debug.Log("玩家已生成，宽度=%d" % player.width)
  ```

---

## 调试工具

`Debug`（`class_name Debug`）提供条件编译日志。

```gdscript
Debug.Log("普通日志")
Debug.Log_Success("成功日志")      # 绿色
Debug.Log_Error("错误日志")        # 红色
Debug.Log_Warning("警告日志")      # 黄色
Debug.Log_Error_Stop("致命错误")   # 红色 + 停止游戏
```

`IS_OPEN = true` 控制日志开关，发布前设为 `false` 关闭所有日志。

---

## 开发工作流

### 使用 Godot MCP 工具

优先使用 MCP 工具进行以下操作：
- `create_scene` / `add_node` — 创建场景和节点
- `attach_script` / `detach_script` — 挂载/解绑脚本
- `connect_signal` — 连接信号
- `validate_script` — 验证脚本语法
- `run_scene` / `stop_scene` — 运行/停止场景
- `set_sprite_texture` / `set_material` — 设置资源
- `read_scene` / `scene_tree_dump` — 查看场景结构

### 文件命名

- `.gd` 脚本与对应的 `.tscn` 场景同名（如 `player.tscn` ↔ `player.gd`）
- `.uid` 文件由 Godot 自动管理，不要手动编辑或删除

### .tscn 优先

- 所有节点结构必须在 .tscn 中定义
- 脚本中只处理逻辑，不创建子节点（Bullet 运行时生成纹理例外）
- 需要调整节点结构 → 编辑 .tscn，不是改代码

### ECS 开发流程

1. **定义 Component** — 确定实体需要哪些数据，创建 `*_data.gd`（extends Resource）
2. **创建/修改 Entity** — 在 `_ready()` 中注册 EcsWorld，添加 Components
3. **创建 System** — 查询实体组合，编写纯逻辑
4. **挂载 System** — 在场景树的 `Systems` 节点下添加 System 子节点

### 新增功能检查清单

- [ ] 数据是否适合放在 Component（Resource）中？
- [ ] 逻辑是否应该放在 System（Node）中集中处理？
- [ ] 该实体是否真的需要 ECS 注册？（简单实体可直接自包含，不必强求）
- [ ] 跨系统通信信号是否定义在 SignalManager 中？
- [ ] 新数据是否需要支持存档（SaveManager）？
- [ ] 对象池管理的对象是否实现了 `reset()` 方法？
- [ ] 是否需要处理 `on_destroyed()` 回调？
