# Automated_Deployment

一键部署脚本集合，当前面向 Anolis OS 8.10 / RHEL 8 兼容环境。

## 版本说明

- 新制作部署包默认选择各项目 **stable 分支的最新稳定版本**。
- 表格中列出的版本是离线包 **实际锁定版本**；个别历史包或兼容性包会单独标注。
- 当前已锁定的兼容版本：Ceph 18.2.2（Anolis 8/el8 的 cephadm 只提供到该版本；21.2.0 物料用于 el9 迁移，不用于当前 el8 主机）。
- 后续统一升级组件时，会同步更新包版本、README 和 SHA256 校验值。

## 当前部署形态

当前仓库中的脚本均为 **单机版 / 最小化部署版本**，用于 `192.168.1.101`、`192.168.1.104` 实验环境快速拉起和验证，不是生产高可用架构：

- 单节点数据库、单节点中间件、单节点代理。
- Ceph 为单节点 2 OSD 最小案例，单 MON；21.2.0 物料保留给未来 el9 迁移。
- 未配置生产级 VIP、集群仲裁、跨机房容灾、备份平台和统一巡检。
- 所有默认密码均为实验环境密码，生产使用前必须修改。

后续会单独提供大型生产环境方案，例如：

- **MySQL**：主从复制 / MGR、Keepalived → HAProxy、定时备份、慢查询与巡检。
- **Redis / MongoDB / Cassandra / ClickHouse**：主从、副本集、分片集群和监控告警。
- **Ceph / 对象存储**：多 MON、多 OSD、CRUSH 规划、纠删码、跨节点恢复。
- **中间件**：Kafka/RocketMQ/RabbitMQ 集群、持久化、备份恢复和巡检。
- **网络组件**：VIP、健康检查、灰度发布、限流、WAF 和高可用双机。

## 基础运行时

| 目录 | 组件 | 压缩包 | 说明 |
|---|---|---|---|
| java | JDK 21.0.12.1 | `install_jdk.zip` | 中间件依赖，安装到 `/data/anzhuan/plugin/jdk` 或 `jdk-21` |

## 数据库

| 目录 | 组件 | 压缩包 | 形态 |
|---|---|---|---|
| postgresql | PostgreSQL 18.6 | `install_postgresql.zip` | 单机 |
| mariadb | MariaDB 12.3.3 LTS | `install_mariadb.zip` | 单机 |
| mysql | MySQL 8.4.11 LTS | `install_mysql.zip` | 单机 |
| redis | Redis 8.10.3 | `install_redis.zip` | 单机 |
| mongodb | MongoDB Community 9.0.4 | `install_mongodb.zip` | 单机 |
| cassandra | Apache Cassandra 5.0.9 | `install_cassandra.zip` | 单机 |
| sqlite | SQLite 3.54.1 | `install_sqlite.zip` | 单机 |
| clickhosue | ClickHouse 26.10.2.103 | `clickhouse_install.zip` | 单机，目录名为历史拼写 |

## 文件存储

| 目录 | 组件 | 压缩包 | 形态 |
|---|---|---|---|
| nfs | nfs-utils 3.1.1 | `install_nfs.zip` | 单机 |
| samba | Samba 4.25.1 | `install_samba.zip` | 单机 |
| glusterfs | GlusterFS 11.1 | `install_glusterfs.zip` | 单机 |
| seaweedfs | SeaweedFS 4.51 | `install_seaweedfs.zip` | 单机 |
| juicefs | JuiceFS 1.4.2 | `install_juicefs.zip` | 单机 |
| minio | MinIO RELEASE.2025-10-15 | `install_minio.zip` | 单机 |
| ceph | Ceph 18.2.2 Reef（el8）/ 21.2.0（el9 备用） | `install_ceph.zip` | 单节点 2 OSD 最小案例 |
| fastdfs | FastDFS 6.18.1 | `install_fastdfs.zip` | 单机 |

### 文件存储验证

7 个文件存储包已在 101/104 完成实际验证：

| 组件 | 101 | 104 | 验证 |
|---|---|---|---|
| NFS | active | active | `showmount -e 127.0.0.1` |
| Samba | active | active | `smbclient -L 127.0.0.1` |
| GlusterFS | active | active | `gluster volume status gv0` |
| SeaweedFS | active | active | master 9333 / filer 8888 / S3 8333 |
| JuiceFS | active | active | `mountpoint` + 读写 |
| MinIO | active | active | `/minio/health/live` |
| Ceph | active | active | 2 OSD、CephFS 1/1 healthy、`HEALTH_OK` |

Ceph 安装脚本按系统版本选择：Anolis 8 使用 **18.2.2 Reef**（el8 cephadm 最后可用版本），Anolis 9 使用 **21.2.0**；当前 el8 实验机为单节点 2 个 loop OSD + CephFS。Ceph 19/20/21 官方 cephadm 仅提供 el9 包，不能用 21.2.0 直接替换 el8 的 18.2.2。详见 `ceph/README.md`。

## 中间件

| 目录 | 组件 | 压缩包 | 端口 |
|---|---|---|---|
| tomcat | Apache Tomcat 11.0.27 | `install_tomcat.zip` | 8080 |
| zookeeper | Apache ZooKeeper 3.9.7 | `install_zookeeper.zip` | 2181 / 8082 |
| kafka | Apache Kafka 4.4.0 KRaft | `install_kafka.zip` | 9092 / 9093 |
| nacos | Nacos 3.3.0 standalone | `install_nacos.zip` | 8848 / 9848 / 9849 |
| rocketmq | Apache RocketMQ 5.5.1 | `install_rocketmq.zip` | 9876 / 10911 |
| rabbitmq | RabbitMQ 4.4.0 + Erlang 27 | `install_rabbitmq.zip` | 5672 / 15672 |

中间件统一依赖 JDK 21：

```text
java/install_jdk.zip  ->  /data/anzhuan/plugin/jdk  或  /data/anzhuan/plugin/jdk-21
```

中间件脚本会自动识别 `jdk` 或 `jdk-21` 目录。

### 中间件验证

6 个中间件已在 101/104 完成实际部署验证：

| 组件 | 101 | 104 | 验证 |
|---|---|---|---|
| Tomcat | active | active | HTTP 200 / 8080 |
| ZooKeeper | active | active | 2181 + zkCli |
| Kafka | active | active | 9092 + KRaft topic |
| Nacos | active | active | HTTP 200 / 8848 |
| RocketMQ | active | active | 9876 + 10911 + broker-a 注册 |
| RabbitMQ | active | active | 5672 + 15672 HTTP 200 |

RabbitMQ 包内包含 `erlang-27.3.4.19-1.el8.x86_64.rpm`；其余 Java 组件使用 `java/install_jdk.zip` 安装的 JDK 21。

## 网络组件

| 目录 | 组件 | 压缩包 | 端口 |
|---|---|---|---|
| haproxy | HAProxy 3.4.7 | `install_haproxy.zip` | 8086 / 8404 |
| envoy | Envoy 1.40.2 | `install_envoy.zip` | 10000 / 9901 |
| traefik | Traefik 3.7.17 | `install_traefik.zip` | 8090 / 8081 |
| caddy | Caddy 2.11.7 | `install_caddy.zip` | 8088 / 2019 |
| frp | FRP 0.71.1 | `install_frp.zip` | 7000 / 7500 / 7080 |
| squid | Squid 6.12 | `install_squid.zip` | 3128 |
| nginx | Nginx 1.28.3 | `install_nginx.zip` | 80 / 443（可配） |

网络组件统一安装到：

```text
/data/anzhuan/plugin/{haproxy,envoy,traefik,caddy,frp,squid,nginx}
```

说明：

- HAProxy、Squid 从源码编译，脚本自动安装编译依赖。
- Envoy 官方 1.40.2 二进制要求 glibc 2.30，Anolis 8 为 glibc 2.28；包内附带 glibc 2.31 + libstdc++ 运行库，使用私有 loader 启动，不修改系统 glibc。
- 8080 预留给 Tomcat，网络组件代理上游统一为 `127.0.0.1:8080`；没有启动 Tomcat 时，健康/管理端点仍可独立验证。
- FRP 只启动 `frps`，`frpc.toml` 作为客户端样例保留。
- Nginx 为已有独立包，归入网络组件，不再单独列为“其他组件”。

### 网络组件验证

6 个网络组件已在 101/104 完成实际部署验证：

| 组件 | 101 | 104 | 验证 |
|---|---|---|---|
| HAProxy | active | active | 8086 `/health` 200、8404 `/stats` 200 |
| Envoy | active | active | 10000 `/health` 200、9901 `/ready` 200 |
| Traefik | active | active | 8090 `/ping` 200、8081 dashboard 200 |
| Caddy | active | active | 8088 `/health` 200、2019 admin |
| FRP | active | active | 7000/7500/7080 监听、dashboard 301 |
| Squid | active | active | 3128 监听、squidclient 正常 |

## AI 智能体

本仓库新增 AI 智能体一键部署包，统一安装到：

```text
/data/anzhuan/plugin/ai-agents
```

| 顺序 | 目录 | 组件 | 压缩包 | 形态 |
|---|---|---|---|---|
| 1 | ai-base | Miniconda + Node + pnpm + gh + tmux | `install_ai_base.zip` | 公共运行时 |
| 2 | claude-code | Claude Code 2.1.317 | `install_claude_code.zip` | 交互式 CLI |
| 3 | codex | OpenAI Codex CLI 0.166.0 | `install_codex.zip` | 交互式 CLI |
| 4 | octop | Octop 1.0.3b2 | `install_octop.zip` | Web 服务，8088 |
| 5 | deepseek | DeepSeek dsh-superagent + DSH 0.2.1-rc.3 | `install_deepseek.zip` | Web 面板，3082 |

公共运行时创建 Conda 环境：

```text
/data/anzhuan/plugin/ai-agents/miniconda3/envs/ai-agents
```

并写入 `/etc/profile.d/ai-agents.sh`，新登录 shell 自动激活。

统一 Key/端点文件：

```text
/data/anzhuan/plugin/ai-agents/etc/ai-keys.env
```

支持 `ANTHROPIC_API_KEY`、`OPENAI_API_KEY`、`DEEPSEEK_API_KEY`，以及本地 OpenAI-Compatible 端点 `LOCAL_OPENAI_BASE_URL`。详细说明见对应目录 README。

DeepSeek 为研究原型，没有正式稳定 Release；其面板只监听 `127.0.0.1:3082`，需通过 SSH 隧道访问。

### AI 智能体验证

| 组件 | 101 | 104 | 验证 |
|---|---|---|---|
| ai-base | 完成 | 完成 | Conda `ai-agents`、Node 24.22.2、pnpm 11.7.0、gh 2.103.3、tmux 3.8 |
| Claude Code | 完成 | 完成 | `claude --version` = 2.1.317 |
| Codex | 完成 | 完成 | `codex --version` = 0.166.0 |
| Octop | active | active | HTTP 8088 返回 200 |
| DeepSeek | active | active | DSH 3082 监听，HTTP 401 token 保护 |

## 大数据

三节点大数据集群包，安装到 `/data/anzhuan/plugin`：

| 顺序 | 目录 | 组件 | 压缩包 |
|---|---|---|---|
| 1 | bigdata-base | JDK17/11/21 + Conda + 主机名 | `install_bigdata_base.zip` |
| 2 | zookeeper | ZooKeeper 3.9.7 | `install_zookeeper.zip` |
| 3 | hadoop | Hadoop 3.5.0 HDFS/YARN | `install_hadoop.zip` |
| 4 | hbase | HBase 3.0.0 | `install_hbase.zip` |
| 5 | hive | Hive 4.2.1 + MariaDB | `install_hive.zip` |
| 6 | spark | Spark 4.3.0 | `install_spark.zip` |
| 7 | flink | Flink 2.2.0 | `install_flink.zip` |
| 8 | flume | Flume 1.11.0 | `install_flume.zip` |
| 9 | tez | Tez 0.10.5 | `install_tez.zip` |
| 10 | kafka | Kafka 4.4.0 KRaft | `install_kafka.zip` |

角色：101 = bd-master，104 = bd-node1，105 = bd-node2。先安装 base，再按依赖顺序安装；Hadoop/Hive/HBase 依赖 HDFS，HBase 依赖 ZooKeeper。

公共环境写入 `/etc/profile.d/bigdata.sh`，Conda 环境 `bigdata` 自动激活；集群内部端口在实验环境中统一关闭 firewalld。
### 大数据验证

三台主机已安装公共基础、ZooKeeper、Hadoop、Hive、Spark、Flume、Tez、Kafka、HBase、Flink。

实际验证结果：

| 组件 | 结果 |
|---|---|
| ZooKeeper | 3 节点 quorum，follower/leader 正常 |
| Hadoop HDFS | Live DataNodes 3 |
| Hadoop YARN | Total Nodes 3 |
| Kafka KRaft | 3 voters，3 副本 topic 正常 |
| Hive | Metastore 9083、HiveServer2 10000，`show databases` 正常 |
| Spark | Master + 2 alive workers |
| Flume | 1.11.0 可执行 |
| Tez | 0.10.5 库已安装 |
| HBase | Master UI 200；HBase 3.0 RegionServer 在 el8/JDK 下存在 RPC 兼容问题，当前实际 RS 数以 `status` 为准 |
| Flink | JobManager UI 200；TaskManager 注册仍需按 README 排查 `jobmanager.rpc.address`/网络 |

HBase 和 Flink 的脚本、压缩包已上传，但上述两项的三节点行为仍需继续修复验证，不能声明为已完整通过。
## 监控

主监控节点 101，被监控节点 104/105。

| 目录 | 组件 | 压缩包 | 用途 |
|---|---|---|---|
| zabbix-server | Zabbix 7.4.7 Server + Frontend | `install_zabbix_server.zip` | 101 主监控 |
| zabbix-agent | Zabbix 7.4.7 Agent | `install_zabbix_agent.zip` | 104/105 被监控 |
| prometheus-server | Prometheus 3.15.1 + Grafana 13.3.0 + Alertmanager + exporters | `install_prometheus_server.zip` | 101 |
| prometheus-agent | node_exporter 1.12.1 | `install_prometheus_agent.zip` | 104/105 |
| uptime-kuma | Uptime Kuma 2.5.9 | `install_uptime_kuma.zip` | 101/104，端口 3001 |

端口：

```text
Zabbix Frontend 80
Zabbix Server   10051
Zabbix Agent    10050
Prometheus      9090
Alertmanager    9093
Grafana         3000
node_exporter   9100
blackbox        9115
pushgateway     9091
```

Grafana 自动加载 **Node Exporter Dashboard 16098**；Prometheus 抓取 101/104/105:9100，并配置 NodeDown、CPU、内存、磁盘告警规则。

Zabbix Server 安装后通过 API 自动注册 `bd-master/bd-node1/bd-node2`，链接 `Linux by Zabbix agent` 模板。

Anolis 8 兼容性说明：Zabbix Server 使用 PHP 8.0 module；MariaDB 10.3 以 `AllowUnsupportedDBVersions=1` 实验兼容，生产建议 MariaDB 10.5+ 或 PostgreSQL。

### 监控验证

| 组件 | 101 | 104 | 105 |
|---|---|---|---|
| Zabbix Server | active | — | — |
| Zabbix Agent | active | active | active |
| Prometheus | 200 | — | — |
| Grafana | 200 | — | — |
| node_exporter | 9100 | 9100 | 9100 |
| Grafana 16098 | 已加载 | — | — |
## 日志与可观测

| 目录 | 组件 | 压缩包 | 形态 |
|---|---|---|---|
| elk | Elasticsearch 9.5.5 + Kibana 9.5.5 + Logstash 9.5.5 | `install_elk.zip` | 单机 |

## 安装包说明

- 所有包统一安装到 `/data/anzhuan/plugin/<component>`。
- 每个 zip 解压后执行 `bash scripts/install.sh`；已有历史包按包内 README 执行。`scripts/preflight.sh` 会先巡检系统版本、glibc、dnf 仓库、/data 空间和端口。
- 包内包含版本固定的离线安装包、安装脚本、README 和 SHA256SUMS。
- 数据库、文件存储、中间件和网络组件脚本均已在 `192.168.1.101`、`192.168.1.104` 验证。
- 中间件脚本会检查 `/data/anzhuan/plugin/jdk`；请先安装 `java/install_jdk.zip`。
- 网络组件端口已规避 Tomcat 8080，全部可在同一主机共存。
- 当前默认部署为单机/最小化，生产环境需按后续方案改造。

## 存储与镜像策略

`AtomGit` 是本项目的**主仓库和主存储**，部署包、脚本、README 与 SHA256 均以 AtomGit 为准：

```text
https://atomgit.com/shamoyeyu/Automated_Deployment
```

发布策略：

- **默认**：所有部署包提交并保存在 AtomGit，使用 Git LFS 管理。
- **GitHub Releases**：仅作为下载镜像/溢出通道，不是唯一存储；用于 Gitee 单仓库 1 GB 限制、GitHub Actions 自动发布和海外下载加速。
- **Gitee**：代码和 README 同步；受单仓库附件 1 GB 限制，大包不重复存放在 Gitee。
- 如果 GitHub Release 空间不足、上传失败或需要清理，**不删除 AtomGit 中的原始包**，并在 AtomGit README 中记录状态和替代下载方式。
- 如果 AtomGit 空间充足，后续新增包继续放 AtomGit；只有确需 GitHub 镜像时才发布 Release。
- 当前 AtomGit LFS 约 18 GiB，GitHub Release 发布任务会从 AtomGit 克隆后上传；若发布任务失败，以 AtomGit 包为准。

### GitHub Release 发布状态（2026-11）

- 最近一次 GitHub Actions 发布（run `41842953885`）失败，错误为：

```text
HTTP 422: Validation Failed
```

原因是目标标签 `deployment-packages-2` 已存在，属于标签冲突，不是存储空间不足。

- 已把发布标签改为唯一标签：

```text
deployment-packages-${GITHUB_RUN_NUMBER}-${GITHUB_RUN_ATTEMPT}
```

- 即使 GitHub Release 发布失败，AtomGit 中的包仍完整保留；GitHub Release 只是镜像/溢出通道。
- 后续如果 GitHub Release 空间不足，不删除 AtomGit 原件，而是在本 README 记录失败原因和替代下载方式。
## 使用方式

```bash
cd /data/anzhuan/plugin
unzip -o install_nfs.zip
cd install_nfs
bash scripts/install.sh
```

其他组件相同，只需替换目录名和压缩包名。

## Git LFS

`*.zip` 使用 Git LFS 管理，克隆后先执行：

```bash
git lfs install
git lfs pull
```

## 身份、安全与镜像仓库

| 目录 | 组件 | 压缩包 | 端口 |
|---|---|---|---|
| vault | HashiCorp Vault 2.2.1 | `install_vault.zip` | 8200 |
| keycloak | Keycloak 26.8.1 | `install_keycloak.zip` | 8080 |
| harbor | Harbor 2.14.6 | `install_harbor.zip` | 80 |

安装目录：

```text
/data/anzhuan/plugin/{vault,keycloak,harbor}
```

说明：

- Vault 安装后查看 `/data/anzhuan/plugin/vault/root.token`。
- Keycloak 默认 `admin / Keycloak@996`，实验模式使用 H2，生产需切 PostgreSQL。
- Harbor 默认 `admin / Harbor@996`，当前为 HTTP，生产需启用 HTTPS。
- Vault / Keycloak / Harbor 均已在 101、104 完成单机验证。

## AI 推理运行时

| 目录 | 组件 | 压缩包 | 端口 |
|---|---|---|---|
| ollama | Ollama 0.40.14 | `install_ollama.zip` | 11434 |

说明：

- 安装到 `/data/anzhuan/plugin/ollama`。
- 已在 101、104 验证。
- 大模型文件不进入仓库，按实际模型另行下载。

## 数据平台与可视化

| 目录 | 组件 | 压缩包 | 端口 |
|---|---|---|---|
| airflow | Airflow 3.3.2 | `install_airflow.zip` | 8082 |
| superset | Superset 6.1.0 | `install_superset.zip` | 8088 |

安装目录：

```text
/data/anzhuan/plugin/{airflow,superset}
```

默认凭据：

```text
Airflow  : admin / Airflow@996
Superset : admin / Superset@996
```

说明：

- Airflow 和 Superset 当前使用 SQLite 实验模式，生产需切 PostgreSQL/MySQL 和独立服务。
- 均已在 101、104 完成单机验证。

## K3s 轻量 Kubernetes

| 目录 | 组件 | 压缩包 | 端口 |
|---|---|---|---|
| k3s | K3s 1.36.5 三节点 | `install_k3s.zip` | 6443 |

验证：

```text
k3s-101 Ready control-plane
k3s-104 Ready
k3s-105 Ready
```

说明：

- K3s 需要 cgroup v2。
- 默认 token `K3s@996`，API `https://192.168.1.101:6443`。
- 禁用 Traefik/servicelb，避免与 Harbor 的 80/443 冲突。
- 已在 101/104/105 三节点验证。

## Kubernetes 容器化集群（k0s）

不使用 K3s。采用 k0s 容器方式部署三节点 Kubernetes：

```text
k0s-controller / k0s-104 / k0s-105
Kubernetes v1.37.2+k0s.0
API https://192.168.1.101:6443
```

安装包：

```text
k0s/install_k0s.zip
```

目录：

```text
/data/anzhuan/plugin/kubernetes/
```

角色：

| 主机 | 角色 |
|---|---|
| 192.168.1.101 | controller + worker |
| 192.168.1.104 | worker |
| 192.168.1.105 | worker |

验证：

```text
k0s-controller Ready control-plane
k0s-104 Ready
k0s-105 Ready
coredns/kube-router/kube-proxy/metrics-server Running
```

说明：

- k0s 以 Docker 容器运行，控制器和工作节点均为容器。
- 需要 cgroup v2。
- worker 加入需要 controller 生成的 `worker-token`。
- 已在 101/104/105 验证。

## Kubernetes 1.37.2 Kubeadm 三节点

基于 `参考部署\K8s部署文档.pdf` 重新制作，版本从 CentOS 7 / K8s 1.12.2 / Docker 17.03 升级。

| 目录 | 包 | 主机 | 内容 |
|---|---|---|---|
| k8s-master | `install_k8s_master.zip` | 101 | kubeadm/kubelet/kubectl、containerd、etcd、API Server、Flannel、Metrics、Dashboard |
| k8s-worker | `install_k8s_worker.zip` | 104/105 | kubelet/kubeadm、containerd、pause、kube-proxy、Flannel |

版本：

```text
Kubernetes 1.37.2
containerd 2.4.2（static）
Flannel 0.28.10
Metrics Server 0.9.1
Kubernetes Dashboard 2.7.0
```

部署目录：

```text
/data/anzhuan/plugin/kubeadm/
```

验证：

```text
k8s-master   Ready control-plane
k8s-node104  Ready
k8s-node105  Ready
```

主节点安装结束后生成：

```text
/data/anzhuan/plugin/kubeadm/worker-join.sh
```

复制到 104/105 后执行 worker 包。

说明：

- 使用 containerd static 2.4.2，兼容 Anolis OS 8.10 glibc 2.28；普通 containerd 动态二进制需要 GLIBC 2.32/2.34，不能直接用。
- 需要 cgroup v2。
- 主节点包与工作节点包分离，worker 不包含 API Server/etcd/Dashboard/Metrics。
- 已在 101/104/105 三节点验证。
- Dashboard v2.7.0 为仓库归档前最后稳定版。

## Anolis 8.10 离线 YUM

```text
offline-yum/install_offline_yum.zip
```

包含：

- ISO 离线仓库 313 个 RPM
- 一键挂载和写入 repo 脚本
- Kubernetes 1.37.2 RPM
- 编译、Python、Java、网络、MariaDB、Nginx 等常用依赖

安装目录：

```text
/data/anzhuan/plugin/offline-yum
```

## GitHub Release 镜像

- GitHub Releases 仅作为下载镜像/溢出通道，不作为唯一存储。
- 发布页：https://github.com/Wei131488/weizt/releases
- 如果 GitHub 空间不足或发布失败，以 AtomGit 中的原始包为准，并在 AtomGit README 记录。
