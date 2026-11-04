# weizt

部署包 GitHub 镜像仓库。

## 部署包

AtomGit `Automated_Deployment` 仓库中的全部离线部署包，已通过 GitHub Actions
自动发布到本仓库的 **Releases** 页面：

- Releases: https://github.com/Wei131488/weizt/releases/tag/deployment-packages-2

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

## AtomGit 新增内容（2026-11）

以下为 `Automated_Deployment` 最近新增的部署包清单；大包继续通过 GitHub Releases 发布，不使用 Git LFS。

### AI 智能体

| 包 | 内容 |
|---|---|
| `install_ai_base.zip` | Miniconda + Node 24 + pnpm + gh + tmux |
| `install_claude_code.zip` | Claude Code 2.1.317 |
| `install_codex.zip` | Codex CLI 0.166.0 |
| `install_octop.zip` | Octop 1.0.3b2 |
| `install_deepseek.zip` | DeepSeek dsh-superagent + DSH 0.2.1-rc.3 |

### 大数据

| 包 | 内容 |
|---|---|
| `install_bigdata_base.zip` | JDK17/11/21 + Conda + 主机名 |
| `install_zookeeper.zip` | ZooKeeper 3.9.7 |
| `install_hadoop.zip` | Hadoop 3.5.0 |
| `install_hbase.zip` | HBase 3.0.0 |
| `install_hive.zip` | Hive 4.2.1 + MariaDB |
| `install_spark.zip` | Spark 4.3.0 |
| `install_flink.zip` | Flink 2.2.0 |
| `install_flume.zip` | Flume 1.11.0 |
| `install_tez.zip` | Tez 0.10.5 |
| `install_kafka.zip` | Kafka 4.4.0 KRaft |

### 监控

| 包 | 目标 |
|---|---|
| `install_zabbix_server.zip` | 101 主监控节点 |
| `install_zabbix_agent.zip` | 104/105 被监控节点 |
| `install_prometheus_server.zip` | 101 Prometheus + Grafana + Dashboard 16098 |
| `install_prometheus_agent.zip` | 104/105 node_exporter |

AtomGit 源：

```text
https://atomgit.com/shamoyeyu/Automated_Deployment
```

GitHub 发布：

```text
https://github.com/Wei131488/weizt/releases/tag/deployment-packages-2
```

> 以上为新增内容清单；大包发布以 Releases 页面实际资产为准。

## AtomGit 新增内容（2026-11，Kubernetes / 离线 YUM）

以下为 `Automated_Deployment` 最新追加的部署包，均保留在 AtomGit 仓库。

### 容器化 Kubernetes

| 包 | 内容 | 体积 |
|---|---|---|
| `k0s/install_k0s.zip` | k0s 1.37.2 三节点容器化 Kubernetes | 约 690 MB |
| `k8s-master/install_k8s_master.zip` | kubeadm 1.37.2 主节点包 | 约 568 MB |
| `k8s-worker/install_k8s_worker.zip` | kubeadm 1.37.2 工作节点包 | 约 325 MB |

说明：

- k0s 使用 Docker 容器运行 Kubernetes，支持 101/104/105 三节点。
- kubeadm 使用 containerd 2.4.2 static，适配 Anolis OS 8.10 / glibc 2.28。
- 主节点与工作节点包独立，避免工作节点安装 API Server、etcd、Dashboard 等冗余组件。
- 已验证三节点 Ready，并完成 kubeadm 镜像版本、节点名、CNI 清理和 containerd 启动等待修复。

### 离线 YUM 仓库

| 包 | 内容 | 体积 |
|---|---|---|
| `offline-yum/install_offline_yum.zip` | Anolis 8.10 离线 YUM ISO + 一键挂载脚本 | 约 424 MB |

包含 313 个 RPM，覆盖编译工具、Python 3、Java、网络工具、MariaDB、Nginx、Kubernetes 1.37.2 RPM 等；安装脚本自动挂载到：

```text
/data/anzhuan/plugin/offline-yum
```

并生成：

```text
/etc/yum.repos.d/offline-an8.repo
```

### 国内数据库资料

本机 `未部署/domestic_databases` 已下载：

```text
openGauss 7.0.0 LTS（CentOS7 x86_64）
OceanBase CE 4.6.0.1（EL8 RPM）
TiDB 8.5.8（PD/TiKV/TiDB 容器镜像）
```

> 二进制大包不进入 Git 历史，继续通过 Release 附件分发。

AtomGit 源：

```text
https://atomgit.com/shamoyeyu/Automated_Deployment
```
