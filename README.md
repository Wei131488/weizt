# weizt

部署包 GitHub 镜像仓库。

## 部署包

AtomGit `Automated_Deployment` 仓库中的全部离线部署包，已通过 GitHub Actions
自动发布到本仓库的 **Releases** 页面：

- Releases: https://github.com/Wei131488/weizt/releases

发布内容包含：

| 组件 | 包名 |
|---|---|
| PostgreSQL 18.6 | `install_postgresql.zip` |
| MariaDB 12.3.3 LTS | `install_mariadb.zip` |
| Redis 8.10.3 | `install_redis.zip` |
| MongoDB Community 9.0.4 | `install_mongodb.zip` |
| Cassandra 5.0.9 | `install_cassandra.zip` |
| SQLite 3.54.1 | `install_sqlite.zip` |
| MySQL | `install_mysql.zip` |
| Nginx | `install_nginx.zip` |
| ELK | `install_elk.zip` |
| FastDFS | `install_fastdfs.zip` |
| ClickHouse | `clickhouse_install.zip` |
| JDK | `install_jdk.zip` |

## 发布方式

`.github/workflows/publish-packages.yml` 会从 AtomGit 克隆带 LFS 的完整仓库，
创建 GitHub Release 并上传所有 `*.zip`。

也可以在 GitHub Actions 页面手动触发 `Publish deployment packages`。

## 说明

- 安装包总体积约 3.8 GB，因此使用 Release 附件而不是 Git LFS。
- 部署脚本和默认安装路径仍以各 zip 内 `README.md` 为准。
- 默认安装根目录：`/data/anzhuan/plugin/`。
