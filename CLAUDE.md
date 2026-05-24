# SnakeArena 项目规范

> Godot 4.6 STG（射击）游戏项目

---

## 技术栈

| 项目 | 值 |
|------|-----|
| 引擎 | Godot 4.6 |
| 语言 | GDScript |
| 渲染 | Forward Plus, MSAA 2x, D3D12 |
| 分辨率 | 1920×1080 设计分辨率，1280×720 窗口，canvas_items 拉伸 |
| 物理 | Jolt Physics (3D)，2D 使用 Godot 默认 PhysicsServer2D |

## 项目结构

```
res://
├── assets/                     # 资源文件（编辑器标粉色）
│   ├── audio/                  #   音频文件（.wav/.mp3/.ogg，自动加载）
│   ├── fonts/                  #   字体文件
│   └── image/                  #   贴图文件
│       ├── enemy/              #     敌人贴图
│       └── player/             #     玩家贴图
├── scenes/                     # 场景文件（编辑器标紫色）
│   ├── bullet/                 #   子弹相关
│   │   ├── bullet.tscn         #     子弹预制体（Area2D + Sprite2D + CollisionShape2D）
│   │   └── bullet_manager.tscn #     子弹管理器预制体
│   ├── enemy/                  #   敌人相关
│   │   ├── boss.tscn           #     Boss 蛇形敌人
│   │   ├── monster_head.tscn   #     蛇头节点
│   │   └── monster_node.tscn   #     蛇身节点
│   ├── game_scene/             #   游戏主场景
│   │   └── game_scene.tscn     #     游戏场景
│   ├── main_menu/              #   主菜单
│   │   └── main_menu.tscn      #     主菜单场景
│   ├── player/                 #   玩家相关
│   │   └── player.tscn         #     玩家飞机预制体
│   ├── game_root.tscn          #   游戏入口场景
├── scripts/                    # 脚本（编辑器标绿色）
│   ├── game/                   #   游戏逻辑（实体脚本）
│   │   ├── bullet/             #     子弹逻辑
│   │   │   └── bullet.gd       #       子弹（Area2D）
│   │   ├── enemy/              #     敌人逻辑
│   │   │   ├── boss.gd         #       Boss 蛇（蛇形敌人，多节身体）
│   │   │   ├── monster_head.gd #       蛇头（追踪玩家）
│   │   │   └── monster_node.gd #       蛇身节点（Trail 跟随系统）
│   │   ├── game_scene/         #     游戏场景逻辑
│   │   │   └── game_scene.gd   #       游戏主场景（生成玩家/Boss/子弹管理器）
│   │   ├── player/             #     玩家逻辑
│   │   │   └── player.gd       #       玩家协调器（薄层，协调各组件）
│   ├── manager/                #   全局管理器（autoload）
│   │   ├── audio_manager.gd    #     音频管理器（音效池 + BGM + 自动加载 assets/audio/）
│   │   ├── game_manager.gd     #     游戏状态管理器（占位）
│   │   ├── global_manager.gd   #     全局管理器（占位，UI引用入口）
│   │   ├── object_pool.gd      #     通用对象池类（class_name ObjectPool, RefCounted）
│   │   ├── scene_manager.gd    #     场景切换管理器
│   │   └── signal_manager.gd   #     全局信号总线
│   ├── save_system/            #   存档系统
│   │   ├── save_item.gd        #     存档条目
│   │   ├── save_manager.gd     #     存档管理器
│   │   └── save_system_data.gd #     存档数据定义
│   ├── simple_ECS/             #   ECS 框架
│   │   ├── core/               #     核心
│   │   │   └── ecs_world.gd    #       EcsWorld（Autoload，实体注册/组件管理/查询）
│   │   ├── components/         #     组件（纯数据 Resource）
│   │   │   ├── auto_shooter_data.gd   # 自动瞄准射击数据
│   │   │   ├── bullet_data.gd         # 子弹属性模板
│   │   │   ├── enemy_data.gd          # 敌人配置模板
│   │   │   ├── health_data.gd         # 生命值数据
│   │   │   ├── movement_data.gd       # 移动参数数据（敌人用）
│   │   │   ├── player_movement_data.gd # 玩家移动参数数据
│   │   │   └── shooter_data.gd        # 射击参数数据（敌人用）
│   │   └── systems/            #     系统（挂载到场景中运行，驱动逻辑）
│   │       ├── auto_shoot_system.gd    # 自动瞄准射击系统
│   │       ├── bullet_manager.gd       # 子弹管理系统（对象池包装）
│   │       ├── health_system.gd        # 生命值系统（无敌计时/死亡检测）
│   │       ├── movement_system.gd      # 敌人移动系统
│   │       ├── player_movement_system.gd # 玩家移动系统
│   │       ├── shooter_system.gd       # 敌人射击系统
│   │       └── spawn_system.gd         # 敌人生成/波次系统
│   └── tools/GXTools/          #   工具类
│       └── Debug.gd            #     调试日志工具
├── addons/godot_mcp/           #    Godot MCP 插件（开发工具）
├── addons/post_processing/     #    后处理插件
└── project.godot               #    Godot 项目配置
```

---

## Autoload 单例

所有 autoload 在 `project.godot` 的 `[autoload]` 段注册，全局可访问。

| 名称 | 脚本 | 作用 |
|------|------|------|
| `GlobalManager` | `scripts/manager/global_manager.gd` | 全局引用入口，持有 GameManager 和 UI 节点的引用 |
| `SceneManager` | `scripts/manager/scene_manager.gd` | 场景切换（切换场景+过渡动画） |
| `SignalManager` | `scripts/manager/signal_manager.gd` | **全局信号总线**，所有跨系统信号在此定义 |
| `AudioManager` | `scripts/manager/audio_manager.gd` | 音频管理，自动加载 `assets/audio/` 下所有音频 |
| `GameManager` | `scripts/manager/game_manager.gd` | 游戏状态管理（目前为占位） |
| `SaveManager` | `scripts/save_system/save_manager.gd` | 存档系统 |
| `EcsWorld` | `scripts/simple_ECS/core/ecs_world.gd` | **ECS 核心**，实体注册/组件管理/批量查询 |

### SignalManager —— 全局信号总线

所有跨系统的全局信号在此定义，避免直接耦合。

```gdscript
signal player_damaged(hp: float, max_hp: float)    # 玩家受损
signal player_died()                                  # 玩家死亡
signal player_shot(bullet: Node2D, target_pos: Vector2)  # 玩家发射子弹
signal bullet_hit_enemy(bullet: Node2D, enemy: Node2D)  # 子弹命中敌人
signal enemy_killed(enemy: Node2D, pos: Vector2)     # 敌人死亡
```

**使用原则**：
- 组件/系统内部通信优先用本地信号
- 跨实体/跨系统的通信必须走 `SignalManager`
- 监听方在 `_ready()` 中连接，在 `_exit_tree()` 中断开

---

## ECS 模式规范

项目采用 **轻量 ECS 风格** —— 借鉴 ECS 的数据驱动思想，但按需使用，不追求纯 ECS 范式。

> **设计原则**：ECS 是工具不是目的。简单玩法用简单架构，不强行将每个实体都塞进 ECS。
> 目前仅 **Player** 和 **MonsterNode** 注册了完整 ECS 组件；Boss 因其复杂性保持自包含，
> MonsterHead 仅注册实体 ID（用于碰撞查询），不挂载组件。

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

### EcsWorld API

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
var node := EcsWorld.get_entity_node(eid)       # 获取实体节点（注意：Godot 4 的 Node.get_node() 只接受 NodePath，故不能用 get_node 命名）
```

### Component 规范

1. **必须继承 `Resource`**，class_name 以 `Data` 结尾
2. **只包含数据**，没有 `_process()`，不操控父节点
3. **允许简单的数据操作方法**（如 `take_damage()` 修改自己的字段）
4. **命名** — `*_data.gd`，class_name 用 `*Data`

示例：
```gdscript
class_name HealthData extends Resource

@export var max_hp: float = 3.0
@export var invincible_time: float = 0.5

# 运行时状态
var current_hp: float
var invincible_timer: float = 0.0
var is_dead: bool = false

# 允许纯数据操作方法
func take_damage(amount: float) -> bool:
    if invincible_timer > 0 or is_dead:
        return false
    current_hp -= amount
    if current_hp <= 0:
        is_dead = true
        return false
    invincible_timer = invincible_time
    return true

func reset() -> void:
    current_hp = max_hp
    invincible_timer = 0.0
    is_dead = false
```

### System 规范

1. **必须继承 `extends Node`**，挂载到场景树中运行
2. **每帧查询指定 Component 组合**，遍历匹配的实体
3. **System 不直接调用其他 System**，通过 Component 数据驱动
4. **命名** — `*_system.gd`（无特殊 class_name）

示例：
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
                node.on_destroyed()
```

### Entity 规范

1. **实体是场景树中的普通 Node**，可选择在 `_ready()` 中注册到 EcsWorld
2. **注册不是强制的** — Boss 等复杂实体保持自包含，不注册 ECS
3. **添加组件**：创建 `XData.new()`，设置属性，调用 `EcsWorld.add_component()`
4. **协调器角色**：实体脚本处理"实体特有"的逻辑（如碰撞回调），通用逻辑交给 System
5. **存储 eid**：实体维护 `var entity_id: int = -1` 供外部查找

示例：
```gdscript
# player.gd
class_name Player extends Area2D
var entity_id: int = -1

func _ready() -> void:
    entity_id = EcsWorld.register(self)
    var health := HealthData.new()
    health.max_hp = 5.0
    EcsWorld.add_component(entity_id, health)
    # 其他组件...

# 碰撞等事件仍由实体处理
func _on_area_entered(area: Area2D) -> void:
    var health := EcsWorld.get_component(entity_id, HealthData) as HealthData
    if health: health.take_damage(1.0)
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
var pool := ObjectPool.new(bullet_scene, parent_node, prewarm_count=10)
var bullet := pool.acquire()    # 获取
pool.release(bullet)            # 归还
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
- `_deactivate()`: 禁用 process、隐藏 visible、**使用 `call_deferred("set_process_mode", PROCESS_MODE_DISABLED)`** 避免物理回调中禁用 CollisionObject 报错

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

## 碰撞层配置

| 层 | 用途 | 掩码 |
|----|------|------|
| Layer 1 | 玩家子弹 | mask 2（敌人） |
| Layer 2 | 敌人 | mask 1（玩家子弹） |
| 默认 | 玩家自身等 | — |

Bullet 的 `collision_mask = 2`（只检测敌人类）。

---

## 音频系统规范

`AudioManager` 自动加载 `res://assets/audio/` 目录下的所有 `.wav`/`.mp3`/`.ogg` 文件（包括子目录）。

### API

```gdscript
AudioManager.play_sfx("hit")           # 播放音效（通过文件名不含扩展名）
AudioManager.play_bgm("game_bgm")      # 播放背景音乐
AudioManager.stop_bgm()                # 停止背景音乐
AudioManager.stop_all_sfx()            # 停止所有音效
AudioManager.set_sfx_volume(0.8)       # 设置音量
```

### 音效池

- 默认 20 个 `AudioStreamPlayer` 实例
- `play_sfx()` 返回 `AudioStreamPlayer` 引用（可用于停止等操作）
- 池满时返回 `null` 并打印警告

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
- 脚本中只处理逻辑，不创建子节点
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
