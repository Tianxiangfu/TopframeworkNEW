# TopOptFrameC - 智能体上下文文档

## 项目概述

**TopOptFrameC** 是一个基于 C++17 开发的拓扑优化可视化框架，采用节点编辑器（Node Editor）的交互方式让用户通过可视化流程图构建和运行结构拓扑优化任务。

### 主要技术栈

| 组件 | 技术/库 | 用途 |
|------|---------|------|
| 构建系统 | CMake 3.20+ | 跨平台构建管理 |
| 图形界面 | Dear ImGui v1.91.8 | 即时模式GUI |
| 节点编辑器 | imnodes v0.5 | 可视化节点图编辑 |
| 窗口/渲染 | GLFW 3.4 + OpenGL 3 | 窗口管理和3D渲染 |
| 线性代数 | Eigen 3.4 | 矩阵运算和有限元求解 |
| 序列化 | nlohmann/json | 项目文件保存/加载 |

### 架构概览

```
┌─────────────────────────────────────────────────────────────┐
│                      Application                           │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐   │
│  │NodeList  │  │NodeEditor│  │Property  │  │View3D    │   │
│  │Panel     │  │          │  │Panel     │  │Panel     │   │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘   │
│        │             │             │             │         │
│        └─────────────┴─────────────┴─────────────┘         │
│                          │                                 │
│                   GraphExecutor                          │
│        (节点图执行引擎 - 拓扑排序执行)                      │
│                          │                                 │
│  ┌───────────────────────┼───────────────────────┐        │
│  │                       │                       │        │
│  ▼                       ▼                       ▼        │
│ FEMSolver            TopOptSolver            PostProcess  │
│ (有限元求解)          (SIMP/BESO优化)          (后处理)    │
└─────────────────────────────────────────────────────────────┘
```

## 项目结构

```
D:\Desktop\code\TopOptFrame\
├── CMakeLists.txt          # 主CMake配置
├── CMakePresets.json       # CMake预设(Debug/Release)
├── src/
│   ├── main.cpp            # 程序入口
│   ├── app/
│   │   ├── Application.h/cpp    # 主应用类，管理所有面板和窗口
│   ├── node_editor/
│   │   ├── Node.h               # 节点数据结构定义
│   │   ├── NodeEditor.h/cpp     # 节点编辑器核心
│   │   ├── NodeRegistry.cpp     # 内置节点类型注册(30+节点类型)
│   ├── execution/
│   │   ├── GraphExecutor.h/cpp  # 节点图执行引擎
│   │   ├── NodeData.h           # 节点数据类型定义
│   ├── fem/
│   │   ├── FEMSolver.h/cpp      # 有限元求解器
│   │   ├── TopOptSolver.h/cpp   # 拓扑优化求解器(SIMP/BESO)
│   ├── panels/
│   │   ├── NodeListPanel.h/cpp  # 左侧节点列表面板
│   │   ├── PropertyPanel.h/cpp  # 右侧属性面板
│   │   ├── View3DPanel.h/cpp    # 3D视图面板
│   │   ├── LogPanel.h/cpp       # 日志面板
│   │   ├── ModulePanel.h/cpp    # 模块面板
│   ├── commands/
│   │   ├── Command.h/cpp        # 命令模式基类
│   │   ├── NodeCommands.h/cpp   # 节点操作命令(撤销/重做)
│   ├── serialization/
│   │   ├── ProjectSerializer.h/cpp  # 项目序列化(JSON)
│   └── utils/
│       ├── Logger.h             # 日志工具
│       └── FileDialog.h/cpp     # 文件对话框
├── model/                  # 示例3D模型文件
│   ├── *.obj, *.stl        # 动物、几何体等模型
└── third_party/glad/       # OpenGL加载器
```

## 节点类型体系

系统内置 **30+** 种节点类型，按功能分为7大类：

### 1. Input 节点 (输入)
- `input-number` - 数字输入
- `input-vector` - 3D向量输入
- `input-boolean` - 布尔输入
- `input-file` - 文件输入

### 2. Output 节点 (输出)
- `output-display` - 数据显示
- `output-export` - 文件导出
- `output-viewer` - 3D可视化

### 3. Domain 节点 (域定义)
- `domain-box` - 长方体域 (Hex8单元)
- `domain-lshape` - L型域
- `domain-from-mesh` - 从表面网格转换
- `domain-import` - 导入外部FE网格

### 4. FEA 节点 (有限元分析)
- `fea-material` - 各向同性材料定义
- `fea-fixed-support` - 固定支撑约束
- `fea-displacement-bc` - 位移边界条件
- `fea-point-force` - 集中力载荷
- `fea-pressure-load` - 压力载荷
- `fea-body-force` - 体积力(重力)
- `fea-load-case` - 载荷工况组合
- `fea-solver` - FEA求解器

### 5. Topology 节点 (拓扑优化)
- `topo-simp` - SIMP优化器
- `topo-beso` - BESO优化器
- `topo-constraint` - 设计约束(对称性/最小尺寸等)
- `topo-passive-region` - 非设计区域标记

### 6. PostProcess 节点 (后处理)
- `post-density-view` - 密度场等值面提取
- `post-extract-field` - 结果场提取(应力/位移等)
- `post-convergence` - 收敛曲线显示
- `post-export` - 结果导出

### 7. Data 节点 (数据)
- `data-mesh-gen` - 基础几何体生成

## 数据类型系统

节点间通过强类型端口连接，支持的数据类型：

```cpp
// 基础类型
Number, Vector, Boolean, String, Mesh, Field

// FEA专用类型
FEMesh          // 有限元网格(节点+单元)
Material        // 材料属性(E, nu, rho)
BoundaryCondition // 边界条件
LoadCase        // 载荷工况
FEResult        // 有限元结果(位移/应力/应变能)
DensityField    // 密度场(优化结果)
```

## 构建与运行

### 环境要求
- Windows 10/11
- Visual Studio 2019 或更高版本
- CMake 3.20+

### 构建步骤

```powershell
# 1. 配置项目 (Debug模式)
cmake --preset debug

# 2. 构建项目
cmake --build build --config Debug

# 3. 运行程序
.\build\Debug\TopOptFrameC.exe
```

或手动使用 CMake GUI/命令行：

```powershell
cd build
cmake .. -G "Visual Studio 16 2019" -A x64
cmake --build . --config Release
```

### VS Code 开发
项目已配置 `.vscode/` 目录，包含：
- `tasks.json` - 构建任务
- `launch.json` - 调试配置
- `settings.json` - C++ IntelliSense 设置

## 核心功能说明

### 1. 节点编辑器 (NodeEditor)
- 基于 `imnodes` 的可视化节点图编辑
- 支持拖拽创建节点、连接端口
- 自动类型检查（仅允许兼容类型连接）
- 支持多选、复制、粘贴、删除

### 2. 执行引擎 (GraphExecutor)
- 使用 **Kahn算法** 进行拓扑排序
- 支持三种执行模式：
  - `runAll()` - 执行全部节点
  - `stepOne()` - 单步执行
  - `previewNode()` - 实时预览选中节点
- 自动缓存中间结果避免重复计算

### 3. 拓扑优化求解器
- **SIMP** (Solid Isotropic Material with Penalization)
  - 体积分数控制
  - 密度/灵敏度过滤
  - OC优化准则
- **BESO** (Bi-directional Evolutionary Structural Optimization)
  - 渐进式进化率
  - 双向增删材料

### 4. 3D可视化 (View3DPanel)
- OpenGL 3.3 渲染
- 支持模型：STL, OBJ
- 相机控制：旋转/平移/缩放
- 显示模式：线框/实体/网格

### 5. 项目序列化
- JSON 格式存储节点图结构
- 保存/加载节点位置、连接、参数
- 相机视角状态持久化

## 开发约定

### 代码风格
- 命名空间: `TopOpt`
- 类名: PascalCase (如 `GraphExecutor`)
- 成员变量: 下划线后缀 (如 `editor_`)
- 私有方法: camelCase

### 添加新节点类型
在 `NodeRegistry::registerBuiltinTypes()` 中添加：

```cpp
registerType({
    "type-id", "Display Name", "Category", "Icon", "Description",
    headerColor,
    { /* inputs */ },
    { /* outputs */ },
    { /* parameters */ }
});
```

然后在 `GraphExecutor` 中添加对应的执行函数。

### 撤销/重做系统
所有节点操作通过 `Command` 模式实现：
- `AddNodeCommand`
- `DeleteNodeCommand`
- `ConnectCommand`
- `MoveNodeCommand`

## 常用操作快捷键

| 快捷键 | 功能 |
|--------|------|
| Ctrl+N | 新建项目 |
| Ctrl+O | 打开项目 |
| Ctrl+S | 保存项目 |
| Ctrl+Z | 撤销 |
| Ctrl+Y | 重做 |
| Delete | 删除选中节点 |
| F5 | 执行全部节点 |
| F10 | 单步执行 |

## 依赖库获取方式

所有依赖通过 CMake `FetchContent` 自动下载：
- GLFW: `https://github.com/glfw/glfw.git`
- ImGui: `https://github.com/ocornut/imgui.git`
- imnodes: `https://github.com/Nelarius/imnodes.git`
- nlohmann/json: `https://github.com/nlohmann/json.git`
- Eigen: `https://gitlab.com/libeigen/eigen.git`

首次构建时会自动克隆这些仓库。

## 典型工作流程

1. **创建域**: Domain → Box Domain / L-Shape Domain
2. **定义材料**: FEA → Isotropic Material
3. **施加约束**: FEA → Fixed Support
4. **施加载荷**: FEA → Point Force / Pressure Load
5. **组合载荷**: FEA → Load Case
6. **运行优化**: Topology → SIMP Optimizer
7. **查看结果**: PostProcess → Density View / 3D Viewer
8. **导出结果**: PostProcess → Export Results

---
*文档生成日期: 2026-03-10*
*项目版本: 0.1.0*
