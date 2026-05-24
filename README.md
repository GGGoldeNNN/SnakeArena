# SnakeArena

Godot 4.6 STG（射击）游戏项目

---

## 概述

经典街机风格竖版射击游戏，使用 Godot 4.6 引擎开发。玩家操控飞机在 3000×3000 的游戏区域内移动，与 Boss 蛇形敌人战斗。

---

## 功能特性

### 已实现
- **玩家飞机** — 惯性移动（加速度/摩擦力/最大速度），键盘 WASD / 方向键操控
- **自动瞄准射击** — 自动转向最近敌人并在范围内开火（可配置射程/攻速/伤害）
- **碰撞击退** — 碰撞敌人/子弹时被弹开，附带短暂硬直状态
- **边界碰撞** — 撞墙触发镜面反射击退
- **Boss 蛇形敌人** — 贪吃蛇式多节身体（头部+50节），正弦弧形追逐玩家，身体独立受击/销毁
- **子弹系统** — 对象池管理玩家和敌人子弹，支持散弹配置
- **波次生成系统** — 可配置的敌人生成/波次管理
- **音效系统** — 自动加载音频目录，音效对象池（20 通道），BGM 播放
- **世界边界可视化** — 半透明填充 + 100px 网格线 + 虚线边框
- **相机跟随** — Camera2D 平滑跟随玩家
- **纹理缩放** — 等比缩放，支持 Mipmap

### 轻量 ECS 架构

```
scripts/simple_ECS/
├── core/                    # 核心
│   └── ecs_world.gd            EcsWorld（Autoload，实体注册/组件管理/查询）
├── components/              # 组件（纯数据 Resource）
│   ├── health_data.gd          生命值/无敌帧
│   ├── player_movement_data.gd 玩家移动/击退参数
│   ├── auto_shooter_data.gd    自动瞄准射击参数
│   ├── movement_data.gd        敌人移动模式（直线/正弦/追击/轨道）
│   ├── shooter_data.gd         敌人射击配置
│   ├── bullet_data.gd          子弹属性模板
│   └── enemy_data.gd           敌人配置模板
└── systems/                 # 系统（挂载场景树，驱动逻辑）
    ├── player_movement_system.gd  玩家输入/惯性/边界/击退
    ├── auto_shoot_system.gd       自动瞄准/射击
    ├── movement_system.gd         敌人移动
    ├── shooter_system.gd          敌人射击
    ├── health_system.gd           生命值/无敌计时/死亡检测
    ├── bullet_manager.gd          子弹对象池管理
    └── spawn_system.gd            敌人生成/波次管理
```

设计原则：ECS 是工具不是目的。Player/MonsterNode 注册完整 ECS，Boss 自包含，MonsterHead 仅注册 ID。

### 对象池

通用 `ObjectPool`，支持预创建、自动扩容、acquire/release 生命周期管理，用于子弹和敌人的复用。

---

## 运行要求

- **Godot 4.6** 或更高版本
- 无需额外插件

## 快速开始

```
git clone https://github.com/GGGoldeNNN/SnakeArena.git
```

用 Godot 4.6 打开项目根目录，直接运行。

---

## 操作

| 按键 | 功能 |
|------|------|
| WASD / 方向键 | 移动 |
| 撞到敌人/子弹 | 被击退 + 短暂硬直 |

---

## 技术栈

- **引擎**: Godot 4.6
- **语言**: GDScript
- **渲染**: Forward Plus, MSAA 2x, D3D12

---

## 项目结构

```
打飞机/
├── addons/                    # 插件
│   ├── godot_mcp/                Godot MCP 开发工具
│   └── post_processing/          后处理插件
├── assets/                    # 资源文件
│   ├── audio/                   音频文件（自动加载）
│   ├── fonts/                   字体
│   └── image/                   贴图
│       ├── enemy/                  敌人贴图
│       └── player/                 玩家贴图
├── data/                      # 运行时数据（后处理配置等）
├── scenes/                    # 场景文件
│   ├── bullet/                 子弹/子弹管理器
│   ├── enemy/                  Boss/蛇头/蛇身
│   ├── game_scene/             游戏主场景
│   ├── main_menu/              主菜单
│   ├── player/                 玩家飞机
│   └── game_root.tscn          游戏入口
└── scripts/                   # 脚本
    ├── game/                   实体逻辑（bullet/boss/player/...）
    ├── manager/                全局管理器（autoload）
    ├── save_system/            存档系统
    ├── simple_ECS/             轻量 ECS 框架
    └── tools/                  工具类
```
