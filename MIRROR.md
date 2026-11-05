# 镜像说明

## 仓库定位

| 仓库 | 地址 | 内容 |
|---|---|---|
| AtomGit | https://atomgit.com/shamoyeyu/Automated_Deployment | 主仓库、主存储、完整部署包 |
| GitHub | https://github.com/Wei131488/weizt | README、目录、校验清单、GitHub Release 镜像 |
| Gitee | https://gitee.com/Gitlab_wztwei/automated_-deployment | README、目录、说明 |

## 同步规则

- AtomGit 是唯一主存储；所有安装包、脚本、SHA256 以 AtomGit 为准。
- GitHub 只同步文档和小体积清单；大包通过 GitHub Release 手动发布。
- Gitee 受单仓库附件 1 GB 限制，只同步 README 和目录说明。
- GitHub/Gitee 的 README 不替代 AtomGit 的版本和包内容。

## 2026-11 新增组件

| 目录 | 组件 | AtomGit 位置 |
|---|---|---|
| `jenkins/` | Jenkins 2.580.1 | `Automated_Deployment/jenkins/` |
| `opengauss/` | openGauss 7.0.0 LTS | `Automated_Deployment/opengauss/` |
| `tidb/` | TiDB 8.5.8 | `Automated_Deployment/tidb/` |
| `oceanbase/` | OceanBase CE 4.6.0.1 | `Automated_Deployment/oceanbase/` |
| `log-*` | OpenObserve / OpenSearch / Fluent Bit / MinIO / Grafana+Prometheus | `Automated_Deployment/log-*` |

## 校验

完整校验清单：

```text
UNDEPLOYED-SHA256SUMS.txt
```

只对 AtomGit 中的实际文件有效；镜像仓库不保证包含全部二进制包。
