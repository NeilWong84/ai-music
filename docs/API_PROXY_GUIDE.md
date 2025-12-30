# API 代理服务器搭建指南

如果现有的公共API服务不稳定，您可以搭建自己的API代理服务器来提供更稳定的服务。

## 方案 1：使用 Vercel 部署网易云音乐 API

### 步骤 1：准备工作

1. 注册 [Vercel](https://vercel.com) 账号（免费）
2. 注册 [GitHub](https://github.com) 账号
3. 安装 [Git](https://git-scm.com/)

### 步骤 2：Fork 网易云音乐 API 项目

访问项目：https://github.com/Binaryify/NeteaseCloudMusicApi

点击右上角 `Fork` 按钮，将项目复制到您的 GitHub 账号下。

### 步骤 3：导入到 Vercel

1. 登录 Vercel
2. 点击 `New Project`
3. 选择 `Import Git Repository`
4. 选择您 Fork 的 NeteaseCloudMusicApi 项目
5. 点击 `Deploy`

部署完成后，您会获得一个类似 `https://your-project.vercel.app` 的地址。

### 步骤 4：配置到应用

修改 `lib/services/music_api_service.dart`：

```dart
static const List<String> _baseUrls = [
  'https://your-project.vercel.app',  // 您自己的 API 地址
  // 其他备用地址...
];
```

## 方案 2：在本地/服务器部署

### 使用 Node.js 部署

```bash
# 1. 克隆项目
git clone https://github.com/Binaryify/NeteaseCloudMusicApi.git
cd NeteaseCloudMusicApi

# 2. 安装依赖
npm install

# 3. 启动服务（端口3000）
node app.js

# 或使用 PM2 保持运行
npm install -g pm2
pm2 start app.js --name netease-api
```

### 使用 Docker 部署

```bash
# 1. 克隆项目
git clone https://github.com/Binaryify/NeteaseCloudMusicApi.git
cd NeteaseCloudMusicApi

# 2. 构建镜像
docker build -t netease-api .

# 3. 运行容器
docker run -d -p 3000:3000 --name netease-api netease-api
```

### 步骤 4：配置应用

如果部署在本地（开发环境）：

```dart
static const List<String> _baseUrls = [
  'http://localhost:3000',  // 本地API
  // 其他备用地址...
];
```

如果部署在服务器：

```dart
static const List<String> _baseUrls = [
  'http://your-server-ip:3000',  // 服务器API
  // 或使用域名
  'https://api.yourdomain.com',
  // 其他备用地址...
];
```

## 方案 3：使用云服务器（推荐用于生产环境）

### 阿里云/腾讯云/华为云部署

1. 购买云服务器（最低配置即可）
2. 安装 Node.js 环境
3. 克隆并部署 API 项目
4. 配置 Nginx 反向代理
5. 配置 HTTPS（使用 Let's Encrypt 免费证书）

### Nginx 配置示例

```nginx
server {
    listen 80;
    server_name api.yourdomain.com;
    
    location / {
        proxy_pass http://localhost:3000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}
```

## 方案 4：使用 Railway 部署（免费）

1. 访问 [Railway](https://railway.app)
2. 使用 GitHub 登录
3. 点击 `New Project`
4. 选择 `Deploy from GitHub repo`
5. 选择您 Fork 的 NeteaseCloudMusicApi 项目
6. 等待部署完成

Railway 会自动生成一个 URL，例如：`https://your-project.up.railway.app`

## 安全建议

1. **限制访问**：配置 API 只允许您的应用访问
2. **添加认证**：为 API 添加 Token 认证
3. **使用 HTTPS**：确保数据传输安全
4. **监控日志**：定期检查 API 访问日志
5. **备份配置**：保存好 API 配置和密钥

## 性能优化

1. **启用缓存**：在代理服务器层面启用缓存
2. **CDN 加速**：使用 CDN 服务加速全球访问
3. **负载均衡**：部署多个实例，使用负载均衡
4. **数据库缓存**：对热门数据使用 Redis 缓存

## 故障排查

### 问题 1：API 部署后无法访问

- 检查防火墙是否开放端口
- 检查服务是否正常运行：`pm2 status`
- 查看错误日志：`pm2 logs netease-api`

### 问题 2：CORS 跨域问题

在 API 项目的 `app.js` 中添加：

```javascript
app.use((req, res, next) => {
  res.header('Access-Control-Allow-Origin', '*');
  res.header('Access-Control-Allow-Headers', '*');
  next();
});
```

### 问题 3：请求速度慢

- 检查服务器带宽
- 使用 CDN 加速
- 优化数据库查询
- 启用 Gzip 压缩

## 成本估算

| 方案 | 月费用 | 适用场景 |
|------|--------|----------|
| Vercel | 免费 | 开发测试、小流量 |
| Railway | 免费-$5 | 开发测试 |
| 云服务器 | ¥30-100 | 生产环境、中等流量 |
| 高级云服务 | ¥200+ | 大流量、企业级 |

## 推荐方案

**开发测试**：使用 Vercel 或 Railway（免费且简单）

**个人项目**：使用低配云服务器（稳定且可控）

**商业项目**：使用高配云服务器 + CDN + 负载均衡

## 相关资源

- [网易云音乐 API 文档](https://binaryify.github.io/NeteaseCloudMusicApi/)
- [Vercel 文档](https://vercel.com/docs)
- [Railway 文档](https://docs.railway.app/)
- [PM2 进程管理](https://pm2.keymetrics.io/)
