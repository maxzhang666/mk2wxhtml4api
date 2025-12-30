# 任务清单：添加 Docker 部署支持

## 优先级说明
- **P0**: 必须完成，阻塞其他任务
- **P1**: 应该完成，核心功能
- **P2**: 可选完成，增强功能

---

## 第一阶段：基础 Docker 配置

### 1. 创建 .dockerignore 文件 [P0]
**描述**: 创建 .dockerignore 文件，排除不必要的文件以减小镜像体积

**验证步骤**:
- [ ] 文件创建在项目根目录
- [ ] 排除 `node_modules/`
- [ ] 排除 `.git/`
- [ ] 排除 `test/`
- [ ] 排除 `.github/`
- [ ] 排除 `*.log`
- [ ] 排除 `.env*`
- [ ] 排除 `.vscode/`、`.cursor/`、`.claude/`

**预期结果**: 镜像构建时忽略不必要的文件

---

### 2. 创建 Dockerfile [P0]
**描述**: 创建优化的多阶段 Dockerfile

**验证步骤**:
- [ ] 使用 `node:20-alpine` 作为基础镜像
- [ ] 设置工作目录为 `/app`
- [ ] 分两阶段：依赖安装 + 应用运行
- [ ] 复制 `package.json` 和 `package-lock.json`
- [ ] 运行 `pnpm install --prod` 安装依赖
- [ ] 复制 `src/` 和 `temp/` 目录
- [ ] 创建非 root 用户 `nodeuser`
- [ ] 切换到非 root 用户
- [ ] 暴露端口 3000
- [ ] 设置默认命令为 `pnpm start`
- [ ] 添加 HEALTHCHECK 指令

**预期结果**:
- 能够成功构建镜像
- 镜像体积 < 200MB
- 容器以非 root 用户运行

---

### 3. 创建 docker-compose.yml [P1]
**描述**: 创建 docker-compose 配置文件简化部署

**验证步骤**:
- [ ] 定义服务名为 `mk2wxhtml4api`
- [ ] 使用当前目录的 Dockerfile 上下文
- [ ] 配置端口映射 `3002:3000`（主机端口3002映射到容器端口3000）
- [ ] 设置环境变量 `NODE_ENV=production`
- [ ] 添加可选的 `PORT` 环境变量配置
- [ ] 配置重启策略为 `unless-stopped`

**预期结果**:
- `docker-compose up` 能够成功启动服务
- 服务可通过 http://localhost:3002 访问

---

## 第二阶段：测试与验证

### 4. 本地构建测试 [P0]
**描述**: 验证 Docker 镜像能够成功构建

**命令**:
```bash
docker build -t mk2wxhtml4api:latest .
```

**验证步骤**:
- [ ] 构建成功无错误
- [ ] 检查镜像大小 < 200MB
- [ ] 检查镜像层数合理（< 15 层）

**预期结果**: 获得可用的 Docker 镜像

---

### 5. 容器运行测试 [P0]
**描述**: 验证容器能够正常启动并响应请求

**命令**:
```bash
docker run -p 3002:3000 mk2wxhtml4api:latest
```

**验证步骤**:
- [ ] 容器启动无错误日志
- [ ] 健康检查通过（`/health` 端点返回 200）
- [ ] API 端点可访问（`/api/convert/wechat`）
- [ ] 样式模板正确加载
- [ ] 发送测试 Markdown 内容并验证转换结果

**测试用例**:
```bash
# 健康检查
curl http://localhost:3002/health

# 转换测试
curl -X POST http://localhost:3002/api/convert/wechat \
  -H "Content-Type: application/json" \
  -d '{"markdown": "# Hello\n\nThis is a test."}'
```

**预期结果**: 所有测试通过

---

### 6. Docker Compose 测试 [P1]
**描述**: 验证 docker-compose 能够正常工作

**命令**:
```bash
docker-compose up
```

**验证步骤**:
- [ ] 服务启动成功
- [ ] 通过 http://localhost:3002 访问服务
- [ ] `docker-compose down` 能够正确停止服务

**预期结果**: docker-compose 工作正常

---

## 第三阶段：文档更新

### 7. 更新 README.md [P1]
**描述**: 在 README 中添加 Docker 部署说明

**验证步骤**:
- [ ] 添加 "Docker 部署" 章节
- [ ] 说明前置条件（需要安装 Docker）
- [ ] 提供构建命令示例
- [ ] 提供运行命令示例
- [ ] 提供测试命令示例
- [ ] 说明环境变量配置
- [ ] 添加常见问题（FAQ）

**预期结果**: 用户能够根据文档独立完成 Docker 部署

---

### 8. 创建 DOCKER.md 详细文档 [P2]
**描述**: 创建详细的 Docker 使用文档

**验证步骤**:
- [ ] 文档包含：快速开始、配置说明、故障排查
- [ ] 说明如何自定义端口
- [ ] 说明如何查看日志
- [ ] 说明如何进入容器调试
- [ ] 说明生产环境部署建议

**预期结果**: 提供完整的 Docker 使用指南

---

## 任务依赖关系

```
1. .dockerignore ─┐
                 ├─> 2. Dockerfile ─> 4. 本地构建测试 ─> 5. 容器运行测试
3. docker-compose ┘                                        └─> 7. 更新 README
                                                             └─> 8. DOCKER.md
                3. docker-compose ─> 6. Docker Compose 测试 ─┘
```

**并行工作**:
- 任务 1、2、3 可以并行进行
- 任务 7、8 可以并行进行（在任务 5、6 完成后）

---

## 完成标准

所有 P0 任务完成后，用户应该能够：
1. 使用 `docker build` 构建镜像
2. 使用 `docker run` 运行容器
3. 通过 HTTP API 正常使用服务

所有 P1 任务完成后，用户还应该能够：
4. 使用 `docker-compose` 一键部署
5. 根据文档独立完成部署
