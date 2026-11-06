# 组件功能、优缺点与入门教程

组件目录：

```text
E:\gitfile\02\Automated_Deployment
```

本文面向刚开始接触 Linux 运维、后端部署和基础架构的读者。目标不是把所有组件背下来，而是先建立一张“组件地图”：

```text
用户请求
  ↓
网络入口（Nginx / HAProxy / Envoy / Traefik）
  ↓
应用运行时（JDK / Tomcat / Jenkins / AI 工具）
  ↓
数据层（数据库 / 缓存 / 消息 / 存储）
  ↓
平台层（Kubernetes / 监控 / 日志 / 大数据）
  ↓
安全与治理（Keycloak / Vault）
```

## 0. 阅读说明

### 0.1 标记

- `[已有]`：仓库已有安装包。
- `[单机]`：当前包是单机/最小化形式，不等于生产高可用。
- `[需补]`：生产环境仍需要额外组件或集群方案。
- `[可选]`：按规模或业务需要选择。

### 0.2 重要提醒

```text
有安装包 ≠ 已经生产可用
```

现有仓库里很多数据库、消息队列、存储和监控包都是单机/最小化部署。生产环境还要补：

```text
高可用、备份、监控、证书、容灾、安全基线
```

### 0.3 组件分层

| 层次 | 解决的问题 | 代表组件 |
|---|---|---|
| 运行时 | 程序在哪里运行 | JDK、Tomcat |
| 网络入口 | 请求怎么进来、怎么分发 | Nginx、HAProxy、Envoy、Traefik、Caddy、FRP、Squid |
| 数据库 | 数据怎么持久化 | PostgreSQL、MySQL、MariaDB、Redis、MongoDB、Cassandra、ClickHouse、SQLite |
| 存储 | 文件/对象怎么保存 | NFS、Samba、Ceph、GlusterFS、FastDFS、SeaweedFS、JuiceFS、MinIO |
| 消息与集成 | 系统之间怎么解耦 | Kafka、RabbitMQ、RocketMQ、ZooKeeper、Nacos |
| 容器与交付 | 应用怎么打包、发布、编排 | k0s、k3s、Kubernetes、Harbor、Jenkins、离线 YUM |
| 可观测性 | 出问题怎么发现和定位 | Prometheus、Grafana、Zabbix、Uptime Kuma、Fluent Bit、OpenSearch、OpenObserve |
| 数据平台 | 海量数据怎么存储和计算 | Hadoop、Hive、HBase、Spark、Flink、Flume、Tez、Airflow、Superset |
| 安全与 AI | 身份、密钥、智能体 | Keycloak、Vault、Ollama、Claude Code、Codex、DeepSeek、Octop |

---

## 1. 基础运行时

### 1.1 JDK / Java

| 项目 | 内容 |
|---|---|
| 目录 | `java/` |
| 官方定位 | Java 应用的运行时和标准类库，OpenJDK 是开源参考实现 |
| 官网 | https://openjdk.org/ |
| 开发语言 | HotSpot VM 以 C++/C 为主，Java 类库以 Java 为主 |
| 核心功能 | 提供 JVM、垃圾回收、标准类库、Java 工具链 |
| 优势 | 生态成熟、跨平台、企业级中间件支持广 |
| 局限 | 版本兼容需要管理；内存和 GC 需要调优 |
| 典型场景 | Tomcat、Jenkins、Nacos、Hadoop、Spark、Flink 等 Java 组件 |
| 入门提示 | 先理解 `JAVA_HOME`、`java -version`、堆内存 `-Xms/-Xmx` |

### 1.2 Tomcat

| 项目 | 内容 |
|---|---|
| 目录 | `tomcat/` |
| 官方定位 | Apache 官方的 Servlet/JSP 容器 |
| 官网 | https://tomcat.apache.org/ |
| 开发语言 | Java |
| 核心功能 | 运行 Java Web 应用，处理 HTTP、Servlet、JSP |
| 优势 | 标准、稳定、资料多，传统 Java Web 兼容性好 |
| 局限 | 相对偏重；现代 Spring Boot 常使用内置容器 |
| 典型场景 | 传统 Java Web、老系统迁移、WAR 包部署 |
| 入门提示 | 重点看 `server.xml`、`webapps`、`logs/catalina.out` |

---

## 2. 网络入口与代理

### 2.1 Nginx

| 项目 | 内容 |
|---|---|
| 目录 | `nginx/` |
| 官方定位 | 高性能 HTTP 服务器、反向代理、邮件代理 |
| 官网 | https://nginx.org/ |
| 开发语言 | C |
| 核心功能 | 静态资源、反向代理、负载均衡、TLS、限流 |
| 优势 | 轻量、高并发、配置成熟、生产案例多 |
| 局限 | 动态配置和复杂 API 治理较弱；模块需编译或扩展 |
| 典型场景 | Web 入口、静态资源、反向代理、七层负载 |
| 入门提示 | 先学 `server`、`location`、`upstream`、`proxy_pass` |

可以把 Nginx 理解成“大楼前台”：请求先到这里，再决定转到哪个后端。

### 2.2 Caddy

| 项目 | 内容 |
|---|---|
| 目录 | `caddy/` |
| 官方定位 | 自动 HTTPS 的现代 Web 服务器 |
| 官网 | https://caddyserver.com/ |
| 开发语言 | Go |
| 核心功能 | 静态站点、反向代理、自动申请和续期证书 |
| 优势 | 配置简单、自动 TLS、单二进制 |
| 局限 | 生态和复杂调优经验不如 Nginx |
| 典型场景 | 小型站点、内部工具、自动 HTTPS |
| 入门提示 | 适合快速起一个 HTTPS 站点，不适合替代复杂网关 |

### 2.3 HAProxy

| 项目 | 内容 |
|---|---|
| 目录 | `haproxy/` |
| 官方定位 | 高性能 TCP/HTTP 负载均衡器 |
| 官网 | https://www.haproxy.org/ |
| 开发语言 | C |
| 核心功能 | 四层/七层负载、健康检查、连接保持、ACL |
| 优势 | 性能高、稳定、TCP 场景强 |
| 局限 | 配置较专业；动态服务发现弱 |
| 典型场景 | 数据库入口、API 四层负载、双机 VIP 后端 |
| 入门提示 | 常与 Keepalived 搭配做 VIP 高可用 |

### 2.4 Envoy

| 项目 | 内容 |
|---|---|
| 目录 | `envoy/` |
| 官方定位 | 云原生 L7 代理和服务网格数据面 |
| 官网 | https://www.envoyproxy.io/ |
| 开发语言 | C++ |
| 核心功能 | L7 代理、动态配置 xDS、熔断、限流、可观测 |
| 优势 | 动态配置强、可观测性好、服务网格生态核心 |
| 局限 | 配置复杂，学习和运维成本高 |
| 典型场景 | Service Mesh、API 网关数据面、微服务治理 |
| 入门提示 | 初学先理解 listener、cluster、route 三个概念 |

### 2.5 Traefik

| 项目 | 内容 |
|---|---|
| 目录 | `traefik/` |
| 官方定位 | 云原生动态反向代理和入口控制器 |
| 官网 | https://traefik.io/traefik/ |
| 开发语言 | Go |
| 核心功能 | 自动发现容器/K8s 服务、路由、TLS、中间件 |
| 优势 | 动态配置、容器友好、上手快 |
| 局限 | 超大规模和复杂治理不如 Envoy/APISIX |
| 典型场景 | Docker Compose、K8s Ingress、内部服务入口 |
| 入门提示 | 适合容器环境，传统静态 Nginx 配置思维要转换 |

### 2.6 FRP

| 项目 | 内容 |
|---|---|
| 目录 | `frp/` |
| 官方定位 | 内网穿透和反向代理工具 |
| 官网 | https://github.com/fatedier/frp |
| 开发语言 | Go |
| 核心功能 | 把内网服务映射到公网/跳板机 |
| 优势 | 部署简单、配置少、适合无公网 IP 环境 |
| 局限 | 安全和审计能力有限，不适合直接暴露核心业务 |
| 典型场景 | 远程运维、测试环境、临时演示 |
| 入门提示 | 必须配认证、白名单和 TLS，不要裸露管理端口 |

### 2.7 Squid

| 项目 | 内容 |
|---|---|
| 目录 | `squid/` |
| 官方定位 | 缓存代理和正向代理服务器 |
| 官网 | http://www.squid-cache.org/ |
| 开发语言 | C++ |
| 核心功能 | 正向代理、缓存、ACL、访问控制 |
| 优势 | 成熟、缓存和 ACL 能力强 |
| 局限 | 不是反向代理/WAF；HTTPS 透明代理复杂 |
| 典型场景 | 出口代理、上网审计、缓存加速 |
| 入门提示 | 企业出口代理常见，但不要和反向代理混用 |

---

## 3. 数据库

### 3.1 PostgreSQL

| 项目 | 内容 |
|---|---|
| 目录 | `postgresql/` |
| 官方定位 | 先进的开源关系型数据库 |
| 官网 | https://www.postgresql.org/ |
| 开发语言 | C |
| 核心功能 | SQL、事务、JSON、GIS、扩展、复制 |
| 优势 | SQL 标准完整、扩展丰富、GIS/JSON 强 |
| 局限 | 高并发写入和 HA 需 Patroni/PgBouncer 等补强 |
| 典型场景 | 业务主库、GIS、复杂查询、数据仓库入口 |
| 入门提示 | 先学 `psql`、备份 `pg_dump`、连接池和 WAL |

### 3.2 MySQL

| 项目 | 内容 |
|---|---|
| 目录 | `mysql/` |
| 官方定位 | 最流行的开源关系型数据库之一 |
| 官网 | https://www.mysql.com/ |
| 开发语言 | C/C++ |
| 核心功能 | 关系型存储、事务、复制、分区 |
| 优势 | 生态最大、人才多、云厂商兼容好 |
| 局限 | 复杂 SQL/分析弱于 PostgreSQL；HA 需额外组件 |
| 典型场景 | 电商、Web 业务、传统应用 |
| 入门提示 | 先学 `mysql` 客户端、`mysqldump`、主从复制 |

### 3.3 MariaDB

| 项目 | 内容 |
|---|---|
| 目录 | `mariadb/` |
| 官方定位 | MySQL 的开源分支，社区治理 |
| 官网 | https://mariadb.org/ |
| 开发语言 | C/C++ |
| 核心功能 | MySQL 兼容的关系型数据库 |
| 优势 | 开源治理清晰、兼容 MySQL、功能较全 |
| 局限 | 与 MySQL 新特性存在差异，生态略小 |
| 典型场景 | MySQL 替代、通用业务库、Web 应用 |
| 入门提示 | 大部分 MySQL 命令适用，但版本特性要确认 |

### 3.4 Redis

| 项目 | 内容 |
|---|---|
| 目录 | `redis/` |
| 官方定位 | 内存数据结构存储，常用作缓存和 KV |
| 官网 | https://redis.io/ |
| 开发语言 | C |
| 核心功能 | 缓存、KV、列表、集合、有序集合、分布式锁 |
| 优势 | 延迟低、数据结构丰富、生态成熟 |
| 局限 | 内存成本高；持久化/主从/集群需设计；许可证需关注 |
| 典型场景 | 缓存、会话、排行榜、分布式锁、限流 |
| 入门提示 | 先学 String/Hash/List/Set/ZSet 和过期时间 |

可以把 Redis 理解成“内存便签”：读写非常快，但不能当作唯一持久化数据库。

### 3.5 MongoDB

| 项目 | 内容 |
|---|---|
| 目录 | `mongodb/` |
| 官方定位 | 文档型 NoSQL 数据库 |
| 官网 | https://www.mongodb.com/ |
| 开发语言 | C++ |
| 核心功能 | JSON/BSON 文档、索引、聚合、副本集、分片 |
| 优势 | schema 灵活、开发效率高、文档模型自然 |
| 局限 | SSPL 许可证；事务和 HA 需副本集；复杂分析弱 |
| 典型场景 | 内容、日志、半结构化数据、快速迭代业务 |
| 入门提示 | 先学文档、集合、索引和聚合管道 |

### 3.6 Cassandra

| 项目 | 内容 |
|---|---|
| 目录 | `cassandra/` |
| 官方定位 | 高可用的宽列分布式数据库 |
| 官网 | https://cassandra.apache.org/ |
| 开发语言 | Java |
| 核心功能 | 分布式宽列存储、多数据中心、线性扩展 |
| 优势 | 写入扩展强、无单点、多数据中心 |
| 局限 | 最终一致、查询受限、运维复杂 |
| 典型场景 | 海量写入、时序/消息归档、多地域数据 |
| 入门提示 | 先理解分区键、副本因子、一致性级别 |

### 3.7 ClickHouse

| 项目 | 内容 |
|---|---|
| 目录 | `clickhosue/`（现有拼写，实际为 ClickHouse） |
| 官方定位 | 列式 OLAP 数据库 |
| 官网 | https://clickhouse.com/ |
| 开发语言 | C++ |
| 核心功能 | 列式存储、向量化查询、聚合分析 |
| 优势 | 聚合分析极快、压缩率高、成本低 |
| 局限 | 不适合高频点更新/事务；运维需经验 |
| 典型场景 | 日志分析、BI、指标大宽表、用户行为分析 |
| 入门提示 | 先理解 MergeTree、分区、排序键，不要当 MySQL 用 |

### 3.8 SQLite

| 项目 | 内容 |
|---|---|
| 目录 | `sqlite/` |
| 官方定位 | 嵌入式 SQL 数据库引擎 |
| 官网 | https://sqlite.org/ |
| 开发语言 | C |
| 核心功能 | 单文件数据库、SQL、事务 |
| 优势 | 零运维、轻量、可嵌入 |
| 局限 | 单写者、无网络服务、不适合高并发 |
| 典型场景 | 边缘程序、工具本地库、测试、移动端 |
| 入门提示 | 适合“一个程序一个库”，不适合多台机器共享写 |

---

## 4. 存储与文件

### 4.1 NFS

| 项目 | 内容 |
|---|---|
| 目录 | `nfs/` |
| 官方定位 | Linux 网络文件系统 |
| 官网 | https://nfs.sourceforge.net/ |
| 开发语言 | C（内核与用户态工具） |
| 核心功能 | 跨主机共享目录 |
| 优势 | 简单、Linux 原生、兼容好 |
| 局限 | 单点/锁/性能瓶颈，需 HA |
| 典型场景 | 共享目录、备份落盘、K8s PV |
| 入门提示 | 先学 `/etc/exports`、`showmount`、`mount -t nfs` |

### 4.2 Samba

| 项目 | 内容 |
|---|---|
| 目录 | `samba/` |
| 官方定位 | SMB/CIFS 文件和打印服务 |
| 官网 | https://www.samba.org/ |
| 开发语言 | C |
| 核心功能 | Windows 共享、域控、打印 |
| 优势 | Windows 兼容好、企业文件共享常用 |
| 局限 | 权限和性能调优复杂 |
| 典型场景 | 办公文件、Windows 共享、AD 域 |
| 入门提示 | 先学 `smb.conf`、`smbpasswd`、挂载方式 |

### 4.3 Ceph

| 项目 | 内容 |
|---|---|
| 目录 | `ceph/` |
| 官方定位 | 统一分布式存储系统 |
| 官网 | https://ceph.io/ |
| 开发语言 | C++/C/Python |
| 核心功能 | 块存储、文件系统、对象存储 |
| 优势 | 功能全、可扩展、社区成熟 |
| 局限 | 部署运维复杂，资源和网络要求高 |
| 典型场景 | 私有云、K8s PV、对象存储 |
| 入门提示 | 先理解 MON、OSD、MGR、PG，不要单机硬上生产 |

### 4.4 GlusterFS

| 项目 | 内容 |
|---|---|
| 目录 | `glusterfs/` |
| 官方定位 | 可扩展的分布式文件系统 |
| 官网 | https://www.gluster.org/ |
| 开发语言 | C |
| 核心功能 | 分布式文件、复制卷、条带卷 |
| 优势 | 横向扩展、POSIX 兼容 |
| 局限 | 小文件性能一般，运维复杂 |
| 典型场景 | 共享文件、媒体存储、K8s PV |
| 入门提示 | 先理解 volume 类型和 brick |

### 4.5 FastDFS

| 项目 | 内容 |
|---|---|
| 目录 | `fastdfs/` |
| 官方定位 | 轻量分布式文件系统 |
| 官网 | https://github.com/happyfish100/fastdfs |
| 开发语言 | C |
| 核心功能 | 文件上传、下载、同步、图片/附件存储 |
| 优势 | 部署简单、适合图片/附件 |
| 局限 | 生态较老、运维和一致性能力有限 |
| 典型场景 | 传统图片/附件服务、中小规模文件存储 |
| 入门提示 | 常配 Nginx 模块提供 HTTP 访问 |

### 4.6 SeaweedFS

| 项目 | 内容 |
|---|---|
| 目录 | `seaweedfs/` |
| 官方定位 | 分布式对象/文件存储 |
| 官网 | https://github.com/seaweedfs/seaweedfs |
| 开发语言 | Go |
| 核心功能 | 对象存储、文件存储、S3 兼容、海量小文件 |
| 优势 | 轻量、S3 兼容、小文件友好 |
| 局限 | 一致性和企业级运维能力弱于 Ceph |
| 典型场景 | 图片、附件、日志对象、轻量对象存储 |
| 入门提示 | 先理解 master、volume、filer |

### 4.7 JuiceFS

| 项目 | 内容 |
|---|---|
| 目录 | `juicefs/` |
| 官方定位 | 基于对象存储的 POSIX 文件系统 |
| 官网 | https://juicefs.com/ |
| 开发语言 | Go |
| 核心功能 | POSIX 文件系统、对象存储后端、共享挂载 |
| 优势 | 云原生、弹性、共享方便 |
| 局限 | 依赖元数据引擎和对象存储 |
| 典型场景 | 数据平台、AI 数据集、共享盘 |
| 入门提示 | 先理解 metadata engine 和 object store 两个后端 |

### 4.8 MinIO

| 项目 | 内容 |
|---|---|
| 目录 | `minio/`、`log-minio/` |
| 官方定位 | S3 兼容对象存储 |
| 官网 | https://min.io/ |
| 开发语言 | Go |
| 核心功能 | S3 API、桶、对象、生命周期、复制 |
| 优势 | 部署简单、S3 生态好、适合日志/备份 |
| 局限 | AGPL 许可证；单机不是生产 HA |
| 典型场景 | S3、日志归档、备份、数据湖 |
| 入门提示 | 先学 bucket、access key、S3 API |

---

## 5. 中间件与集成

### 5.1 Kafka

| 项目 | 内容 |
|---|---|
| 目录 | `kafka/` |
| 官方定位 | 分布式事件流平台 |
| 官网 | https://kafka.apache.org/ |
| 开发语言 | Java/Scala |
| 核心功能 | 发布订阅、持久化、分区、副本、流处理 |
| 优势 | 高吞吐、可回放、生态强 |
| 局限 | 运维复杂，需要 ZooKeeper/KRaft，调优门槛高 |
| 典型场景 | 日志、事件、解耦、流处理、数据管道 |
| 入门提示 | 先理解 topic、partition、offset、consumer group |

可以把 Kafka 理解成“可回放的传送带”：消息放上去，多个消费者可以按自己的节奏取。

### 5.2 RabbitMQ

| 项目 | 内容 |
|---|---|
| 目录 | `rabbitmq/` |
| 官方定位 | 开源消息代理 |
| 官网 | https://www.rabbitmq.com/ |
| 开发语言 | Erlang |
| 核心功能 | 队列、交换机、路由、确认、死信 |
| 优势 | 路由灵活、管理界面好、易上手 |
| 局限 | 超大规模吞吐低于 Kafka，Erlang 运维需学习 |
| 典型场景 | 业务解耦、任务队列、RPC、延迟队列 |
| 入门提示 | 先理解 exchange、queue、routing key |

### 5.3 RocketMQ

| 项目 | 内容 |
|---|---|
| 目录 | `rocketmq/` |
| 官方定位 | 分布式消息和流处理平台 |
| 官网 | https://rocketmq.apache.org/ |
| 开发语言 | Java |
| 核心功能 | 事务消息、顺序消息、延时消息、堆积 |
| 优势 | 金融/电商场景经验多、事务消息成熟 |
| 局限 | 生态和运维复杂度较高 |
| 典型场景 | 电商交易、订单、金融消息、削峰 |
| 入门提示 | 先理解 NameServer、Broker、Topic、消费组 |

### 5.4 ZooKeeper

| 项目 | 内容 |
|---|---|
| 目录 | `zookeeper/` |
| 官方定位 | 分布式协调服务 |
| 官网 | https://zookeeper.apache.org/ |
| 开发语言 | Java |
| 核心功能 | 选主、配置、命名、分布式锁 |
| 优势 | 成熟、稳定、Kafka/HBase 常用 |
| 局限 | 逐渐被 KRaft/etcd 替代；运维需谨慎 |
| 典型场景 | 选主、配置管理、分布式锁、旧版 Kafka |
| 入门提示 | 先理解 znode、session、watch |

### 5.5 Nacos

| 项目 | 内容 |
|---|---|
| 目录 | `nacos/` |
| 官方定位 | 动态服务发现、配置和服务管理平台 |
| 官网 | https://nacos.io/ |
| 开发语言 | Java |
| 核心功能 | 服务注册、配置中心、服务治理 |
| 优势 | Spring Cloud 集成好、功能完整 |
| 局限 | Java 生态为主，强一致和容量需规划 |
| 典型场景 | 微服务注册配置、动态配置 |
| 入门提示 | 先理解命名空间、服务、配置集 |

### 5.6 ELK

| 项目 | 内容 |
|---|---|
| 目录 | `elk/` |
| 官方定位 | Elasticsearch + Logstash + Kibana 搜索/日志分析栈 |
| 官网 | https://www.elastic.co/ |
| 开发语言 | Elasticsearch Java，Logstash JRuby/Java，Kibana TypeScript |
| 核心功能 | 全文检索、日志采集、可视化、聚合 |
| 优势 | 全文检索成熟、生态完整、可视化强 |
| 局限 | 资源占用高、许可证和集群运维复杂 |
| 典型场景 | 日志检索、审计、全文搜索、可观测性 |
| 入门提示 | 先理解 index、mapping、query DSL |

---

## 6. Kubernetes 与交付

### 6.1 k0s

| 项目 | 内容 |
|---|---|
| 目录 | `k0s/` |
| 官方定位 | 零依赖、单二进制的 Kubernetes 发行版 |
| 官网 | https://k0sproject.io/ |
| 开发语言 | Go |
| 核心功能 | 单二进制部署 K8s 控制面和工作节点 |
| 优势 | 部署简单、依赖少、适合实验/边缘 |
| 局限 | 生态和托管能力不如标准集群 |
| 典型场景 | 轻量 K8s、实验集群、边缘 |
| 入门提示 | 先理解 controller、worker、kubeconfig |

### 6.2 k3s

| 项目 | 内容 |
|---|---|
| 目录 | `k3s/` |
| 官方定位 | 轻量级 Kubernetes |
| 官网 | https://k3s.io/ |
| 开发语言 | Go |
| 核心功能 | 轻量 K8s、内置 SQLite/etcd 选项、边缘友好 |
| 优势 | 体积小、安装快、资源占用低 |
| 局限 | 默认组件裁剪，生产需补强 |
| 典型场景 | 边缘、分支、测试、资源受限环境 |
| 入门提示 | 先理解 server/agent 和 `k3s kubectl` |

### 6.3 Kubernetes（k8s-master / k8s-worker）

| 项目 | 内容 |
|---|---|
| 目录 | `k8s-master/`、`k8s-worker/` |
| 官方定位 | 容器编排平台 |
| 官网 | https://kubernetes.io/ |
| 开发语言 | Go |
| 核心功能 | 调度、服务发现、滚动发布、自愈、存储编排 |
| 优势 | 标准、生态完整、可扩展 |
| 局限 | 运维复杂，网络/存储/安全需额外设计 |
| 典型场景 | 生产容器平台、微服务 |
| 入门提示 | 先理解 Pod、Deployment、Service、Ingress、PV/PVC |

### 6.4 Harbor

| 项目 | 内容 |
|---|---|
| 目录 | `harbor/` |
| 官方定位 | 云原生容器镜像仓库 |
| 官网 | https://goharbor.io/ |
| 开发语言 | Go |
| 核心功能 | 镜像存储、RBAC、扫描、签名、复制 |
| 优势 | 企业级权限和镜像安全能力 |
| 局限 | 资源占用较高，依赖数据库/对象存储 |
| 典型场景 | 私有镜像仓库、供应链安全 |
| 入门提示 | 先理解 project、repository、robot account |

### 6.5 Jenkins

| 项目 | 内容 |
|---|---|
| 目录 | `jenkins/` |
| 官方定位 | 开源自动化服务器 |
| 官网 | https://www.jenkins.io/ |
| 开发语言 | Java |
| 核心功能 | 构建、测试、发布、流水线、定时任务 |
| 优势 | 插件多、灵活、老团队熟悉 |
| 局限 | 单点、插件兼容和安全维护成本高 |
| 典型场景 | CI/CD、构建、自动化任务 |
| 入门提示 | 先理解 Job、Pipeline、Agent、凭据 |

### 6.6 offline-yum

| 项目 | 内容 |
|---|---|
| 目录 | `offline-yum/` |
| 官方定位 | 项目自定义的离线 YUM 仓库包 |
| 官网 | 无单一上游官网，属于本地封装 |
| 开发语言 | Shell + RPM 打包 |
| 核心功能 | 内网安装依赖、固定 RPM 版本 |
| 优势 | 无外网安装、可重复 |
| 局限 | 只是裁剪仓库，不是完整发行版源 |
| 典型场景 | 内网、隔离环境、离线交付 |
| 入门提示 | 先理解 repo 文件、createrepo、依赖解析 |

---

## 7. 监控、日志与可观测性

### 7.1 Prometheus（server / agent）

| 项目 | 内容 |
|---|---|
| 目录 | `prometheus-server/`、`prometheus-agent/` |
| 官方定位 | 指标监控和告警系统 |
| 官网 | https://prometheus.io/ |
| 开发语言 | Go |
| 核心功能 | 拉取指标、PromQL、告警、服务发现 |
| 优势 | 云原生标准、查询强、生态好 |
| 局限 | 长期存储和 HA 需 Thanos/远程存储 |
| 典型场景 | K8s/主机/中间件监控、告警 |
| 入门提示 | 先理解 metric、label、PromQL、exporter |

### 7.2 Grafana

| 项目 | 内容 |
|---|---|
| 目录 | `log-grafana-prometheus/`，也随 Prometheus 包提供 |
| 官方定位 | 可视化和看板平台 |
| 官网 | https://grafana.com/oss/grafana/ |
| 开发语言 | Go + TypeScript |
| 核心功能 | 多数据源看板、图表、告警、共享 |
| 优势 | 可视化强、数据源多、社区仪表盘丰富 |
| 局限 | 本身不存储指标/日志，复杂权限需企业版 |
| 典型场景 | 监控看板、日志分析看板、业务大屏 |
| 入门提示 | 先理解 datasource、dashboard、panel |

### 7.3 Zabbix（server / agent）

| 项目 | 内容 |
|---|---|
| 目录 | `zabbix-server/`、`zabbix-agent/` |
| 官方定位 | 企业级监控解决方案 |
| 官网 | https://www.zabbix.com/ |
| 开发语言 | C，Web 前端 PHP |
| 核心功能 | 主机/网络/应用监控、告警、模板、自动发现 |
| 优势 | 传统 IDC/网络设备监控成熟、模板多 |
| 局限 | 资源较重，云原生体验一般 |
| 典型场景 | 传统 IDC、网络设备、主机监控 |
| 入门提示 | 先理解 host、item、trigger、action |

### 7.4 Uptime Kuma

| 项目 | 内容 |
|---|---|
| 目录 | `uptime-kuma/` |
| 官方定位 | 自托管可用性监控工具 |
| 官网 | https://uptime.kuma.pet/ |
| 开发语言 | JavaScript/Node.js |
| 核心功能 | HTTP/TCP/Ping 拨测、通知、状态页 |
| 优势 | 部署简单、通知渠道多、界面友好 |
| 局限 | 规模化和复杂 SLO 能力有限 |
| 典型场景 | 网站/接口存活监控、状态页 |
| 入门提示 | 适合小团队，不要替代完整 APM |

### 7.5 Fluent Bit

| 项目 | 内容 |
|---|---|
| 目录 | `log-fluent-bit/` |
| 官方定位 | 轻量日志和指标处理器 |
| 官网 | https://fluentbit.io/ |
| 开发语言 | C |
| 核心功能 | 采集、解析、过滤、转发日志 |
| 优势 | 轻量、资源占用低、K8s 友好 |
| 局限 | 复杂加工能力不如 Vector/Logstash |
| 典型场景 | 容器/主机日志采集 |
| 入门提示 | 先理解 input、filter、output |

### 7.6 OpenSearch（单机 / 集群）

| 项目 | 内容 |
|---|---|
| 目录 | `log-opensearch/`、`log-opensearch-cluster-master/`、`log-opensearch-cluster-worker/` |
| 官方定位 | 开源搜索和分析套件 |
| 官网 | https://opensearch.org/ |
| 开发语言 | Java |
| 核心功能 | 全文检索、聚合、日志分析、Dashboards |
| 优势 | 全文检索成熟、Apache 许可、生态完整 |
| 局限 | JVM 资源高、集群运维复杂 |
| 典型场景 | 日志检索、审计、安全分析、全文搜索 |
| 入门提示 | 先理解 index、mapping、query、shard |

### 7.7 OpenObserve

| 项目 | 内容 |
|---|---|
| 目录 | `log-openobserve/` |
| 官方定位 | 一体化可观测性平台 |
| 官网 | https://openobserve.ai/ |
| 开发语言 | Rust（后端），前端 TypeScript |
| 核心功能 | 日志、指标、链路、SQL 查询、告警、看板 |
| 优势 | 部署简单、成本低、SQL 友好 |
| 局限 | 生态较新，超大规模需验证 |
| 典型场景 | 单机日志平台、SLS 替代、可观测性入门 |
| 入门提示 | 适合快速搭建，不等于完整 SLO 平台 |

---

## 8. 大数据与数据平台

### 8.1 bigdata-base

| 项目 | 内容 |
|---|---|
| 目录 | `bigdata-base/` |
| 官方定位 | 项目自定义的大数据公共运行时 |
| 官网 | 无单一上游官网，属于本地封装 |
| 开发语言 | Shell + JDK/Conda |
| 核心功能 | 统一 JDK/Conda/主机名环境 |
| 优势 | 降低大数据组件环境差异 |
| 局限 | 只是基础环境，不是数据服务 |
| 典型场景 | Hadoop/Spark/Flink 集群前置 |
| 入门提示 | 先统一 JDK、Python、hosts，再装组件 |

### 8.2 Hadoop

| 项目 | 内容 |
|---|---|
| 目录 | `hadoop/` |
| 官方定位 | 分布式存储和计算框架 |
| 官网 | https://hadoop.apache.org/ |
| 开发语言 | Java |
| 核心功能 | HDFS、YARN、MapReduce |
| 优势 | 生态成熟、成本低、批处理强 |
| 局限 | 架构重、实时能力弱、运维复杂 |
| 典型场景 | 离线数仓、批处理、数据湖 |
| 入门提示 | 先理解 HDFS、YARN、NameNode/DataNode |

### 8.3 Hive

| 项目 | 内容 |
|---|---|
| 目录 | `hive/` |
| 官方定位 | Hadoop 上的 SQL 数据仓库 |
| 官网 | https://hive.apache.org/ |
| 开发语言 | Java |
| 核心功能 | SQL 转 MapReduce/Tez/Spark、元数据 |
| 优势 | SQL 门槛低、生态广 |
| 局限 | 延迟高，依赖 Hadoop |
| 典型场景 | 离线数仓、报表、ETL |
| 入门提示 | 先理解 database、table、partition、Metastore |

### 8.4 HBase

| 项目 | 内容 |
|---|---|
| 目录 | `hbase/` |
| 官方定位 | Hadoop 上的分布式宽表数据库 |
| 官网 | https://hbase.apache.org/ |
| 开发语言 | Java |
| 核心功能 | 海量随机读写、列族、Region |
| 优势 | 海量数据随机访问、可扩展 |
| 局限 | 依赖 ZooKeeper/HDFS，运维复杂 |
| 典型场景 | 明细查询、画像、时序、消息归档 |
| 入门提示 | 先理解 rowkey、column family、region |

### 8.5 Spark

| 项目 | 内容 |
|---|---|
| 目录 | `spark/` |
| 官方定位 | 统一分析引擎 |
| 官网 | https://spark.apache.org/ |
| 开发语言 | Scala/Java/Python/R |
| 核心功能 | 批处理、流处理、SQL、MLlib、GraphX |
| 优势 | 内存计算快、生态完整、API 多 |
| 局限 | 资源消耗大，调优复杂 |
| 典型场景 | 离线计算、特征工程、ETL、机器学习 |
| 入门提示 | 先理解 RDD/DataFrame、Driver/Executor |

### 8.6 Flink

| 项目 | 内容 |
|---|---|
| 目录 | `flink/` |
| 官方定位 | 流处理框架 |
| 官网 | https://flink.apache.org/ |
| 开发语言 | Java/Scala |
| 核心功能 | 事件流、窗口、状态、Exactly-Once、批流一体 |
| 优势 | 低延迟、状态管理强、实时计算成熟 |
| 局限 | 运维和状态调优复杂 |
| 典型场景 | 实时风控、实时数仓、事件处理 |
| 入门提示 | 先理解 DataStream、watermark、checkpoint |

### 8.7 Flume

| 项目 | 内容 |
|---|---|
| 目录 | `flume/` |
| 官方定位 | 日志采集、聚合和传输 |
| 官网 | https://flume.apache.org/ |
| 开发语言 | Java |
| 核心功能 | Source/Channel/Sink 日志管道 |
| 优势 | 与 Hadoop 生态集成好、配置简单 |
| 局限 | 社区活跃度下降，复杂加工弱 |
| 典型场景 | 日志入 HDFS、日志聚合 |
| 入门提示 | 先理解 source、channel、sink |

### 8.8 Tez

| 项目 | 内容 |
|---|---|
| 目录 | `tez/` |
| 官方定位 | Hadoop DAG 执行框架 |
| 官网 | https://tez.apache.org/ |
| 开发语言 | Java |
| 核心功能 | 优化 Hive/Pig 的 DAG 执行 |
| 优势 | 减少中间落盘、加速 Hive |
| 局限 | 生态较窄，主要服务 Hive |
| 典型场景 | Hive 查询加速、批处理 DAG |
| 入门提示 | 先理解 DAG、vertex、edge |

### 8.9 Airflow

| 项目 | 内容 |
|---|---|
| 目录 | `airflow/` |
| 官方定位 | 工作流编排和调度平台 |
| 官网 | https://airflow.apache.org/ |
| 开发语言 | Python |
| 核心功能 | DAG 调度、依赖管理、任务重试、UI |
| 优势 | DAG 表达强、插件多、Python 友好 |
| 局限 | 不适合毫秒级流调度，运维需数据库/Executor |
| 典型场景 | 离线 ETL、数据管道、定时任务 |
| 入门提示 | 先理解 DAG、Operator、Scheduler、Executor |

### 8.10 Superset

| 项目 | 内容 |
|---|---|
| 目录 | `superset/` |
| 官方定位 | 开源 BI 和数据探索平台 |
| 官网 | https://superset.apache.org/ |
| 开发语言 | Python + TypeScript |
| 核心功能 | SQL 查询、图表、看板、权限 |
| 优势 | 开源、图表丰富、SQL 友好 |
| 局限 | 权限/性能/运维需加强 |
| 典型场景 | 报表、数据探索、业务看板 |
| 入门提示 | 先理解 database、dataset、chart、dashboard |

---

## 9. 安全、AI 与其他

### 9.1 Keycloak

| 项目 | 内容 |
|---|---|
| 目录 | `keycloak/` |
| 官方定位 | 身份和访问管理（IAM） |
| 官网 | https://www.keycloak.org/ |
| 开发语言 | Java |
| 核心功能 | SSO、OIDC、SAML、RBAC、用户联邦 |
| 优势 | 标准协议、功能完整、生态成熟 |
| 局限 | Java 资源占用，定制需经验 |
| 典型场景 | 统一登录、SSO、多系统身份 |
| 入门提示 | 先理解 realm、client、user、role |

### 9.2 Vault

| 项目 | 内容 |
|---|---|
| 目录 | `vault/` |
| 官方定位 | 密钥、证书和凭据管理 |
| 官网 | https://www.vaultproject.io/ |
| 开发语言 | Go |
| 核心功能 | 密钥存储、动态凭据、PKI、加密即服务 |
| 优势 | 功能强、动态凭据、审计 |
| 局限 | BUSL 许可证，HA/解封运维复杂 |
| 典型场景 | 密钥托管、动态数据库凭据、PKI |
| 入门提示 | 严格开源场景可关注 OpenBao，不要把它当普通配置中心 |

### 9.3 AI Base

| 项目 | 内容 |
|---|---|
| 目录 | `ai-base/` |
| 官方定位 | 项目自定义的 AI 智能体公共运行时 |
| 官网 | 无单一上游官网，属于本地封装 |
| 开发语言 | Shell + Python/Node.js |
| 核心功能 | Miniconda、Node、pnpm、gh、tmux |
| 优势 | 统一 AI 工具环境 |
| 局限 | 只是运行时，不是模型服务 |
| 典型场景 | AI Agent、Claude Code、Codex、DeepSeek 前置 |
| 入门提示 | 先装运行时，再装具体 AI 工具 |

### 9.4 Ollama

| 项目 | 内容 |
|---|---|
| 目录 | `ollama/` |
| 官方定位 | 本地大模型运行和管理工具 |
| 官网 | https://ollama.com/ |
| 开发语言 | Go |
| 核心功能 | 模型下载、运行、API、GPU/CPU 推理 |
| 优势 | 部署简单、模型管理方便、适合内网 |
| 局限 | 依赖硬件，多租户和生产治理弱 |
| 典型场景 | 内网 LLM、原型验证、私有模型 |
| 入门提示 | 先确认 CPU/GPU、内存和模型大小 |

### 9.5 Claude Code

| 项目 | 内容 |
|---|---|
| 目录 | `claude-code/` |
| 官方定位 | Anthropic 的终端 AI 编码代理 |
| 官网 | https://www.anthropic.com/claude-code |
| 开发语言 | 官方 CLI，具体实现以发布包为准 |
| 核心功能 | 代码阅读、修改、命令执行、任务规划 |
| 优势 | 代码理解和交互体验强 |
| 局限 | 依赖账号/API/网络，输出需人工审核 |
| 典型场景 | 研发辅助、代码审查、重构 |
| 入门提示 | 先配 API/账号，不要直接在生产库上执行 |

### 9.6 Codex

| 项目 | 内容 |
|---|---|
| 目录 | `codex/` |
| 官方定位 | OpenAI 的编码代理/CLI |
| 官网 | https://openai.com/codex/ |
| 开发语言 | 官方 CLI，具体实现以版本仓库为准 |
| 核心功能 | 代码生成、修改、命令执行 |
| 优势 | 与 OpenAI 生态集成 |
| 局限 | 依赖 API Key，输出需审核 |
| 典型场景 | 代码生成、自动化、研发辅助 |
| 入门提示 | 在隔离工作区和测试分支使用 |

### 9.7 DeepSeek

| 项目 | 内容 |
|---|---|
| 目录 | `deepseek/` |
| 官方定位 | DeepSeek dsh-superagent 研究原型 |
| 官网 | https://www.deepseek.com/ |
| 开发语言 | 原型运行时，具体以发布包为准 |
| 核心功能 | 智能体实验、任务执行 |
| 优势 | 低成本、可本地化 |
| 局限 | 研究原型，不是稳定生产版 |
| 典型场景 | 实验、内部助手、原型验证 |
| 入门提示 | 只用于实验，不承诺生产稳定性 |

### 9.8 Octop

| 项目 | 内容 |
|---|---|
| 目录 | `octop/` |
| 官方定位 | 项目内的 AI Agent Web 控制台 |
| 官网 | 以项目 README 为准 |
| 开发语言 | 以项目 README/发布包为准 |
| 核心功能 | 管理、访问 AI 智能体 |
| 优势 | 统一入口、方便实验 |
| 局限 | 版本较新，生产验证不足 |
| 典型场景 | AI 实验平台、内部工具 |
| 入门提示 | 先装 `ai-base`，再装 Octop |

---

## 10. 初学者学习顺序

### 阶段 1：Linux 和网络基础

```text
Linux 命令
IP/端口/防火墙
DNS/HTTPS
Nginx 反向代理
```

推荐先学：

```text
Nginx + JDK + PostgreSQL/MySQL + Redis
```

### 阶段 2：数据与消息

```text
PostgreSQL/MySQL 基础
Redis 缓存
Kafka/RabbitMQ 消息
备份和恢复
```

### 阶段 3：容器与平台

```text
Docker
Kubernetes
Harbor
Jenkins
```

### 阶段 4：可观测性

```text
Prometheus + Grafana
Fluent Bit + OpenSearch/OpenObserve
告警和日志保留
```

### 阶段 5：大数据

```text
Hadoop/Hive
Spark
Flink
Airflow/Superset
```

### 阶段 6：安全与 AI

```text
Keycloak
Vault/OpenBao
Ollama
AI 编码工具
```

## 11. 典型架构选型

### 11.1 小型单体应用

```text
Nginx
JDK + Tomcat
PostgreSQL 或 MySQL
Redis
Prometheus + Grafana
```

### 11.2 中型微服务

```text
Nginx / APISIX
Spring Cloud + Nacos
PostgreSQL/MySQL
Redis
Kafka/RabbitMQ
Kubernetes
OpenSearch
Prometheus + Grafana
```

### 11.3 大数据平台

```text
Hadoop + Hive
Spark
Flink
Kafka
Airflow
Superset
MinIO/Ceph
```

### 11.4 银行/金融

```text
Keycloak
Vault/OpenBao
PostgreSQL/MySQL HA
Redis Sentinel
Kafka/RocketMQ
Flowable/Drools
OpenSearch 审计
备份/容灾
```

### 11.5 工程/GIS

```text
PostgreSQL + PostGIS
GeoServer
MinIO/Ceph
OpenProject/Redmine
Nginx
Keycloak
```

### 11.6 商城/电商

```text
Nginx 或 APISIX
MySQL/PostgreSQL
Redis
Kafka
OpenSearch
MinIO
imgproxy
Hyperswitch
Prometheus/Grafana
```

## 12. 生产环境补充项

现有仓库已有组件不等于生产完备，建议优先补：

```text
Keepalived + VIP
Chrony
CoreDNS
数据库 HA 和备份
step-ca / cert-manager
WAF
Trivy / SonarQube
Jaeger / Tempo
APISIX / Kong
Nexus / Gitea / Argo CD
```

完整缺口见：

```text
PRODUCTION-COMPONENT-CATALOG.md
```

## 13. 快速结论

- 先学“入口 + 数据库 + 缓存 + 监控”，这是最小闭环。
- 消息队列按吞吐和路由需求选 Kafka/RabbitMQ/RocketMQ。
- 存储按接口选：文件用 NFS/Samba，对象用 MinIO/Ceph，海量小文件用 SeaweedFS。
- Kubernetes 不是必须；单机业务先不要上 K8s。
- 日志和监控是两套系统：Prometheus 看指标，OpenSearch/OpenObserve 看日志。
- AI 工具先当研发辅助，不要直接给生产写权限。
- 所有生产组件都要考虑：高可用、备份、监控、证书、安全、容灾。
