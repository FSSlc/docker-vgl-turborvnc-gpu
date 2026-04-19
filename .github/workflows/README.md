# GitHub Actions Workflows

本目录包含项目的 CI/CD 工作流配置。

## 工作流列表

### 1. build-and-push.yml
自动构建和推送 Docker 镜像到 GitHub Container Registry。

**触发条件:**
- Push 到 main/develop 分支
- 创建版本标签
- Pull Request
- 手动触发

### 2. test-distros.yml
测试所有支持的 Linux 发行版。

**触发条件:**
- Pull Request
- 每周定时运行
- 手动触发

### 3. release.yml
创建 GitHub Release 并生成变更日志。

**触发条件:**
- 推送版本标签 (v*)

## 详细文档

查看 [ACTIONS.md](../ACTIONS.md) 获取完整的使用指南。
