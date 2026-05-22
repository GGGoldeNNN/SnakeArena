# 打飞机 ✈️

Godot 4.6 射击游戏项目（STG / Shoot-'em-up）

---

## 概述

经典街机风格竖版射击游戏，使用 Godot 4.6 引擎开发。玩家操控飞机在 3000×3000 的游戏区域内移动，躲避并击落敌人。

---

## 功能特性

### 已实现
- **玩家飞机** — 惯性移动（加速度/摩擦力/最大速度），键盘 WASD / 方向键操控
- **碰撞击退** — 碰撞敌人/子弹时被弹开，附带短暂失控状态
- **边界碰撞** — 撞墙触发镜面反射击退
- **相机跟随** — Camera2D 平滑跟随玩家
- **世界边界可视化** — 半透明填充 + 100px 网格线 + 虚线边框
- **纹理缩放** — Mipmap 实现高清图缩小后依然清晰
- **简单 ECS 架构** — 组件/数据/系统三层分离

### 架构（simple_ECS）

\\\
scripts/simple_ECS/
├── components/           # 组件（挂载到实体上）
│   ├── health_component     生命值 / 受伤 / 无敌帧
│   ├── movement_component   移动模式（直线/正弦/追击/轨道）
│   └── shooter_component    射击逻辑（间隔/散弹）
├── data/                 # 数据模板（Resource）
│   ├── bullet_data          子弹属性模板
│   └── enemy_data           敌人属性模板
└── systems/              # 系统（挂载到场景中运行）
    ├── bullet_manager       子弹对象池管理
    └── spawn_system         敌人生成 / 波次管理
\\\

### 对象池
通用对象池 \ObjectPool\，支持预创建、自动扩容、acquire / release 生命周期管理，用于子弹和敌人的复用。

---

## 运行要求

- **Godot 4.6** 或更高版本
- 无需额外插件

## 快速开始

\\\ash
git clone https://github.com/GGGoldeNNN/SnakeArena.git
\\\

用 Godot 4.6 打开项目根目录，直接运行。

---

## 操作

| 按键 | 功能 |
|------|------|
| WASD / 方向键 | 移动 |
| 撞到敌人/子弹 | 被击退 + 短暂失控 |

---

## 技术栈

- **引擎**: Godot 4.6
- **语言**: GDScript
- **渲染**: Forward Plus, MSAA 2x, D3D12

---

## 项目结构

\\\
打飞机/
├── assets/                  # 资源文件
│   ├── fonts/               字体
│   └── image/player/        玩家贴图
├── scenes/                  # 场景文件
│   ├── game_root.tscn       游戏入口
│   ├── game_scene/          游戏主场景
│   ├── main_menu/           主菜单
│   └── player/              玩家场景
├── scripts/                 # 脚本
│   ├── scene/game_scene/    游戏主场景脚本
│   ├── player/              玩家脚本
│   ├── manager/             全局管理器（autoload）
│   ├── simple_ECS/          简易 ECS 框架
│   ├── save_system/         存档系统
│   └── tools/GXTools/       工具类
└── addons/godot_mcp/        Godot MCP 插件
\\\

---

## 待开发

- [ ] 子弹系统（玩家射击、敌人弹幕）
- [ ] 敌人种类（多种移动/攻击模式）
- [ ] 波次生成系统
- [ ] 得分 / 生命值 UI
- [ ] 音效与 BGM
- [ ] 游戏结束与重新开始
- [ ] 碰撞特效（闪烁、粒子）
