# 生产环境组件完备性目录（银行 / 工程 / 商城）

本文件基于 `E:\gitfile\02\Automated_Deployment` 现有目录和压缩包做静态盘点，只做组件规划，不修改现有部署包。

## 一、结论

现有仓库已经覆盖：

- 基础运行时、反向代理、部分负载均衡
- 关系型数据库、NoSQL、缓存、搜索
- 消息队列、注册配置中心
- 文件/对象/分布式存储
- Hadoop/Spark/Flink 等大数据组件
- Prometheus/Zabbix/Grafana/Uptime Kuma 监控
- OpenSearch/ELK/OpenObserve/Fluent Bit 日志
- Keycloak/Vault 身份与密钥
- k0s/k3s/kubeadm/Harbor
- Jenkins

但从**银行、工程、商城生产环境**角度看，仍然缺少以下关键模块：

| 缺口 | 影响 |
|---|---|
| 高可用 VIP / Keepalived | 单机代理和入口无法故障切换 |
| 内网 DNS / NTP | 生产环境域名解析和时间同步缺失 |
| 数据库 HA / 读写分离 / 备份 | 现有数据库多为单机包，不满足生产 RPO/RTO |
| 证书与 PKI | 缺少内部 CA、证书自动签发和轮换 |
| WAF / 安全扫描 | 缺少 Web 防护、镜像扫描、代码质量门禁 |
| API 网关 / 服务网格 | 缺少统一鉴权、限流、灰度、服务治理 |
| 链路追踪 / 长期指标 | 只有监控和日志，缺少 APM/Tracing |
| 配置管理与 IaC | 仍以手工脚本为主，缺少可重复交付 |
| 制品库 / GitOps | Jenkins 单点，缺少制品、代码托管和 GitOps |
| 数据集成 / CDC | 缺少数据库到数据平台的实时同步 |
| BPM / 规则引擎 | 银行审批、风控规则缺业务中间件 |
| 行业应用组件 | 缺少银行核心、工程 GIS/文档、商城交易/支付类开源应用 |

## 二、生产组件表达目录

标记说明：

- `[已有]`：仓库已有安装包
- `[需补]`：建议新增
- `[可选]`：按行业或规模选择
- `[单机]`：已有但当前只是单机/最小化，生产需补集群或 HA 包

```text
Automated_Deployment/
├── 00-base/                                 基础与高可用
│   ├── offline-yum/                         [已有] 离线 YUM
│   ├── java/                                [已有] JDK
│   ├── keepalived/                          [需补] VIP/VRRP 高可用
│   ├── chrony/                              [需补] NTP 时间同步
│   ├── coredns/                             [需补] 内网 DNS
│   ├── bind9/                               [可选] 传统 DNS
│   ├── ansible/                             [需补] 配置管理
│   ├── opentofu/                            [可选] IaC
│   ├── auditd-aide/                         [需补] 主机审计与文件完整性
│   └── openscap/                            [需补] 基线合规扫描
│
├── 10-network/                              网络与入口
│   ├── nginx/                               [已有]
│   ├── caddy/                               [已有]
│   ├── haproxy/                             [已有]
│   ├── envoy/                               [已有]
│   ├── traefik/                             [已有]
│   ├── frp/                                 [已有]
│   ├── squid/                               [已有]
│   ├── apisix/                              [需补] API 网关
│   ├── kong/                                [可选] API 网关
│   ├── ingress-nginx/                       [需补] K8s 入口
│   ├── modsecurity-coraza/                  [需补] WAF
│   ├── istio/                               [可选] 服务网格
│   └── cilium/                              [可选] eBPF 网络与安全
│
├── 20-security/                             身份、安全、合规
│   ├── keycloak/                            [已有] SSO/OIDC
│   ├── vault/                               [已有][单机] 密钥管理
│   ├── openbao/                             [需补] Vault 的 MPL 开源替代
│   ├── openldap/                            [需补] 企业目录
│   ├── freeipa/                             [可选] Linux 身份域
│   ├── step-ca/                             [需补] 内部 CA
│   ├── cert-manager/                        [需补] K8s 证书自动签发
│   ├── teleport/                            [可选] 堡垒机/审计
│   ├── jumpserver/                          [可选] 国产堡垒机
│   ├── trivy/                               [需补] 镜像/依赖漏洞扫描
│   ├── sonarqube/                           [需补] 代码质量门禁
│   ├── dependency-track/                    [需补] SBOM/依赖风险
│   └── clamav/                              [需补] 文件病毒扫描
│
├── 30-data/                                 数据层
│   ├── postgresql/                          [已有][单机]
│   ├── mysql/                               [已有][单机]
│   ├── mariadb/                             [已有][单机]
│   ├── redis/                               [已有][单机]
│   ├── mongodb/                             [已有][单机]
│   ├── cassandra/                           [已有]
│   ├── clickhouse/                          [已有][单机]
│   ├── sqlite/                              [已有]
│   ├── tidb/                                [需补] 分布式 SQL
│   ├── oceanbase/                           [需补] 分布式 SQL
│   ├── opengauss/                           [需补] 国产集中式/分布式数据库
│   ├── patroni/                             [需补] PostgreSQL HA
│   ├── pgbouncer/                           [需补] PostgreSQL 连接池
│   ├── pgbackrest/                          [需补] PostgreSQL 备份
│   ├── mysql-router-proxysql/               [需补] MySQL HA/读写分离
│   ├── xtrabackup/                          [需补] MySQL 物理备份
│   ├── redis-sentinel-cluster/              [需补] Redis HA
│   ├── mongodb-replicaset/                  [需补] MongoDB 副本集
│   └── database-migration/                  [需补] Flyway/Liquibase
│
├── 40-middleware/                           中间件与集成
│   ├── kafka/                               [已有]
│   ├── rabbitmq/                            [已有]
│   ├── rocketmq/                            [已有]
│   ├── zookeeper/                           [已有]
│   ├── nacos/                               [已有]
│   ├── seata/                               [需补] 分布式事务
│   ├── sentinel/                            [需补] 流控/熔断
│   ├── shardingsphere/                     [需补] 分库分表/加密
│   ├── flowable/                            [需补] BPM 工作流
│   ├── camunda/                             [可选] BPM
│   ├── drools/                              [需补] 规则引擎
│   └── postfix/                             [需补] 邮件发送
│
├── 50-app-delivery/                        应用交付
│   ├── k0s/                                 [已有] 容器化 Kubernetes
│   ├── k3s/                                 [已有] 轻量 Kubernetes
│   ├── k8s-master/                          [已有] kubeadm 控制面
│   ├── k8s-worker/                          [已有] kubeadm 工作节点
│   ├── ingress-nginx/                       [需补] K8s 入口
│   ├── cert-manager/                        [需补] K8s 证书
│   ├── velero/                              [需补] K8s 备份
│   ├── jenkins/                             [已有][单机]
│   ├── harbor/                              [已有]
│   ├── gitea/                               [需补] 轻量 Git 服务
│   ├── gitlab-ce/                           [可选] 一体化 DevOps
│   ├── nexus-oss/                           [需补] Maven/npm/制品库
│   ├── argocd/                              [需补] GitOps
│   ├── argo-workflows/                      [可选] 流水线
│   ├── keda/                                [可选] K8s 事件驱动伸缩
│   ├── kyverno/                             [可选] K8s 策略
│   └── opa-gatekeeper/                      [可选] K8s 准入策略
│
├── 60-observability/                        监控、日志、追踪
│   ├── prometheus-server/                   [已有]
│   ├── prometheus-agent/                    [已有]
│   ├── alertmanager/                        [已有] 随 Prometheus
│   ├── grafana/                             [已有]
│   ├── zabbix-server/                       [已有]
│   ├── zabbix-agent/                        [已有]
│   ├── uptime-kuma/                         [已有]
│   ├── thanos/                              [需补] 长期指标
│   ├── victoriametrics/                     [可选] 长期指标
│   ├── jaeger/                              [需补] 链路追踪
│   ├── tempo/                               [可选] Trace 存储
│   ├── skywalking/                          [可选] APM
│   ├── opensearch/                          [已有]
│   ├── elk/                                 [已有]
│   ├── openobserve/                         [已有]
│   ├── fluent-bit/                          [已有]
│   └── vector/                              [可选] 采集
│
├── 70-data-platform/                        数据平台
│   ├── hadoop/                              [已有]
│   ├── hive/                                [已有]
│   ├── hbase/                               [已有]
│   ├── spark/                               [已有]
│   ├── flink/                               [已有]
│   ├── flume/                               [已有]
│   ├── tez/                                 [已有]
│   ├── airflow/                             [已有]
│   ├── superset/                            [已有]
│   ├── dolphinscheduler/                    [需补] 调度
│   ├── seatunnel/                           [需补] 数据集成
│   ├── datax/                               [可选] 批量同步
│   ├── debezium/                            [需补] CDC
│   ├── great-expectations/                  [需补] 数据质量
│   ├── datahub/                             [可选] 数据目录
│   └── openmetadata/                        [可选] 元数据
│
├── 80-storage/                              存储与备份
│   ├── nfs/                                 [已有]
│   ├── samba/                               [已有]
│   ├── ceph/                                [已有]
│   ├── glusterfs/                           [已有]
│   ├── fastdfs/                             [已有]
│   ├── seaweedfs/                           [已有]
│   ├── juicefs/                             [已有]
│   ├── minio/                               [已有]
│   ├── velero/                              [需补] K8s 备份
│   ├── restic/                              [需补] 主机/文件备份
│   └── rsync/                               [需补] 文件同步
│
├── 90-business/                             行业业务组件（可选）
│   ├── banking/
│   │   ├── fineract/                        Apache Fineract 核心银行
│   │   ├── flowable/                        BPM 审批
│   │   ├── drools/                          风控规则
│   │   └── hyperswitch/                     支付网关
│   ├── engineering/
│   │   ├── openproject/                     项目管理
│   │   ├── redmine/                         缺陷/工单
│   │   ├── geoserver/                       GIS 服务
│   │   ├── postgis/                         空间数据库
│   │   ├── paperless-ngx/                   工程文档
│   │   └── freecad-ifcopenshell/            CAD/BIM
│   └── mall/
│       ├── saleor/                          Headless 电商
│       ├── magento/                         电商平台
│       ├── opencart/                        轻量商城
│       ├── hyperswitch/                     支付编排
│       ├── imgproxy/                        图片处理
│       └── metarank/                        推荐排序（可选）
│
└── 99-ops/                                  运维与交付规范
    ├── runbook/                             运维手册
    ├── backup-policy/                       备份策略
    ├── dr-plan/                             容灾演练
    ├── cmdb/                                资产与配置
    ├── log-retention/                       日志保留
    └── security-baseline/                   安全基线
```

## 三、按行业看缺口

### 3.1 银行/金融

生产必需但当前不足：

1. 数据库高可用：PostgreSQL Patroni/PgBouncer、MySQL Router/ProxySQL、Redis Sentinel、MongoDB Replica Set。
2. 备份与容灾：pgBackRest、XtraBackup、restic、异地备份。
3. 审计与合规：auditd、AIDE、OpenSCAP、集中日志保留。
4. 身份与密钥：Keycloak、OpenBao、step-ca、cert-manager。
5. 交易与流程：Flowable、Drools、Seata。
6. 数据平台：TiDB/OceanBase/openGauss、Debezium、数据质量。
7. 安全：WAF、镜像扫描、代码质量门禁、SBOM。

建议优先补：

```text
keepalived
patroni + pgbouncer + pgbackrest
mysql-router/proxysql + xtrabackup
redis-sentinel-cluster
flowable
drools
step-ca
openbao
auditd-aide-openscap
trivy
```

### 3.2 工程/设计/GIS

缺口：

- PostGIS/GeoServer 空间数据服务
- OpenProject/Redmine 项目管理
- Paperless-ngx 文档管理
- FreeCAD/IfcOpenShell 的 CAD/BIM 处理
- 大文件对象存储和版本化
- 图纸/文档病毒扫描

现有可复用：

```text
postgresql
minio / ceph / seaweedfs
nginx
keycloak
opensearch
```

### 3.3 商城/电商

缺口：

- API 网关：APISIX/Kong
- 搜索：OpenSearch 已有
- 缓存/队列：Redis/Kafka 已有
- 图片处理：imgproxy
- 支付编排：Hyperswitch
- CMS/商品内容：Saleor/Strapi
- 推荐：Metarank（可选）
- WAF/风控：ModSecurity、Drools
- CDN/边缘缓存：Varnish 或现有 Nginx

## 四、优先级建议

### P0：生产基础

```text
keepalived
chrony
coredns
step-ca / cert-manager
patroni + pgbouncer + pgbackrest
mysql-router/proxysql + xtrabackup
redis-sentinel-cluster
mongodb-replicaset
restic / velero
modsecurity-coraza
trivy
jaeger/tempo
apisix
```

### P1：交付与数据

```text
gitea
nexus-oss
argocd
sonarqube
openbao
openldap
seata
sentinel
shardingsphere
debezium
seatunnel
dolphinscheduler
```

### P2：行业与增强

```text
flowable
drools
geoserver/postgis
openproject
paperless-ngx
saleor/magento
hyperswitch
istio/cilium
thanos/victoriametrics
datahub/openmetadata
```

## 五、许可证提醒

以下组件许可证需要重点核对，不能简单标为“完全开源免费”：

| 组件 | 风险 |
|---|---|
| Vault | BUSL，不是 OSI 开源；严格开源可用 OpenBao |
| Redis | 新版许可证有变化；可用 Valkey（BSD）替代 |
| MongoDB | SSPL；严格开源可用 FerretDB |
| Elasticsearch/Kibana | 许可证与 OpenSearch 不同，优先 OpenSearch |
| Jenkins | MIT，但插件生态许可证需逐个检查 |
| MinIO | AGPL，商业分发需评估 |
| Grafana/Loki | AGPL，商业分发需评估 |
| SonarQube | 社区版功能与许可证需核对 |

## 六、建议实施顺序

```text
第 1 批：入口高可用 + 时间/DNS + 备份
第 2 批：数据库 HA + 证书 + WAF/扫描
第 3 批：API 网关 + 链路追踪 + 长期指标
第 4 批：Git/制品/GitOps + 数据集成/调度
第 5 批：BPM/规则引擎 + 行业业务组件
```

不要把业务应用和基础组件混在同一层；基础组件先稳定，再叠加银行、工程、商城业务模块。

## 七、说明

- 本目录只做“完备性规划”，未下载、未安装、未验证新增组件。
- `[已有]` 只表示仓库已有安装包，不等于已经达到生产高可用。
- 现有数据库、中间件多为单机/最小化包，生产前必须补 HA、备份、监控和容灾。
- 建议后续新增组件继续采用：

```text
<component>/install_<component>.zip
scripts/install.sh
README.md
SHA256SUMS.txt
```

并保持 101 首次部署、104 二次验证的流程。
