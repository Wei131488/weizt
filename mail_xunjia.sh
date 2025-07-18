#!/bin/bash

# 自定义主机名称
HOST_NAME="测试"

# 设置资源使用阈值（可以手动调整）
CPU_THRESHOLD=90
MEMORY_THRESHOLD=90
DISK_THRESHOLD=90

# 收件人邮箱列表
RECIPIENTS="weizhenting@chinabzc.com"
SUBJECT="Resource Utilization Alert on $(hostname)"
ALERT_FILE="/data/bzc/yunwei/resource_alert.txt"

# 获取主机 IP 地址
INTERNAL_IP_ADDRESS=$(hostname -I | awk '{for(i=1;i<=NF;i++) if ($i ~ /^192\.168\.|^10\.|^172\./) print $i}')
PUBLIC_IP_ADDRESS=$(curl -s ifconfig.me)

# 获取系统版本信息
SYSTEM_INFO=$(cat /etc/os-release | grep PRETTY_NAME | cut -d '=' -f 2 | tr -d '\"')

# 获取资源使用情况
check_cpu() {
    CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')
}

check_memory() {
    MEMORY_USAGE=$(free | grep Mem | awk '{print $3/$2 * 100.0}')
}

check_disk() {
    DISK_USAGE=$(df -h / | grep '/' | awk '{print $5}' | sed 's/%//g')
}

# 清空旧的告警文件
> $ALERT_FILE

# 写入系统信息
echo "Host Name: $HOST_NAME" >> $ALERT_FILE
echo "Internal IP Address: $INTERNAL_IP_ADDRESS" >> $ALERT_FILE
echo "Public IP Address: $PUBLIC_IP_ADDRESS" >> $ALERT_FILE
echo "CPU Cores: $(nproc)" >> $ALERT_FILE
echo "Memory Size: $(free -h | awk '/^Mem:/{print $2}')" >> $ALERT_FILE
echo "OS Version: $SYSTEM_INFO" >> $ALERT_FILE
echo "System Disk Space: $(df -h / | awk 'NR==2{print $2}')" >> $ALERT_FILE
echo "Data Disk Space: $(df -h /data | awk 'NR==2{print $2}')" >> $ALERT_FILE
echo "" >> $ALERT_FILE

# 检查资源使用情况
check_cpu
check_memory
check_disk

# 写入当前资源使用百分比
echo "Current CPU Usage: $CPU_USAGE%" >> $ALERT_FILE
echo "Current Memory Usage: $MEMORY_USAGE%" >> $ALERT_FILE
echo "Current Disk Usage: $DISK_USAGE%" >> $ALERT_FILE

# 检查是否需要发送告警邮件
SEND_ALERT=false
if (( $(echo "$CPU_USAGE > $CPU_THRESHOLD" | bc -l) )); then
    SEND_ALERT=true
fi

if (( $(echo "$MEMORY_USAGE > $MEMORY_THRESHOLD" | bc -l) )); then
    SEND_ALERT=true
fi

if (( $(echo "$DISK_USAGE > $DISK_THRESHOLD" | bc -l) )); then
    SEND_ALERT=true
fi

# 如果需要发送告警邮件，则发送邮件
if [ "$SEND_ALERT" = true ]; then
    cat $ALERT_FILE | mail -s "$SUBJECT" $RECIPIENTS
fi

# 清理告警文件
rm -f $ALERT_FILE
