# SeuratV5 单细胞环境安装 Skill

这是一个用于 Codex 的单细胞转录组环境安装 skill，面向 Windows 上的 Seurat V5 全流程课程代码。它的目标不是重写分析流程，而是根据课程配套代码中已经出现的脚本和安装清单，整理出可复用的环境需求、PATH 配置、R 包安装、Python/Conda 环境安装和环境检查脚本。

## 项目定位

本项目适用于以下场景：

- 为 Seurat V5 单细胞课程代码准备 R 4.4.x 运行环境。
- 自动补充 `Rscript`、Rtools44、Git gzip、Conda、JAGS 等工具的 PATH。
- 按课程脚本需求安装 CRAN、Bioconductor、GitHub 和课程本地 `tar.gz` R 包。
- 创建供 `reticulate`、API 调用或 scverse 辅助流程使用的 Conda Python 环境。
- 在正式跑分析前生成环境检查报告，确认缺失的软件和包。

## 目录结构

```text
seuratv5-env-requirements/
├─ SKILL.md
├─ README.md
├─ agents/
│  └─ openai.yaml
├─ references/
│  ├─ path-setup.md
│  └─ requirements.md
└─ scripts/
   ├─ check_environment.ps1
   ├─ extract_course_requirements.ps1
   ├─ install_environment.ps1
   ├─ install_python_env.ps1
   └─ install_r_packages.R
```

## 依赖来源

依赖清单来自本地 Seurat V5 课程配套代码目录中的 35 个 `.r` / `.R` 脚本，以及课程自带的 `2.R包安装` 安装脚本和本地包归档。脚本会在未显式传入 `-CourseRoot` 时，从 `F:\0000-*` 下搜索课程本地包 `monocle_xxdchange.tar.gz`，再反推课程根目录，避免在脚本中硬编码中文路径。

## 快速检查

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\check_environment.ps1 `
  -Rscript "E:\R-4.4.2\bin\Rscript.exe" `
  -CondaEnv "seuratv5-course-py"
```

检查报告会写到当前目录下的 `seuratv5_environment_check/<timestamp>/`。

## 一键配置环境

只配置 PATH 并做检查：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\install_environment.ps1 `
  -RHome "E:\R-4.4.2"
```

安装 R 包和 Python 环境：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\install_environment.ps1 `
  -RHome "E:\R-4.4.2" `
  -InstallRPackages `
  -InstallPythonEnv
```

如果自动扫描不到课程目录，可以显式传入：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\scripts\install_environment.ps1 `
  -CourseRoot "F:\0000-单细胞转录组\05_SeuratV5全流程视频及配套代码\SeuratV5全流程配套代码\单细胞V5" `
  -RHome "E:\R-4.4.2" `
  -InstallRPackages `
  -InstallPythonEnv
```

## 主要脚本

- `install_environment.ps1`: 总入口，负责 PATH、R 包安装、Python 环境安装和最终检查。
- `install_r_packages.R`: 根据课程需求安装 CRAN、Bioconductor、GitHub 和本地 R 包。
- `install_python_env.ps1`: 创建 `seuratv5-course-py` Conda 环境并安装 Python 包。
- `check_environment.ps1`: 检查 Rscript、Rtools、gzip、Conda、课程本地包、R 包和 Python 包。
- `extract_course_requirements.ps1`: 从课程 R 脚本中重新提取 `library()`、`require()` 和 `::` 包引用。

## 设计原则

- 优先复用课程配套代码中的安装思路，不重新发明单细胞分析流程。
- 默认检查和补 PATH，只有显式传入安装参数时才执行大规模包安装。
- 安装来源分层：CRAN、Bioconductor、GitHub、课程本地归档。
- 保留可审计报告，方便定位缺包、编译器、JAGS、Conda 环境等问题。

## 注意事项

- 大规模 R 包安装可能耗时较长，GitHub 包还可能受网络和上游仓库变化影响。
- JAGS 不是所有流程都需要，但与 JAGS 链接的包报错时应先安装并重启终端。
- AI 注释脚本可能需要 Moonshot/Kimi、DeepSeek 等 API key，请不要把密钥写进仓库。
- 课程数据、矩阵文件、临床信息和分析输出不应提交到本项目仓库。
