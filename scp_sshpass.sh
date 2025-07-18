#!/bin/bash

# 配置文件路径（格式：IP 端口 密码）
CONFIG_FILE="hosts.config"

# 待分发的文件路径
SOURCE_FILE="/data/bzc/yunwei/ssh45.sh"

# 目标路径
TARGET_DIR="/data/bzc/yunwei/"

# 检查配置文件是否存在
if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "错误：配置文件 $CONFIG_FILE 不存在！"
    exit 1
fi

# 逐行读取配置
while IFS= read -r line; do
    # 跳过注释行和空行
    [[ "$line" =~ ^#|^$ ]] && continue

    # 解析参数（支持密码含空格）
    ip=$(echo "$line" | awk '{print $1}')
    port=$(echo "$line" | awk '{print $2}')
    password=$(echo "$line" | awk '{$1=$2=""; print substr($0,3)}' | xargs)

    echo "正在分发到主机 $ip ..."

    # 使用 printf 转义特殊字符
    escaped_password=$(printf "%q" "$password")

    # 执行分发命令
    eval "sshpass -p $escaped_password scp -o StrictHostKeyChecking=no -P $port \"$SOURCE_FILE\" \"root@$ip:$TARGET_DIR\""

    # 检查执行结果
    if [[ $? -eq 0 ]]; then
        echo "[成功] $ip 分发完成"
    else
        echo "[失败] $ip 分发失败"
    fi
done < "$CONFIG_FILE"

echo "全部分发操作完成。"