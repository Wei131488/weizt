#!/bin/bash

# 设置Redis版本和部署包路径
redis_version="5.0.14"          # 指定Redis版本
local_path="/data/bzc/plugin"    # 指定部署包的本地路径
redis_tarball="redis-${redis_version}.tar.gz"  # Redis压缩包文件名
redis_source_dir="${local_path}/redis-${redis_version}"  # 解压后的Redis源码目录

# 配置节点的IP地址和密码
nodes=("192.168.1.1" "192.168.2.2" "192.168.3.3")  # Redis节点的IP地址集合
redis_pwd="your_redis_password"  # Redis的访问密码
master_node="192.168.1.1"         # 主节点的IP地址

# 模式选择
single_mode=false  # 设置为true以启用单机模式
cluster_mode=true  # 设置为true以启用集群模式

# 解压Redis源码包
tar xf ${local_path}/${redis_tarball} -C ${local_path}  # 解压文件到指定路径

# 进入解压后的Redis目录并编译
cd ${redis_source_dir}           # 切换到Redis源码目录
make                             # 编译Redis

# 修改redis.conf配置文件，使其以daemon模式运行
sed -i 's/daemonize no/daemonize yes/' redis.conf

# 部署单机模式
if [ "$single_mode" == true ]; then
    echo "部署单机模式..."
    conf_file="${redis_source_dir}/redis-single.conf"
    cp redis.conf ${conf_file}
    echo "
bind 127.0.0.1  # 仅在本地监听
requirepass ${redis_pwd}
" >> ${conf_file}
    ${redis_source_dir}/src/redis-server ${conf_file}  # 启动单机Redis实例
    ps -aux | grep redis | grep -v grep  # 检查单机实例是否运行
fi

# 部署集群模式
if [ "$cluster_mode" == true ]; then
    echo "部署集群模式..."
    cluster_nodes=("192.168.1.1" "192.168.2.2" "192.168.3.3")  # 集群节点数组
    cluster_passwords=("pwd1" "pwd2" "pwd3")  # 每个节点的密码数组

    for i in "${!cluster_nodes[@]}"; do
        node=${cluster_nodes[$i]}
        pwd=${cluster_passwords[$i]}
        
        conf_file="${redis_source_dir}/redis-${node}.conf"
        cp redis.conf ${conf_file}
        echo "
bind ${node}
requirepass ${pwd}
cluster-enabled yes
cluster-config-file nodes-${node}.conf
cluster-node-timeout 5000
" >> ${conf_file}

        # 启动集群节点
        if [ "${node}" == "${master_node}" ]; then
            ${redis_source_dir}/src/redis-server ${conf_file}  # 启动主节点
        else
            # 启动从节点，通过SSH执行远程命令
            ssh ${node} "mkdir -p ${redis_source_dir} && cp ${local_path}/${redis_tarball} ${redis_source_dir} && tar xf ${redis_source_dir}/${redis_tarball} -C ${redis_source_dir} && cd ${redis_source_dir} && make && cp redis.conf ${conf_file} && echo '
bind ${node}
requirepass ${pwd}
cluster-enabled yes
cluster-config-file nodes-${node}.conf
cluster-node-timeout 5000
' >> ${conf_file} && ${redis_source_dir}/src/redis-server ${conf_file}"
        fi
    done

    # 创建集群
    echo "创建集群..."
    redis-cli -h ${master_node} -a ${redis_pwd} --cluster create ${cluster_nodes[@]/#/} --cluster-replicas 1  # 创建集群并配置从节点
fi

echo "Redis部署完成"
