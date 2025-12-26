# Nginx 双层反向代理架构说明

## 当前架构

```
用户请求
    ↓
宝塔 Nginx (80/443)  ← 第一层：SSL 终止、域名绑定
    ↓
Docker Web 容器 Nginx (8080→80)  ← 第二层：SPA 路由、API 代理
    ↓
Docker Server 容器 (3000)  ← 后端 API
```

## 为什么需要两层 Nginx？

### 第一层：宝塔 Nginx

| 职责 | 说明 |
|------|------|
| SSL/HTTPS | 统一管理证书，Let's Encrypt 自动续期 |
| 域名绑定 | 多域名、多站点统一管理 |
| 访问日志 | 宝塔面板可视化查看 |
| 防火墙集成 | 与宝塔安全策略联动 |
| 负载均衡 | 未来扩展多实例时可用 |

### 第二层：Docker 内 Nginx

| 职责 | 说明 |
|------|------|
| SPA 路由 | Vue Router History 模式支持 (`try_files`) |
| API 代理 | 将 `/api/` 请求转发到后端容器 |
| 静态资源 | 直接服务前端构建产物 |
| 容器隔离 | 前后端在同一 Docker 网络内通信 |
| 可移植性 | 整个 Docker Compose 可迁移到任何环境 |

## 好处

### 1. 职责分离
- 宝塔负责「对外」：SSL、域名、安全
- Docker 负责「对内」：应用路由、服务发现

### 2. 环境一致性
- Docker 内的配置在开发、测试、生产环境完全一致
- 不依赖宿主机的 Nginx 配置

### 3. 简化宝塔配置
- 宝塔只需要一条简单的反向代理规则
- 不需要在宝塔里配置复杂的 API 代理逻辑

### 4. 容器网络隔离
- 后端服务 (server:3000) 不需要暴露到宿主机
- 只有 web 容器的 8080 端口对外
- 数据库、Redis 完全隔离在 Docker 网络内

### 5. 便于扩展
- 未来可以轻松添加更多后端服务
- 可以在 Docker 内做负载均衡
- 可以添加缓存层

## 替代方案：单层 Nginx

如果想简化为单层，可以：

1. 去掉 Docker 内的 Nginx
2. 让宝塔 Nginx 直接代理到后端
3. 前端静态文件放到宝塔网站目录

```nginx
# 宝塔 Nginx 配置（单层方案）
server {
    listen 80;
    server_name admin.example.com;
    
    root /www/wwwroot/xunyin-admin/web/dist;
    index index.html;
    
    # SPA 路由
    location / {
        try_files $uri $uri/ /index.html;
    }
    
    # API 代理到 Docker 后端
    location /api/ {
        proxy_pass http://127.0.0.1:3000/api/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

**缺点**：
- 前端构建产物需要放到宿主机
- 配置分散在宝塔和 Docker 两处
- 迁移时需要同步修改宝塔配置

## 总结

| 方案 | 优点 | 缺点 |
|------|------|------|
| 双层 Nginx | 职责清晰、可移植、隔离性好 | 多一层转发，略微增加延迟 |
| 单层 Nginx | 配置简单、少一层转发 | 耦合宿主机、迁移麻烦 |

**推荐**：保持当前双层架构，性能损耗可忽略（本地回环通信），换来的是更好的可维护性和可移植性。
