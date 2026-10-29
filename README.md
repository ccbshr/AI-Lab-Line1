# AI-Lab 通识任务工作区

> 本仓库收录 AI-Lab 通识考核（Task 01–04）的交付物、学习笔记与配套脚本。
> 分支说明：本人分支 `zhangzechuan-ailab`，请勿直接改 `main`。

## 目录结构

```text
.
├── docs/                          # 个人技术笔记库（Task 02 要求的四类体系）
│   ├── README.md                  # 笔记索引
│   ├── 00-环境配置/                # 环境基线 + 一条命令复检
│   ├── 10-排错记录/                # 一次故障的完整闭环（现象→报错→根因→解决→验证）
│   ├── 20-代码实验/                # 假设 → 脚本 → 观测 → 结论
│   ├── 30-文献技术摘记/            # 技术对比与命令速查
│   └── 90-交付物/                  # Task03 / Task04 交付文档
├── review-demo/                   # 供「代码审查」练习的样例（含故意埋的缺陷）
├── assets/                        # 交付文档配图
├── AI-Lab 通识学习计划与环境踩坑记录.md    # Task02 交付物
├── AI-Lab-通识任务-操作与学习教程.md        # 操作/学习双线教程
├── WSL2-安装配置指南.md                     # 环境搭建参考
└── *.sh / *.py                    # 可复跑的演示与验证脚本
```

## 任务对照

| 任务 | 交付物 / 证据 | 位置 |
|---|---|---|
| Task 01 环境搭建（IDE + CLI Agent + API 连通性） | 教程 + 环境基线 | `AI-Lab-通识任务-操作与学习教程.md`、`docs/00-环境配置/` |
| Task 02 Markdown 笔记体系 | 踩坑记录（表格/代码块/截图/外链四要素齐备） | `AI-Lab 通识学习计划与环境踩坑记录.md` |
| Task 03 终端操作序列 | 目录树 / 批量重命名 / 日志过滤的**真实执行记录** | `docs/90-交付物/Task03-终端操作序列交付.md` |
| Task 04 Git 与 GitHub 协作 | init→commit→分支→冲突解决→远程，含真实 hash | `docs/90-交付物/Task04-Git版本管理与协作实操.md` |

## 可复跑脚本

| 脚本 | 作用 |
|---|---|
| `python-healthcheck.py` | Python 环境完整性体检（stdlib / venv / tkinter / OpenSSL） |
| `task03-runbook.sh` + `task03-capture.sh` | Task03 三项操作序列 + 采集真实输出 |
| `task04-git-demo.sh` | Git 全流程演示（含制造并解决冲突） |
| `grep-recipes-test.sh` / `rename-recipes-test.sh` | 过滤与批量重命名的配方自测 |
| `link-local-github.sh` | 本仓库初始化并关联远程 |

## 环境

Windows 11 + Git 2.56 + Python 3.14.8 + Git Bash 5.3（命令与 Linux 一致）。

## 说明

- `preview-*/`、`checks*.json`、`__pycache__/`、`.tmp-*/` 等产物已在 `.gitignore` 中排除；
- 行尾由 `.gitattributes` 统一（`.sh` 强制 LF，避免在 WSL 里执行报 `$'\r'`）；
- 个人作业文档（如 `生涯人物访谈提纲.docx`）不属于本项目，已排除。
