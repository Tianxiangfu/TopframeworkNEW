# TopOptFrameC - 拓扑优化可视化框架

[![C++17](https://img.shields.io/badge/C++-17-blue.svg)](https://isocpp.org/)
[![CMake](https://img.shields.io/badge/CMake-3.20+-green.svg)](https://cmake.org/)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

**TopOptFrameC** 是一个基于 C++17 开发的结构拓扑优化可视化框架，采用节点编辑器（Node Editor）的交互方式，让用户通过拖拽和连接可视化节点来构建和运行拓扑优化任务，无需编写代码即可完成复杂的结构优化设计。

![界面预览](docs/images/ui_preview.png)

---

## 目录

- [核心功能](#核心功能)
- [系统要求](#系统要求)
- [安装与构建](#安装与构建)
- [快速入门](#快速入门)
- [节点类型详解](#节点类型详解)
- [示例工作流](#示例工作流)
- [文件操作](#文件操作)
- [快捷键](#快捷键)
- [故障排查](#故障排查)
- [技术栈](#技术栈)

---

## 核心功能

### 可视化节点编程
- **30+ 内置节点类型**，涵盖从几何建模到优化结果可视化的完整流程
- **拖拽式操作**，通过连接节点端口构建工作流
- **实时预览**，选中节点即可在 3D 视图中查看结果
- **智能类型检查**，只允许兼容的数据类型连接

### 拓扑优化算法
- **SIMP** (Solid Isotropic Material with Penalization) - 密度法拓扑优化
- **BESO** (Bi-directional Evolutionary Structural Optimization) - 双向渐进优化
- 支持多种过滤方法（密度过滤、灵敏度过滤）
- 可设置体积分数、惩罚因子、过滤半径等参数

### 有限元分析 (FEA)
- **自动网格生成**：长方体、L型等参数化域
- **多种边界条件**：固定支撑、位移约束、集中力、压力载荷、体积力
- **材料定义**：各向同性材料（弹性模量、泊松比、密度）
- **多载荷工况**：支持多工况组合和加权

### 后处理与可视化
- **3D 实时渲染**：OpenGL 3.3 硬件加速
- **密度场可视化**：等值面提取、阈值调节
- **结果导出**：STL（3D打印）、VTK（科学可视化）格式
- **收敛曲线**：显示优化过程的历史记录

---

## 系统要求

### 最低配置
- **操作系统**：Windows 10/11 (64位)
- **处理器**：Intel Core i5 或同级 AMD 处理器
- **内存**：8 GB RAM
- **显卡**：支持 OpenGL 3.3 的独立显卡或核显
- **磁盘空间**：2 GB 可用空间

### 推荐配置
- **处理器**：Intel Core i7 / AMD Ryzen 7 及以上
- **内存**：16 GB RAM 及以上
- **显卡**：NVIDIA GTX 1060 / AMD RX 580 或更高

---

## 安装与构建

### 环境要求

1. **Visual Studio 2019 或更高版本**
   - 安装时勾选 "使用 C++ 的桌面开发"
   - 包含 CMake 工具

2. **CMake 3.20 或更高版本**
   - 下载地址：https://cmake.org/download/
   - 或直接使用 Visual Studio 自带的 CMake

3. **Git**（可选，用于克隆依赖）

### 构建步骤

#### 方法一：使用 CMake 命令行

```powershell
# 1. 进入项目目录
cd D:\Desktop\code\TopOptFrame

# 2. 创建构建目录
mkdir build
cd build

# 3. 配置项目（Visual Studio 2022）
cmake .. -G "Visual Studio 17 2022" -A x64

# 4. 构建 Debug 版本
cmake --build . --config Debug

# 5. 运行程序
.\Debug\TopOptFrameC.exe
```

#### 方法二：使用 Visual Studio

1. 打开 Visual Studio
2. 选择 "打开本地文件夹"
3. 选择项目根目录 `D:\Desktop\code\TopOptFrame`
4. Visual Studio 会自动识别 CMakeLists.txt
5. 点击 "生成" → "生成全部" (Ctrl+Shift+B)
6. 点击 "调试" → "开始执行" (Ctrl+F5)

#### 方法三：使用 VS Code

项目已配置 `.vscode` 目录，直接打开项目文件夹：

```powershell
code D:\Desktop\code\TopOptFrame
```

然后按 `F5` 调试运行。

### 首次构建说明

首次构建时会自动下载以下依赖（通过 CMake FetchContent）：
- GLFW 3.4（窗口管理）
- Dear ImGui 1.91.8（GUI）
- imnodes 0.5（节点编辑器）
- Eigen 3.4（矩阵运算）
- nlohmann/json 3.11（序列化）

下载和编译依赖可能需要 **5-15 分钟**，请耐心等待。

---

## 快速入门

### 界面布局

```
┌────────────────────────────────────────────────────────────────┐
│  [New] [Open] [Save] | [Undo] [Redo] | [Run] [Step] [Reset]   │  ← 工具栏
├────────┬───────────────┬───────────────┬───────────────────────┤
│        │               │               │                       │
│ 节点   │               │               │       属性            │
│ 列表   │    节点       │    3D         │       面板            │
│ (可选  │    编辑器     │    视图       │       (修改参数)      │
│  节点) │    (画布)     │               │                       │
│        │               │               │                       │
├────────┴───────────────┴───────────────┴───────────────────────┤
│  日志/状态栏                                                    │
└────────────────────────────────────────────────────────────────┘
```

### 第一个工作流：悬臂梁优化

#### 步骤 1：创建设计域

1. 在左侧面板找到 **Domain** 分类
2. 拖拽 **Box Domain** 到画布中央
3. 在右侧面板设置参数：
   - **LengthX**: 10（长度）
   - **LengthY**: 5（高度）
   - **LengthZ**: 1（厚度）
   - **ElemsX**: 20（X方向单元数）
   - **ElemsY**: 10（Y方向单元数）
   - **ElemsZ**: 1（Z方向单元数）

#### 步骤 2：定义边界条件

1. 拖拽 **Fixed Support** 到画布
2. 连接 **Box Domain** 的 `femesh` 输出到 **Fixed Support** 的 `femesh` 输入
3. 设置 **Fixed Support** 参数：
   - **SelectionMode**: Face
   - **Face**: X-（左端面固定）
   - **FixX/Y/Z**: true（三个方向都固定）

#### 步骤 3：施加载荷

1. 拖拽 **Point Force** 到画布
2. 连接 **Box Domain** 的 `femesh` 输出到 **Point Force** 的 `femesh` 输入
3. 设置 **Point Force** 参数：
   - **SelectionMode**: Face
   - **Face**: X+（右端面施加载荷）
   - **ForceY**: -1（向下施加单位力）

#### 步骤 4：定义材料

1. 拖拽 **Isotropic Material** 到画布
2. 参数保持默认（钢材）：
   - **E**: 210000（弹性模量，MPa）
   - **nu**: 0.3（泊松比）
   - **Density**: 7850（密度，kg/m³）

#### 步骤 5：组合载荷工况

1. 拖拽 **Load Case** 到画布
2. 连接：
   - **Fixed Support** 的 `bc` 输出 → **Load Case** 的 `BC 0` 输入
   - **Point Force** 的 `bc` 输出 → **Load Case** 的 `BC 1` 输入
3. 设置 **Name**: "LC1"

#### 步骤 6：运行拓扑优化

1. 拖拽 **SIMP Optimizer** 到画布
2. 连接：
   - **Box Domain** 的 `femesh` → **SIMP** 的 `FEMesh`
   - **Material** 的 `material` → **SIMP** 的 `Material`
   - **Load Case** 的 `loadcase` → **SIMP** 的 `LC 0`
3. 设置 **SIMP** 参数：
   - **VolFrac**: 0.4（保留40%材料）
   - **Penalty**: 3（惩罚因子）
   - **FilterR**: 1.5（过滤半径）
   - **MaxIter**: 100（最大迭代次数）

#### 步骤 7：可视化结果

1. 拖拽 **Density View** 到画布
2. 连接：
   - **SIMP** 的 `density` → **Density View** 的 `Density`
   - **Box Domain** 的 `femesh` → **Density View** 的 `FEMesh`
3. 设置 **Threshold**: 0.5（密度大于0.5显示为实体）

#### 步骤 8：执行

1. 点击工具栏的 **Run** 按钮（绿色）
2. 等待计算完成（约 10-30 秒，取决于网格密度）
3. 点击 **Density View** 节点选中它
4. 查看右侧 3D 视图中的优化结果

---

## 节点类型详解

### 1. Domain（域定义）- 黄色

| 节点 | 功能 | 输出 |
|------|------|------|
| **Box Domain** | 创建长方体设计域 | FEMesh |
| **L-Shape Domain** | 创建L型设计域 | FEMesh |
| **Mesh to FE Domain** | 将表面网格转为有限元域 | FEMesh |
| **Import FE Mesh** | 导入外部网格（VTK/INP） | FEMesh |

### 2. FEA（有限元分析）- 蓝色

| 节点 | 功能 | 输入 | 输出 |
|------|------|------|------|
| **Isotropic Material** | 定义各向同性材料 | - | Material |
| **Fixed Support** | 固定支撑约束 | FEMesh | BC |
| **Displacement BC** | 位移边界条件 | FEMesh | BC |
| **Point Force** | 集中力载荷 | FEMesh | BC |
| **Pressure Load** | 压力载荷 | FEMesh | BC |
| **Body Force** | 体积力（重力） | FEMesh | BC |
| **Load Case** | 组合载荷工况 | BC (x4) | LoadCase |
| **FEA Solver** | 有限元求解器 | FEMesh, Material, LoadCase | FEResult, FEMesh |

### 3. Topology（拓扑优化）- 紫色

| 节点 | 功能 | 输入 | 输出 |
|------|------|------|------|
| **SIMP Optimizer** | SIMP 拓扑优化 | FEMesh, Material, LoadCase (x3) | DensityField, FEResult |
| **BESO Optimizer** | BESO 渐进优化 | FEMesh, Material, LoadCase (x2) | DensityField, FEResult |
| **Design Constraint** | 设计约束（对称性/最小尺寸） | DensityField | DensityField |
| **Passive Region** | 非设计区域标记 | FEMesh | FEMesh |

### 4. PostProcess（后处理）- 绿色

| 节点 | 功能 | 输入 | 输出 |
|------|------|------|------|
| **Density View** | 密度场等值面提取 | DensityField, FEMesh | Mesh |
| **Extract Field** | 提取结果场（位移/应力） | FEResult | Field |
| **Convergence Plot** | 显示收敛曲线 | DensityField | - |
| **Export Results** | 导出结果（STL/VTK） | FEMesh, DensityField, FEResult | - |

### 5. Input/Output（输入输出）

| 节点 | 功能 |
|------|------|
| **Number Input** | 数字常量输入 |
| **Vector Input** | 3D 向量输入 |
| **Boolean Input** | 布尔值输入 |
| **File Input** | 从文件加载数据 |
| **Display** | 数据显示面板 |
| **File Export** | 导出数据到文件 |
| **3D Viewer** | 3D 可视化节点 |

---

## 示例工作流

### 示例 1：带孔板的优化

**场景**：在矩形板中心有一个圆孔，四周受拉力

**节点连接**：
```
Box Domain (20x10x1)
    ├── Fixed Support (X- 面固定)
    ├── Traction Load (X+ 面施加拉力)
    └── Material (Steel)
            ↓
    SIMP Optimizer (VolFrac=0.5)
            ↓
    Density View (Threshold=0.5)
```

### 示例 2：桥梁结构优化

**场景**：简支梁，中间施加载荷

**关键设置**：
- **Box Domain**: 长度 20，高度 3
- **Fixed Support**: X- 面（左支座）
- **Displacement BC**: X+ 面 Y向固定（右支座，允许水平移动）
- **Point Force**: 中点，向下 -10

### 示例 3：多载荷工况

**场景**：结构同时承受垂直和水平载荷

**节点连接**：
```
                    ┌─ Load Case 1 (重力)
Box Domain ─┬─ BC1 ─┤
            │       └─ Load Case 2 (风载)
            └─ BC2 ─┘
                        ↓
                SIMP Optimizer (LC0 + LC1)
```

---

## 文件操作

### 保存项目

**快捷键**: `Ctrl + S`

1. 首次保存会弹出文件对话框
2. 输入文件名（如 `cantilever.topopt`）
3. 点击保存

项目文件包含：
- 所有节点及其位置
- 节点参数设置
- 节点连接关系
- 3D 视图相机状态

### 打开项目

**快捷键**: `Ctrl + O`

1. 选择之前保存的 `.topopt` 文件
2. 项目会自动加载所有节点和设置

### 导出结果

**导出 STL（用于 3D 打印）**：
1. 添加 **Export Results** 节点
2. 连接 **Density View** 的 `mesh` 输出
3. 设置 **Format**: STL
4. 运行后自动导出

**导出 VTK（用于科学可视化）**：
- 设置 **Format**: VTK
- 可用 ParaView 打开查看详细结果

---

## 快捷键

### 文件操作
| 快捷键 | 功能 |
|--------|------|
| `Ctrl + N` | 新建项目 |
| `Ctrl + O` | 打开项目 |
| `Ctrl + S` | 保存项目 |

### 编辑操作
| 快捷键 | 功能 |
|--------|------|
| `Ctrl + Z` | 撤销 |
| `Ctrl + Y` | 重做 |
| `Delete` | 删除选中节点 |
| `Ctrl + A` | 全选节点 |

### 执行操作
| 快捷键 | 功能 |
|--------|------|
| `F5` | 运行全部节点 |
| `F10` | 单步执行 |
| `Esc` | 停止执行 |

### 视图操作
| 操作 | 功能 |
|------|------|
| 鼠标左键拖拽 | 平移画布/旋转3D视图 |
| 鼠标滚轮 | 缩放画布/3D视图 |
| 右键拖拽 | 平移3D视图 |

---

## 故障排查

### 问题 1：点击 Run 后程序卡住

**原因**：SIMP 计算量大，阻塞了 UI 线程

**解决方案**：
1. 减少网格密度（ElemsX/Y/Z 减半）
2. 减少最大迭代次数（MaxIter 从 200 改为 50）
3. 耐心等待 10-30 秒

### 问题 2：3D 视图没有显示结果

**原因**：需要选中节点才会更新视图

**解决方案**：
1. 点击 **Density View** 节点选中它
2. 或添加 **3D Viewer** 节点并连接 mesh 输出

### 问题 3：Save Project 没有反应

**原因**：文件对话框过滤器格式错误

**临时解决方案**：
1. 手动输入完整文件名（如 `project.topopt`）
2. 或等待后续版本修复

### 问题 4：节点连接失败

**原因**：端口数据类型不匹配

**检查**：
- 只能连接相同颜色的端口
- FEMesh（黄色）只能连接 FEMesh
- 查看端口标签确认类型

### 问题 5：优化结果全是蓝色（没有材料）

**原因**：
1. 边界条件和载荷设置冲突
2. 体积分数设置过低

**检查**：
- 确保 Fixed Support 和 Point Force 不在同一面
- VolFrac 建议 0.3-0.5

### 问题 6：编译失败

**检查**：
1. Visual Studio 是否安装了 "使用 C++ 的桌面开发"
2. CMake 版本是否 >= 3.20
3. 是否使用了 x64 平台（不是 Win32）

---

## 技术栈

| 组件 | 版本 | 用途 |
|------|------|------|
| C++ | 17 | 编程语言 |
| CMake | 3.20+ | 构建系统 |
| OpenGL | 3.3 | 3D 渲染 |
| GLFW | 3.4 | 窗口管理 |
| Dear ImGui | 1.91.8 | 图形用户界面 |
| imnodes | 0.5 | 节点编辑器 |
| Eigen | 3.4 | 矩阵运算/有限元求解 |
| nlohmann/json | 3.11 | 项目序列化 |

---

## 许可证

本项目采用 MIT 许可证。详见 [LICENSE](LICENSE) 文件。

---

## 更新日志

### v0.1.0 (2024-03-10)
- 初始版本发布
- 30+ 节点类型
- SIMP/BESO 拓扑优化
- 3D 可视化
- 项目保存/加载

---

## 联系方式

如有问题或建议，欢迎提交 Issue。

**项目地址**: https://github.com/Tianxiangfu/TopframeworkNEW
