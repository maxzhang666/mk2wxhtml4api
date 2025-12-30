# Proposal: 添加 Docker 部署支持

## 概述
为 `mk2wxhtml4api` 项目添加 Docker 容器化部署支持，使用户能够通过 Docker 快速部署和运行 Markdown 到微信公众号 HTML 转换 API 服务。

## 背景
当前项目是一个 Node.js + Express 的 API 服务，但没有容器化部署方案。添加 Docker 支持可以：
- 简化部署流程，消除"在我机器上能运行"的问题
- 提供一致的运行环境
- 支持快速扩展和编排
- 降低部署复杂度

## 目标
1. 创建优化的 Dockerfile，支持多阶段构建
2. 提供 .dockerignore 文件减小镜像体积
3. 提供可选的 docker-compose.yml 简化本地开发和部署
4. 确保 Docker 镜像安全、轻量且高效

## 范围

### 包含
- 创建 `Dockerfile`（多阶段构建）
- 创建 `.dockerignore`
- 创建 `docker-compose.yml`
- 更新 README.md 添加 Docker 使用说明
- 添加 Docker 镜像构建和运行文档

### 不包含
- Kubernetes 部署配置
- CI/CD 流水线集成
- Docker 镜像仓库发布流程
- 多架构镜像构建（如 ARM）

## 技术方案

### Dockerfile 设计
- 基础镜像：`node:20-alpine`（轻量级）
- 工作目录：`/app`
- 多阶段构建优化：
  - 阶段1：依赖安装（利用缓存）
  - 阶段2：应用构建
- 非root用户运行（安全）
- 暴露端口：3000
- 健康检查：`/health` 端点

### docker-compose.yml 设计
- 服务定义：API 服务
- 环境变量：PORT、NODE_ENV
- 端口映射：3002:3000（主机端口3002映射到容器端口3000）
- 卷挂载：可选（本地开发）

### 环境变量
- `PORT`: 服务端口（默认 3000）
- `NODE_ENV`: 运行环境（production/development）

## 影响评估

### 现有功能
- 无需修改现有代码
- 完全向后兼容

### 新增文件
- `Dockerfile` (~30 行)
- `.dockerignore` (~20 行)
- `docker-compose.yml` (~20 行)

## 风险与缓解
| 风险 | 影响 | 缓解措施 |
|------|------|----------|
| temp/ 目录样式模板路径问题 | 高 | 在 Dockerfile 中确保正确复制样式模板文件 |
| 镜像体积过大 | 中 | 使用 alpine 基础镜像 + .dockerignore |
| 权限问题 | 低 | 使用非 root 用户运行 |

## 验收标准
- [ ] 能够成功构建 Docker 镜像
- [ ] 容器启动后健康检查通过
- [ ] API 端点正常工作（`/api/convert/wechat`）
- [ ] 样式模板正确加载
- [ ] 使用 docker-compose 能够一键启动服务
- [ ] 镜像体积 < 200MB
- [ ] 文档完整清晰

## 依赖关系
无（独立功能）

## 替代方案
**方案A：仅 Dockerfile（已采用）**
- 优点：简单直接，满足基本需求
- 缺点：本地开发需要手动构建和运行

**方案B：完整的 Docker 生态**
- 优点：功能最完整
- 缺点：复杂度高，超出当前需求

## 参考文档
- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)
- [Node.js Docker Official Image](https://hub.docker.com/_/node)
