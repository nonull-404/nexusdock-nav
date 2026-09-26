# NexusDock 导航（gethomepage）

把 HSH 已部署的自托管服务聚合成一个分类导航站。
基于 [gethomepage/homepage](https://github.com/gethomepage/homepage) v2.4.0（镜像
`ghcr.io/gethomepage/homepage:latest`），**不改上游镜像**，全部定制都放在本仓库的
`config/` 目录里，所以升级上游只是一句 `docker compose pull`。

## 访问

- 地址：https://nav.970407.xyz
- 认证：nginx basic auth，用户名 `admin`，密码在 Bitwarden 条目
  `NexusDock 导航 (nav.970407.xyz)` 里（浏览器扩展会自动填充）。

## 目录结构

```
config/
  settings.yaml     # 站点标题、主题、分组布局（layout）
  services.yaml     # 服务分组与条目（主要改这个文件）
  widgets.yaml      # 页面顶部信息组件（资源、时间、搜索）
  bookmarks.yaml    # 书签
  docker.yaml       # docker 集成（走 docker-socket-proxy，只读）
  custom.css        # 视觉定制
  custom.js         # 行为定制
docker-compose.yml  # O1 上实际运行的编排（homepage + dockerproxy），挂载 ./config
deploy.sh           # 一键同步本仓库配置到 O1 并重启
```

## 部署 / 更新

```bash
./deploy.sh                # 从别的机器（ssh 别名 o1）部署
REMOTE=local ./deploy.sh   # 已经在 O1 上时
```

它会 push 本仓库 → 在 O1 上 `git fetch/reset --hard` → 重启 homepage 容器 → 调一次
`/api/revalidate` 重建静态页。**注意**：`reset --hard` 会丢掉 O1 上对
`/opt/homepage/repo` 的手改，改动一律走本仓库。
`settings.yaml`（标题/主题/布局）必须在重建静态页之后才生效，改完记得跑一次部署脚本。

## 加一个服务

编辑 `config/services.yaml`，在对应分组下加一条：

```yaml
- 服务名:
    icon: openlist            # dashboard-icons 的名字，或 mdi-xxx / si-xxx
    href: https://example.970407.xyz
    description: 干什么用的
    siteMonitor: https://example.970407.xyz   # 页面上的在线小圆点
    server: local             # 有 docker 集成时才有意义
    container: example        # 容器名（docker ps 里的名字）
```

然后 `./deploy.sh`（或直接在 O1 上 `sudo git -C /opt/homepage/repo pull`）。

## 二开约定

- 只改 `config/`，不要改 `docker-compose.yml` 里的镜像 tag 逻辑；升级用
  `docker compose pull && docker compose up -d`。
- 新主题/样式放 `config/custom.css`，新交互放 `config/custom.js`，本仓库自带的改动
  都加了 `/* nav: ... */` 注释标记，方便 diff。
- 密钥不放本仓库（它是公开仓库）。需要 widget 用 key 时，往 O1 的
  `/opt/homepage/.env` 里加 `HOMEPAGE_VAR_XXX=...`，配置里写 `{{HOMEPAGE_VAR_XXX}}`。

## 回滚

```bash
ssh o1 'cd /opt/homepage && sudo docker compose down'   # 停用导航（不影响其他服务）
sudo rm /etc/nginx/sites-enabled/nav.conf && sudo systemctl reload nginx
# DNS：删掉 nav.970407.xyz 的 A 记录
```
