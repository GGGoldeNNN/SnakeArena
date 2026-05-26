# SnakeArena — 打飞机

> Godot 4.6 竖版 STG（射击）游戏项目

经典街机风格竖版射击游戏，玩家操控飞机在 3000×3000 的游戏区域内移动，与 Boss 蛇形敌人战斗。

---

## 功能特性

### 已实现

- **玩家飞机** — 惯性移动（加速度/摩擦力/最大速度），键盘 WASD / 方向键操控
- **自动瞄准射击** — 自动转向最近敌人并在范围内开火（可配置射程/攻速/伤害）
- **碰撞与击退** — 接触敌人/子弹时被弹开，附带短暂硬直状态
- **边界碰撞** — 撞墙触发镜面反射击退 + 额外伤害
- **攻击范围可视化** — 玩家周围半透明攻击圈绘制
- **Boss 蛇形敌人** — 贪吃蛇式多节身体（头部 + N 节身体），正弦弧形追逐玩家
  - 身体独立受击/销毁，摧毁后剩余身体自动回缩拼接
  - 逐帧池化创建，避免初始化卡顿
  - 所有身体被摧毁后 Boss 退场
- **子弹系统** — 双对象池管理（玩家/敌人子弹），碰撞区域检测造成伤害
- **波次生成系统** — 可配置的敌人类型/数量/生成间隔
- **多种敌人移动模式** — 直线/正弦/追击/轨道
- **音效系统** — 自动加载音频目录，音效对象池（20 通道），BGM 循环播放
- **相机跟随** — Camera2D 平滑跟随玩家
- **纹理等比缩放** — 支持 Mipmap
- **世界边界可视化** — 半透明背景 + 100px 网格线 + 虚线边框
- **游戏流程** — 游戏开始 → 战斗 → 胜利/失败 → 重新开始
- **多存档系统** — JSON 序列化，支持增删改查

### 轻量 ECS 架构

项目自研了简单 ECS 框架，采用数据驱动设计：

```
scripts/simple_ECS/
├── core/
│   └── ecs_world.gd                    EcsWorld（Autoload）
├── components/                         纯数据 Resource
│   ├── health_data.gd                  生命值/无敌帧
│   ├── player_movement_data.gd         玩家移动/击退参数
│   ├── auto_shooter_data.gd            自动瞄准射击参数
│   ├── movement_data.gd                敌人移动模式（LINEAR/SINE/CHASE/ORBIT）
│   ├── shooter_data.gd                 敌人射击配置（含散弹支持）
│   ├── bullet_data.gd                  子弹属性模板
│   └── enemy_data.gd                   敌人配置模板
└── systems/                            场景树挂载，驱动逻辑
    ├── player_movement_system.gd       玩家输入/惯性/边界/击退
    ├── auto_shoot_system.gd            自动瞄准/射击
    ├── movement_system.gd              敌人移动
    ├── shooter_system.gd               敌人射击
    ├── health_system.gd                生命值/无敌计时/死亡检测
    ├── bullet_manager.gd               子弹对象池管理
    └── spawn_system.gd                 敌人生成/波次管理
```

设计原则：ECS 是工具不是目的。Player 和 MonsterNode 注册完整 ECS，Boss 自包含，MonsterHead 仅注册 ID。

### 对象池

通用 `ObjectPool`（RefCounted），支持预创建、自动扩容、acquire/release 生命周期管理。
- 子弹池：BulletManager 管理玩家/敌人双池
- 身体池：Boss 逐帧填充对象池，按需激活

---

## 操作说明

| 按键 | 功能 |
|------|------|
| WASD / 方向键 | 移动 |
| 自动 | 自动瞄准并射击范围内敌人 |

- 碰撞敌人/子弹 → 被击退 + 短暂硬直 + 受伤
- 碰撞边界 → 反弹击退 + 受伤

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

## 项目管理

当前开发模式跳过主菜单，直接进入游戏场景。Boss 默认 200 节身体。

### 调试工具

全局 `Debug`（class_name）提供彩色分级日志，`IS_OPEN` 控制开关。

---

## 技术栈

| 项目 | 值 |
|------|-----|
| 引擎 | Godot 4.6 (Forward Plus) |
| 语言 | GDScript |
| 渲染 | Forward Plus, MSAA 2x, D3D12 |
| 物理 | Jolt Physics (3D) |
| 碰撞 | 2 层: 玩家子弹(1)→敌人(2)，敌人(2)→玩家子弹(1) |

---

## 项目结构

```
打飞机/
├── addons/                         # 编辑器插件
│   ├── godot_mcp/                     Godot MCP 开发工具
│   └── post_processing/               后处理插件（20 种特效）
├── assets/                         # 资源文件
│   ├── audio/                        音频文件（自动加载）
│   │   ├── audio_effect/               音效
│   │   └── bgm/                        背景音乐
│   ├── fonts/                        字体
│   ├── image/                        贴图
│   │   ├── enemy/                      蛇头/蛇身
│   │   └── player/                     玩家飞机
│   └── ui/                           UI 面板
├── data/                           # 运行时数据
│   └── post_process/                  后处理配置
├── scenes/                         # 场景文件
│   ├── bullet/                       子弹/子弹管理器
│   ├── enemy/                        Boss/蛇头/蛇身
│   ├── game_scene/                   游戏主场景
│   ├── main_menu/                    主菜单
│   ├── player/                       玩家飞机
│   ├── ui/                           胜利/失败窗口
│   └── game_root.tscn                游戏入口
└── scripts/                        # GDScript 脚本
    ├── game/                         实体逻辑
    ├── manager/                      全局管理器（7 个 autoload）
    ├── save_system/                  多存档系统
    ├── simple_ECS/                   轻量 ECS 框架
    └── tools/                        工具类
```

---

## 文件统计

| 类型 | 数量 |
|------|------|
| 场景 (.tscn) | 30（含 20 个后处理子场景） |
| 脚本 (.gd) | 46 |
| 着色器 (.gdshader) | 21 |
| 贴图 (.png) | 12 |
| 音频 (.mp3) | 3 |
| 字体 (.ttf/.otf) | 2 |
