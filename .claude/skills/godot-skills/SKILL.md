---
name: godot-skills
description: Godot 4.x 游戏开发全能助手 — 包含 GDScript 代码生成、无头模式验证、资源路径修复、数据驱动配置、场景/资源格式参考、工具函数库、安全文件操作规范。一站式覆盖 Godot 开发的代码、资产、数据、调试、安全各环节。
auto_trigger: true
trigger_priority: 1
---

# Godot 4.x 全能开发助手

## 快速路由表

根据用户意图，跳转到对应章节：

| 用户说... | 跳到章节 |
|-----------|---------|
| "写 GDScript 代码"、"生成脚本"、"代码规范" | → [§1 GDScript 代码生成规范](#1-gdscript-代码生成规范) |
| "清 Godot 缓存"、"编辑器报红"、"验证项目加载" | → [§2 无头模式验证与修复](#2-无头模式验证与修复) |
| "资源引用断了"、"移动文件夹后报错"、"修复路径" | → [§3 资源路径修复(外科手术)](#3-资源路径修复外科手术) |
| "配置表"、"WeaponData"、"把硬编码提取成数据" | → [§4 数据驱动配置](#4-数据驱动配置) |
| ".tres 怎么写"、"创建材质/环境"、"资源格式" | → [§5 .tres 资源文件格式](#5-tres-资源文件格式) |
| ".tscn 怎么写"、"创建场景"、"场景格式" | → [§6 .tscn 场景文件格式](#6-tscn-场景文件格式) |
| "工具函数"、"数学/随机/时间工具"、"工具库" | → [§7 GDScript 工具函数库](#7-gdscript-工具函数库) |
| "MCP 连接"、"启动 Godot" 等编辑器操作 | → [§8 MCP 连接管理](#8-mcp-连接管理) |
| "删错了文件"、"误删恢复"、"安全删除"、"不要 rm -rf" | → [§9 安全文件操作规范](#9-安全文件操作规范) |

---

# §1 GDScript 代码生成规范

> **来源**: gdscript-codegen
> **适用引擎**: Godot 4.5/4.6

## 1.1 类型系统

```gdscript
# ✅ 显式类型标注
var health: int = 100
var speed: float = 10.0
var player_name: String = "Player"
var position: Vector3 = Vector3.ZERO
var enemies: Array[Node3D] = []
var weapon_data: Dictionary = {}

# ✅ 函数参数和返回值标注
func take_damage(amount: int) -> void:
    health -= amount

func get_health_ratio() -> float:
    return float(health) / float(max_health)
```

## 1.2 类型推断陷阱

```gdscript
# ❌ for 循环迭代变量无法推断
for x in [-1.0, 1.0]:
    var pos := center + Vector2(x, 0) * radius  # 报错！
# ✅ 显式标注
for x: float in [-1.0, 1.0]:
    var pos := center + Vector2(x, 0) * radius

# ❌ 字典值类型无法推断
var value := data["a"]  # 报错！
# ✅ 显式标注或使用 as
var value: int = data["a"]
```

## 1.3 信号声明

```gdscript
signal health_changed(current: int, maximum: int)
signal died
signal damage_taken(amount: int, remaining: int)
```

## 1.4 导出变量

```gdscript
@export var health: int = 100
@export_range(0, 100, 1) var health: int = 100
@export_enum("Easy", "Normal", "Hard") var difficulty: int = 1
@export var weapon_resource: WeaponResource
@export_group("Combat")
@export var damage: int = 10
```

## 1.5 @onready 和节点引用

```gdscript
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var health_bar: ProgressBar = $UI/HealthBar

# 运行时获取（更灵活）
var player: Node3D
func _ready() -> void:
    player = get_tree().get_first_node_in_group("player")
```

## 1.6 信号连接规范

```gdscript
# 方法引用（推荐）
button.pressed.connect(_on_button_pressed)
# Lambda（简单逻辑）
timer.timeout.connect(func(): print("Timeout!"))
# 带参数绑定
enemy.died.connect(_on_enemy_died.bind(spawn_point))
# 一次性连接
button.pressed.connect(_on_one_time_press, CONNECT_ONE_SHOT)
```

## 1.7 编辑器警告规避（踩坑清单）

### 避免变量名与 built-in 重名

```gdscript
# ❌ 警告
var hash := _hash_cell(x, z)    # hash 是内置函数
# ✅
var cell_hash := _hash_cell(x, z)
```

**触发名单**: `hash`、`len`、`str`、`int`、`float`、`bool`、`print`、`abs`、`sin`、`cos`、`min`、`max`、`clamp`、`lerp`、`sign`、`type_of`、`range`、`load`、`preload`

### 避免局部变量 shadow 基类属性

`Node3D` 高风险：`transform`、`basis`、`position`、`rotation`、`scale`
`CanvasItem` 高风险：`visible`、`modulate`、`material`
`Node` 高风险：`name`、`owner`、`tree`

### 其他常见警告

```gdscript
# 未使用参数 → 加 _ 前缀
func compute(value: float, _threshold: float) -> float

# 整数除法 → 显式忽略或改用 float
@warning_ignore("integer_division")
var x_groups := int((size.x - 1) / 8) + 1

# 未使用的 signal → 标记占位
@warning_ignore("unused_signal")
signal health_changed(hp: int)  # TODO(v2)
```

## 1.8 代码生成检查清单

- [ ] 所有变量有类型标注
- [ ] for 循环迭代变量有类型标注
- [ ] 函数参数和返回值有类型标注
- [ ] 缩进使用 Tab（不是空格）
- [ ] 避免硬编码节点路径
- [ ] 类名 PascalCase，变量名 snake_case，私有变量 _snake_case
- [ ] 常量 UPPER_SNAKE_CASE，信号名 snake_case
- [ ] 没有变量名与内置函数重名
- [ ] 没有局部变量 shadow 基类属性
- [ ] 信号全部会 emit()，或显式标记占位

---

# §2 无头模式验证与修复

> **来源**: godot-headless-verify
> **核心工具**: Godot 命令行 `--headless` 模式

## 2.0 Godot 二进制约定

所有命令使用 `${GODOT}` 环境变量（Windows 下替换为实际路径）：
```bash
# macOS
GODOT="${GODOT:-/Applications/Godot.app/Contents/MacOS/Godot}"
# Windows 示例
GODOT="C:/Godot/Godot_v4.3-stable_win64.exe"
```

## 2.1 缓存安全清理

当编辑器显示 `Cannot open file 'res://…'` 但文件实际存在时：

```bash
# 需要：关闭编辑器
cd <project-root>

# 安全清理——保留 shader_cache 和 UI 布局
rm -rf .godot/imported \
       .godot/uid_cache.bin \
       .godot/global_script_class_cache.cfg \
       .godot/scene_groups_cache.cfg \
       .godot/editor/filesystem_cache*

# 无头模式重建缓存
"$GODOT" --headless --import --path .
```

**保留的文件**（不要删）：
- `.godot/shader_cache/` — 编译好的着色器
- `.godot/editor/*-folding-*.cfg` — 折叠状态
- `.godot/editor/editor_layout.cfg` — 窗口布局

## 2.2 场景加载冒烟测试

```bash
cat > /tmp/smoke.gd <<'EOF'
extends SceneTree
const SCENES := [
    "res://scenes/boot/main.tscn",
    "res://scenes/levels/arena/arena.tscn",
]
func _initialize() -> void:
    var failed := 0
    for s in SCENES:
        var ps := load(s) as PackedScene
        if ps == null: push_error("FAIL load: %s" % s); failed += 1; continue
        var inst := ps.instantiate()
        if inst == null: push_error("FAIL instantiate: %s" % s); failed += 1; continue
        print("OK %s (children=%d)" % [s, inst.get_child_count()])
        inst.queue_free()
    quit(0 if failed == 0 else 1)
EOF
"$GODOT" --headless --path . --script /tmp/smoke.gd 2>&1 | grep -E 'ERROR|OK '
rm -f /tmp/smoke.gd
```

## 2.3 脚本语法检查

```bash
"$GODOT" --headless --quit --path . 2>&1 \
    | grep -iE 'SCRIPT ERROR|Parse Error' || echo "all scripts parse OK"
```

## 2.4 强制重新导入单个文件夹

```bash
find art/models/environment/arena -name '*.import' -delete
"$GODOT" --headless --import --path .
```

## 2.5 导出/构建验证

```bash
# 列出导出预设
grep '^\[preset\.' export_presets.cfg
# 测试导出
mkdir -p /tmp/godot-export-test
"$GODOT" --headless --export-debug "<preset-name>" /tmp/godot-export-test/game.pck --path .
```

## 2.6 可忽略的常见 WARNING/ERROR

| 信息 | 说明 |
|------|------|
| `ObjectDB instances leaked at exit` | 无头模式一次性脚本的正常行为 |
| `WARNING: [fbx] ...` | FBX SDK 唠嗑 |
| 首次运行 `ERROR: failed loading resource` | 缓存仍在重建，重跑一次即可 |

## 2.7 反模式

- ❌ 删除全部 `.godot/`：会丢失 shader_cache，重建耗时 10+ 分钟
- ❌ 编辑器开启时运行维护脚本：编辑器会回写脏状态覆盖你的修改
- ❌ 硬编码 Godot 路径到脚本里：用 `${GODOT:-<default>}` 环境变量

---

# §3 资源路径修复(外科手术)

> **来源**: godot-asset-path-surgery
> **场景**: 移动/重命名资源文件夹后，编辑器报 `Cannot open file 'res://<old-path>'`

## 3.1 核心认知

Godot 资源携带**两种路径信息**：

| 种类 | 位置 | 更新机制 |
|------|------|---------|
| **发现路径**（编辑器如何找到文件） | `.godot/uid_cache.bin`, `.uid` sidecar | 文件移动时自动更新 |
| **内部 ExtResource 路径**（文件引用了谁） | **二进制文件载荷内部** | **不会自动更新**，必须 load + save 重写 |

## 3.2 诊断决策树

```
编辑器提示: "Cannot open file 'res://<old-path>'"
│
├─ 目标文件在新路径存在吗？
│  ├─ 否 → 文件已删除，恢复或修复引用
│  └─ 是 → 继续
│
├─ 错误来自 *二进制* 资源(.mesh/.material/.scn/.res)？
│  ├─ 否 → .tscn/.tres 文本文件，直接 sed/全局替换
│  └─ 是 → 使用下文的修复脚
│
├─ 受影响二进制还依赖了别的移动过的文件？
│  ├─ 否 → 模式 A（简单重保存）
│  └─ 是 → 模式 B（临时垫片 + 重新赋值 + 重保存）
```

## 3.3 模式 A — 简单重保存

```gdscript
# tools/resave_<thing>.gd
extends SceneTree
const PATHS := [
    "res://art/models/<new>/thing.mesh",
    "res://art/models/<new>/thing.material",
]
func _initialize() -> void:
    var failed := 0
    for p in PATHS:
        var res := ResourceLoader.load(p, "", ResourceLoader.CACHE_MODE_IGNORE)
        if res == null: push_error("[resave] load failed: %s" % p); failed += 1; continue
        res.resource_path = p
        var err := ResourceSaver.save(res, p, ResourceSaver.FLAG_COMPRESS)
        if err != OK: push_error("[resave] save failed (%d): %s" % [err, p]); failed += 1; continue
        print("[resave] ok: ", p)
    quit(0 if failed == 0 else 1)
```

## 3.4 模式 B — 临时垫片 + 重保存

当二进制文件内部引用了已移动的依赖，Godot 拒绝加载它时：

```gdscript
# tools/resave_<thing>.gd
extends SceneTree

const DEP_NEW := "res://art/models/<new>/material.material"
const DEP_OLD := "res://old/path/material.material"
const DEP_OLD_DIR := "res://old/path"
const BINARY := "res://art/models/<new>/mesh_with_dep.mesh"

func _initialize() -> void:
    var dep := ResourceLoader.load(DEP_NEW, "", ResourceLoader.CACHE_MODE_REUSE)
    if dep == null: push_error("cannot load dep at %s" % DEP_NEW); quit(1); return

    # 1. 临时复制依赖到旧路径，让二进制文件的陈旧引用能解析
    var da := DirAccess.open("res://")
    var old_dir_rel := DEP_OLD_DIR.replace("res://", "")
    if not DirAccess.dir_exists_absolute(ProjectSettings.globalize_path(DEP_OLD_DIR)):
        da.make_dir_recursive(old_dir_rel)
    if da.copy(DEP_NEW, DEP_OLD) != OK: push_error("temp copy failed"); quit(1); return

    # 2. 加载二进制文件并重新赋值
    var mesh := ResourceLoader.load(BINARY, "", ResourceLoader.CACHE_MODE_IGNORE) as ArrayMesh
    if mesh != null:
        for i in mesh.get_surface_count():
            mesh.surface_set_material(i, dep)
        mesh.resource_path = BINARY
        ResourceSaver.save(mesh, BINARY, ResourceSaver.FLAG_COMPRESS)
        print("[resave] ok: ", BINARY)

    # 3. 清理临时垫片
    da.remove(DEP_OLD)
    quit(0)
```

## 3.5 术后检查清单

```bash
# 1. 确认没有残留的旧路径
grep -rln '<old-path-fragment>' . --exclude-dir='.godot'

# 2. 无头模式加载测试
"$GODOT" --headless --path . --script tools/_smoke.gd 2>&1 | grep -E 'ERROR|OK:'

# 3. 重新打开编辑器，检查错误面板
```

## 3.6 关键陷阱

- **不要二进制 sed**：新旧路径长度不同会破坏文件（Godot 使用 Pascal 风格长度前缀）
- **不要忘记 `FLAG_COMPRESS`**：否则文件膨胀 3-5 倍
- **`CACHE_MODE_IGNORE` vs `REUSE`**：要修改的资源用 IGNORE，依赖用 REUSE

---

# §4 数据驱动配置

> **来源**: godot-data-driven-config
> **目标**: 将硬编码常量提取为设计师可编辑的 `.tres` 配置

## 4.1 文件布局

```
res://data/
├── specs/                       # JSON spec，唯一真实来源（git 追踪）
│   ├── weapon.spec.json
│   └── ...
├── resources/
│   ├── <name>_data.gd           # class_name <Name>Data extends Resource
│   └── data_manager.gd          # Autoload（自动生成，勿手动编辑 AUTOGEN 区域）
├── <name>s/                     # 复数目录，每个条目一个 .tres
│   └── default_<name>.tres
tools/
├── validate_data.gd             # Godot 端 CLI 验证器
└── validate_data.sh             # bash 封装
```

## 4.2 工作流程

### Step 1 — 发现与提议

1. 读取目标 `.gd` 文件，收集硬编码常量
2. 询问用户类别（weapon/enemy/player/level/skill 等）
3. 输出字段映射表，确认后继续

### Step 2 — 编写 Spec JSON

```json
{
  "name": "weapon",
  "default_id": "default_pistol",
  "fields": [
    { "key": "id", "type": "StringName", "default": "&\"\"", "group": "Identity" },
    { "key": "damage", "type": "int", "default": 10, "range": [0, 9999, 1] }
  ],
  "validators": ["damage >= 0"]
}
```

### Step 3 — 运行 scaffold 脚本

```bash
python <skill_dir>/scripts/scaffold.py \
    --project-root <abs Godot project path> \
    --spec <abs path to spec>.spec.json
```

脚本自动：
- 复制 spec 到 `data/specs/`
- 生成 `<name>_data.gd` Resource 类
- 生成 `default_<name>.tres`
- **重建** `data_manager.gd`（汇总所有 spec）
- **重建** `tools/validate_data.gd`
- 自动在 `project.godot` 添加 Autoload

### Step 4 — 迁移消费者代码

```gdscript
@export var weapon_data: WeaponData

func _ready() -> void:
    if weapon_data == null:
        weapon_data = DataManager.get_weapon()
    # 替换硬编码: JUMP_SPEED → weapon_data.jump_speed
```

### Step 5 — 验证

```bash
bash tools/validate_data.sh
# exit 0 = OK
```

## 4.3 硬规则

- **一个类别一个 Resource 类**，不要造神类
- 数值字段必须有 `@export_range`
- 每个 `<Name>Data` 必须有 `id: StringName` 字段
- `DataManager` 必须是 Autoload
- 不要在运行时修改 Resource（共享引用）→ 用 `data.duplicate()`
- 不要手动编辑 `# region *_AUTOGEN` 块

---

# §5 .tres 资源文件格式

> **来源**: godot-tres-format

## 5.1 基本结构

```
[gd_resource type="ResourceType" format=3 uid="uid://xxx"]

[resource]
property1 = value1
```

## 5.2 材质资源

```gdscript
# 基础材质
[gd_resource type="StandardMaterial3D" format=3]
[resource]
albedo_color = Color(0.8, 0.2, 0.2, 1)
roughness = 0.8
metallic = 0.0

# 金属材质
[gd_resource type="StandardMaterial3D" format=3]
[resource]
albedo_color = Color(0.9, 0.9, 0.9, 1)
roughness = 0.3
metallic = 0.9

# 发光材质
[gd_resource type="StandardMaterial3D" format=3]
[resource]
emission_enabled = true
emission = Color(1, 0.8, 0, 1)
emission_energy_multiplier = 3.0

# 透明材质
[gd_resource type="StandardMaterial3D" format=3]
[resource]
transparency = 1
albedo_color = Color(0.2, 0.5, 1, 0.5)
```

## 5.3 环境资源

```gdscript
# 室外环境
[gd_resource type="Environment" format=3]
[resource]
background_mode = 1
background_color = Color(0.4, 0.6, 0.9, 1)
ambient_light_source = 2
ambient_light_color = Color(0.5, 0.5, 0.6, 1)
tonemap_mode = 2
ssao_enabled = true
glow_enabled = true

# 带天空盒
[gd_resource type="Environment" load_steps=2 format=3]
[sub_resource type="Sky" id="Sky_001"]
sky_material = SubResource("ProceduralSkyMaterial_001")
[sub_resource type="ProceduralSkyMaterial" id="ProceduralSkyMaterial_001"]
sky_top_color = Color(0.3, 0.5, 0.9, 1)
[resource]
background_mode = 2
sky = SubResource("Sky_001")
```

## 5.4 其他常用资源

```gdscript
# 物理材质
[gd_resource type="PhysicsMaterial" format=3]
[resource]
friction = 0.8
bounce = 0.2

# 渐变
[gd_resource type="Gradient" format=3]
[resource]
offsets = PackedFloat32Array(0, 0.5, 1)
colors = PackedColorArray(1, 0, 0, 1, 1, 1, 0, 1, 0, 1, 0, 1)

# 样式盒
[gd_resource type="StyleBoxFlat" format=3]
[resource]
bg_color = Color(0.2, 0.2, 0.25, 1)
border_width_left = 2
corner_radius_top_left = 8

# ShaderMaterial（内联着色器）
[gd_resource type="ShaderMaterial" load_steps=2 format=3]
[sub_resource type="Shader" id="Shader_001"]
code = "shader_type spatial; void fragment() { ALBEDO = vec3(1.0, 0.0, 0.0); }"
[resource]
shader = SubResource("Shader_001")

# 简单位置动画
[gd_resource type="Animation" format=3]
[resource]
resource_name = "move_right"
length = 1.0
tracks/0/type = "value"
tracks/0/path = NodePath(".:position")
tracks/0/keys = {"times": PackedFloat32Array(0, 1), "values": [Vector3(0,0,0), Vector3(5,0,0)]}
```

## 5.5 资源类型速查

| 类型 | 用途 |
|------|------|
| `StandardMaterial3D` | 3D 材质 |
| `CanvasItemMaterial` | 2D 材质 |
| `ShaderMaterial` | 自定义着色器材质 |
| `Environment` | 环境设置 |
| `PhysicsMaterial` | 物理材质 |
| `Gradient` | 渐变 |
| `Curve` | 曲线 |
| `StyleBoxFlat` | UI 样式盒 |
| `ParticleProcessMaterial` | 粒子材质 |
| `Animation` | 动画 |
| `FontVariation` | 字体变体 |

---

# §6 .tscn 场景文件格式

> **来源**: godot-tscn-format

## 6.1 基本结构

```
[gd_scene load_steps=N format=3 uid="uid://xxx"]

[ext_resource type="Type" path="res://..." id="ID"]
[sub_resource type="Type" id="ID"]

[node name="Root" type="Node3D"]

[node name="Child" type="Type" parent="."]

[connection signal="sig" from="Node" to="Target" method="func"]
```

`load_steps = ext_resource 数 + sub_resource 数 + 1`

## 6.2 外部资源引用

```
[ext_resource type="Script" path="res://scripts/player.gd" id="1_script"]
[ext_resource type="PackedScene" path="res://scenes/enemy.tscn" id="2_enemy"]
[ext_resource type="Texture2D" path="res://textures/icon.png" id="3_texture"]
```

## 6.3 内嵌资源

```gdscript
# 碰撞形状
[sub_resource type="CapsuleShape3D" id="CapsuleShape3D_player"]
radius = 0.35
height = 1.8

[sub_resource type="RectangleShape2D" id="RectangleShape2D_001"]
size = Vector2(32, 32)

# 网格
[sub_resource type="BoxMesh" id="BoxMesh_001"]
size = Vector3(1, 1, 1)

[sub_resource type="SphereMesh" id="SphereMesh_001"]
radius = 0.5

# 内嵌材质
[sub_resource type="StandardMaterial3D" id="Material_red"]
albedo_color = Color(1, 0, 0, 1)
```

## 6.4 节点声明

```
# 根节点
[node name="Player" type="CharacterBody3D"]
script = ExtResource("1_script")

# 子节点
[node name="CollisionShape3D" type="CollisionShape3D" parent="."]
shape = SubResource("CapsuleShape3D_player")

# 实例化场景
[node name="Enemy1" parent="Enemies" instance=ExtResource("2_enemy")]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 5, 0, -10)
```

## 6.5 Transform 格式

```
# 3D 单位变换
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0)
# 仅位置
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 5, 2, -10)
# 缩放 0.5
transform = Transform3D(0.5, 0, 0, 0, 0.5, 0, 0, 0, 0.5, 5, 2, -10)

# 2D
transform = Transform2D(1, 0, 0, 1, 100, 200)     # 单位
transform = Transform2D(0.707, 0.707, -0.707, 0.707, 100, 200)  # 旋转45°
```

## 6.6 信号连接

```
[connection signal="timeout" from="ShootCooldown" to="." method="_on_shoot_cooldown_timeout"]
[connection signal="body_entered" from="HitArea" to="." method="_on_hit_area_body_entered"]
```

## 6.7 完整示例

```gdscript
# 3D 角色
[gd_scene load_steps=3 format=3]
[ext_resource type="Script" path="res://scripts/player.gd" id="1_script"]
[sub_resource type="CapsuleShape3D" id="CapsuleShape3D_001"]
radius = 0.35
height = 1.8
[node name="Player" type="CharacterBody3D"]
script = ExtResource("1_script")
[node name="CollisionShape3D" type="CollisionShape3D" parent="."]
transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0.9, 0)
shape = SubResource("CapsuleShape3D_001")

# 2D 角色
[gd_scene load_steps=3 format=3]
[ext_resource type="Script" path="res://scripts/player_2d.gd" id="1_script"]
[ext_resource type="Texture2D" path="res://sprites/player.png" id="2_texture"]
[sub_resource type="RectangleShape2D" id="RectangleShape2D_001"]
size = Vector2(32, 48)
[node name="Player" type="CharacterBody2D"]
script = ExtResource("1_script")
[node name="Sprite2D" type="Sprite2D" parent="."]
texture = ExtResource("2_texture")
```

## 6.8 常用节点类型速查

| 类别 | 3D | 2D |
|------|-----|-----|
| 基础 | Node3D | Node2D |
| 角色 | CharacterBody3D | CharacterBody2D |
| 刚体 | RigidBody3D | RigidBody2D |
| 静态体 | StaticBody3D | StaticBody2D |
| 碰撞形状 | CollisionShape3D | CollisionShape2D |
| 网格/精灵 | MeshInstance3D | Sprite2D |
| 相机 | Camera3D | Camera2D |
| 灯光 | DirectionalLight3D, OmniLight3D | PointLight2D |

---

# §7 GDScript 工具函数库

> **来源**: godot-utils

## 7.1 数学工具

```gdscript
class_name MathUtils

static func lerp_clamped(from: float, to: float, weight: float) -> float:
    return lerpf(from, to, clampf(weight, 0.0, 1.0))

static func smooth_damp(current: float, target: float, velocity: float, smooth_time: float, delta: float) -> Array:
    var omega := 2.0 / smooth_time
    var x := omega * delta
    var exp_factor := 1.0 / (1.0 + x + 0.48 * x * x + 0.235 * x * x * x)
    var change := current - target
    var temp := (velocity + omega * change) * delta
    var new_velocity := (velocity - omega * temp) * exp_factor
    var new_value := target + (change + temp) * exp_factor
    return [new_value, new_velocity]

static func remap(value: float, from_min: float, from_max: float, to_min: float, to_max: float) -> float:
    return to_min + (value - from_min) * (to_max - to_min) / (from_max - from_min)

static func normalize_angle(degrees: float) -> float:  # → [-180, 180]
static func approx_equal(a: float, b: float, epsilon := 0.0001) -> bool:
static func positive_mod(a: int, b: int) -> int:  # 结果总为正
```

## 7.2 向量工具

```gdscript
class_name VectorUtils
static func smooth_damp_v2/v3(...) -> Array       # Vector2/3 平滑阻尼
static func perpendicular_cw(v: Vector2) -> Vector2  # 顺时针垂直
static func perpendicular_ccw(v: Vector2) -> Vector2 # 逆时针垂直
static func world_to_top_down(world_pos: Vector3) -> Vector2
static func closest_point_on_segment(...) -> Vector2
static func clamp_length(v: Vector2, max_length: float) -> Vector2
```

## 7.3 随机工具

```gdscript
class_name RandomUtils
static func pick(arr: Array) -> Variant                         # 随机选一个
static func pick_n(arr: Array, n: int) -> Array                  # 随机选 N 个不重复
static func pick_weighted(items: Array, weights: Array[float])   # 带权重随机
static func random_in_circle(radius := 1.0) -> Vector2           # 单位圆内
static func random_on_circle(radius := 1.0) -> Vector2           # 圆环上
static func random_in_sphere(radius := 1.0) -> Vector3           # 球体内
static func random_gaussian(mean := 0.0, std_dev := 1.0) -> float # 正态分布
static func random_color_hsv(...) -> Color                       # 好看随机色
```

## 7.4 时间工具

```gdscript
class_name TimeUtils
static func format_time_mmss(total_seconds: float) -> String
static func create_timer(node: Node, duration: float, callback: Callable) -> SceneTreeTimer
static func wait(node: Node, duration: float) -> Signal
```

## 7.5 字符串工具

```gdscript
class_name StringUtils
static func capitalize_first(s: String) -> String
static func snake_to_pascal(s: String) -> String
static func pascal_to_snake(s: String) -> String
static func truncate(s: String, max_length: int, suffix := "...") -> String
static func format_number(n: int, separator := ",") -> String   # 千位分隔
```

## 7.6 数组工具

```gdscript
class_name ArrayUtils
static func find(arr: Array, predicate: Callable) -> Variant
static func filter/map/reduce(arr: Array, ...) -> Array
static func sum/average/max_value/min_value(arr: Array) -> Variant
static func unique(arr: Array) -> Array
static func chunk(arr: Array, size: int) -> Array[Array]
static func flatten(arr: Array) -> Array
static func difference/intersection(a: Array, b: Array) -> Array
static func all/any/count(arr: Array, predicate: Callable)
```

## 7.7 节点工具

```gdscript
class_name NodeUtils
static func find_child_of_type(node: Node, type: GDScript) -> Node
static func find_children_of_type(node: Node, type: GDScript) -> Array[Node]
static func safe_free(node: Node) -> void
static func reparent_keep_global(node: Node3D, new_parent: Node) -> void
static func reparent_keep_global_2d(node: Node2D, new_parent: Node) -> void
static func set_process_recursive(node: Node, enabled: bool) -> void
static func remove_all_children(node: Node) -> void
```

## 7.8 文件工具

```gdscript
class_name FileUtils
static func read_json(path: String) -> Variant
static func write_json(path: String, data: Variant, indent := "\t") -> bool
static func list_files(dir_path: String, recursive := false, extension := "") -> PackedStringArray
static func ensure_dir(path: String) -> bool
```

## 7.9 调试工具

```gdscript
class_name DebugUtils
static func log(message: String) -> void           # 带时间戳
static func timer_start/end(name: String) -> void  # 性能计时
static func draw_debug_point/canvas: CanvasItem, pos: Vector2, ...)
static func draw_debug_arrow(canvas: CanvasItem, from: Vector2, to: Vector2, ...)
```

## 7.10 缓动工具

```gdscript
class_name EaseUtils
static func ease_in/out/in_out_quad(t: float) -> float
static func ease_in/out_cubic(t: float) -> float
static func ease_in/out_elastic(t: float) -> float
static func ease_in/out_bounce(t: float) -> float
static func apply(from: float, to: float, t: float, ease_func: Callable) -> float
static func apply_color(from: Color, to: Color, t: float, ease_func: Callable) -> Color
```

---

# §8 MCP 连接管理

## 8.1 连接检测

每次调用 Godot 相关功能前，先检测 MCP 连接状态：

```
用户请求 → 检测 MCP 连接
  ├─ [连接正常] → 继续处理
  └─ [连接失败] → 启动 MCP 服务器 → 重试 → 继续处理
       └─ [启动失败] → 报告错误
```

## 8.2 严格约束

- **仅使用 MCP 工具**：所有 Godot 编辑器的操作通过 `mcp__tomyud1-godot-mcp__*` 工具
- **禁止直接文件操作**：不能直接读写 .tscn/.gd/.tres 文件（格式参考可以向 AI 提供知识，但实际写操作通过 MCP）
- **安全优先**：确保项目数据安全

---

# §9 安全文件操作规范（血泪教训版）

> **来源**: safe-file-operations
> **优先级**: ⚠️ 关键 — 所有涉及终端删除操作的场景必须先过此节

## 9.1 事故回顾

2026年4月19日，在执行 `rd /s /q` 命令清理编译输出目录时，由于 **PowerShell 与 cmd 语法混淆**，命令被错误解析，导致 **整个项目目录被递归删除**：
- `.git/` — 版本历史全部丢失
- 所有源码、配置、脚本一次性清零

**整个项目从有到无，不可逆转。**

## 9.2 🔴 绝对禁止（NEVER DO）

### ❌ 禁止使用递归删除命令
- `rd /s /q`、`rm -rf`、`Remove-Item -Recurse -Force`
- PowerShell 中 `rd` 是 `Remove-Item` 的别名，行为与 cmd 不完全相同，语法混淆会导致灾难

### ❌ 禁止在项目根目录附近执行递归删除
- 哪怕目标是子目录，一个路径解析错误（空格、变量为空）就会删掉整个项目

### ❌ 禁止先删后建的文件操作模式
- 不要 `delete` + `write`，直接 `write_to_file` 覆盖即可（覆盖本身就是覆盖语义）

## 9.3 🟢 正确做法（ALWAYS DO）

### 清理编译输出
- 用 IDE 的 clean 命令
- 手动删除目录下的文件（不要删目录本身）
- 如果必须用命令：**先 `ls` / `dir` 确认目标内容**

### 安全删除目录
1. **先 `ls` / `dir` 列出内容**，确认是预期的目标
2. **只删除文件，不删除目录结构**（如 `del /q out\*.js` 而非 `rd /s /q out`）
3. **使用 IDE 工具** 逐个删除，而非批量终端命令
4. **绝不在包含 .git 的目录层级使用递归删除**

### 文件修改规范
| 操作 | 正确做法 |
|------|---------|
| 修改 | `replace_in_file`（精确替换） |
| 重写 | `write_to_file`（自动覆盖） |
| 新建 | `write_to_file` |
| 删除 | `delete_file`（仅限确实要移除的文件） |

## 9.4 ⚠️ Shell 陷阱提醒

| 场景 | 危险 | 安全替代 |
|------|------|----------|
| 清理 out/ | `rd /s /q out` | `del /q out\*.js` 或 IDE 工具 |
| 清理 node_modules | `rd /s /q node_modules` | `npm ci` |
| PowerShell 中用 cmd 语法 | 命令被错误解析 | 确认当前 Shell 类型 |
| 路径含空格 | 未加引号导致截断 | 始终用引号包裹路径 |
| 变量拼接路径 | 变量为空则删根目录 | 先 echo 路径确认 |

## 9.5 🧠 核心原则

> **对破坏性操作保持极度偏执。**
> 宁可多花 10 秒确认，也不要花 10 小时恢复。
> 如果一个操作可能删除用户代码，就假设它**一定会**出错。
> **能用 IDE 工具完成的事，绝不用终端命令。**

## 9.6 执行危险操作前检查清单

- [ ] 我确认了当前 Shell 是 PowerShell 还是 cmd？
- [ ] 我确认了目标路径是正确的（不是父目录）？
- [ ] 这个操作如果出错，最坏后果是什么？
- [ ] 有没有更安全的替代方案（IDE 工具）？
- [ ] 项目是否有 git 提交/远程备份可以恢复？
- [ ] 我是否可以用 `replace_in_file` 或 `write_to_file` 代替终端操作？

---

# 技能目录结构

```
godot-skills/
├── SKILL.md                    # 本文件 — 统一技能定义
├── scripts/                    # 数据驱动配置的 scaffold 脚本
│   └── scaffold.py
│   └── selftest.sh
├── templates/                  # 数据驱动配置的模板
├── schemas/                    # Spec JSON schema
└── examples/                   # 示例 spec
```
