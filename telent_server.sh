#!/bin/bash

# 定义监控的服务及其端口
declare -A services=(
    ["10021"]="epcsaas-setting-center-V.2.0.jar"
    ["10030"]="epcdata-center-V.2.0.jar"
    ["10035"]="epcsaas-base-center-V.2.0.jar"
    ["10041"]="epcsaas-financial-center-V.2.0.jar"
    ["10043"]="baiplf-bank-center-V.2.0.jar"
    ["10058"]="event-route-center-V.2.0.jar"
    ["10059"]="epcinp-inputpiece-center-V.2.0.jar"
    ["10071"]="epcplant-center-V.2.0.jar"
    ["10072"]="contract-center-V.2.0.jar"
    ["10073"]="baiplf-contract-center-V.2.0.jar"
    ["10078"]="station-center-V.2.0.jar"
    ["10081"]="businessmodel-center-V.2.0.jar"
    ["10082"]="epcsaas-operationplant-center-V.2.0.jar"
    ["6603"]="baiplf-contract-center-V.2.0.jar"
    ["6605"]="baiplf-base-center-V.2.0.jar"
    ["6606"]="baiplf-bank-center-V.2.0.jar"
    ["6701"]="baisaas-gateway-V.2.0.jar"
    ["6702"]="baisaas-uaa-V.2.0.jar"
    ["6703"]="baisaas-base-center-V.2.0.jar"
    ["6705"]="baisaas-license-center-V.2.0.jar"
    ["6712"]="baisolar-opms-center-V.2.0.jar"
    ["6713"]="baisolar-saasauthn-center-V.2.0.jar"
    ["6803"]="epcinp-base-center-V.2.0.jar"
    ["6804"]="epcinp-inputpiece-center-V.2.0.jar"
    ["6805"]="baisolar-inputpiece-center-V.2.0.jar"
    ["8658"]="event-route-center-V.2.0.jar"
    ["9602"]="epcsaas-baie-uaa-V.2.0.jar"
    ["9603"]="epcsaas-base-center-V.2.0.jar"
    ["9604"]="epcsaas-report-center-V.2.0.jar"
    ["9606"]="epcsaas-xxljob-admin-V.2.0.jar"
    ["9607"]="epcsaas-setting-center-V.2.0.jar"
    ["9609"]="station-center-V.2.0.jar"
    ["9610"]="businessmodel-center-V.2.0.jar"
    ["9612"]="contract-center-V.2.0.jar"
    ["9640"]="epcsaas-financial-center-V.2.0.jar"
    ["9670"]="epcdata-center-V.2.0.jar"
    ["9712"]="epcsaas-operationplant-center-V.2.0.jar"
    ["9713"]="agentplant-center-V.2.0.jar"
    ["9735"]="epcplant-center-V.2.0.jar"
)

# 邮件接收者配置
declare -a email_recipients=(
    "weizhenting@chinabzc.com"
)

# 状态文件
status_file="service_status.log"

# 邮件发送函数
send_alert() {
    local services_info="$1"
    local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    local recipients=$(IFS=,; echo "${email_recipients[*]}")
    
    echo -e "生产南网SaaS告警主机192.168.1.11通知：\n\n$services_info\n发送时间: $timestamp\n\n请及时检查服务状态。" | mailx -s "服务告警: 一些服务状态已变化" $recipients
}

# 检查每个服务
check_service() {
    local port=$1
    local service_name=$2
    local ip_address="192.168.1.11"
    local alert_message=""
    local status_updated=false

    # 检查服务是否可用
    (echo > /dev/tcp/$ip_address/$port) &>/dev/null
    if [ $? -ne 0 ]; then
        # 如果连接失败，记录下服务状态
        if ! grep -q "$port:DOWN" "$status_file"; then
            echo "$port:DOWN" >> "$status_file"
            alert_message+="服务 $service_name 在端口 $port 已停止\n"
            status_updated=true
        fi
    else
        # 如果连接成功，检查之前是否报警过
        if grep -q "$port:DOWN" "$status_file"; then
            sed -i "/$port:DOWN/d" "$status_file"  # 移除 DOWN 状态
            echo "$port:UP" >> "$status_file"
            alert_message+="服务 $service_name 在端口 $port 已恢复\n"
            status_updated=true
        else
            if ! grep -q "$port:UP" "$status_file"; then
                echo "$port:UP" >> "$status_file"
            fi
        fi
    fi

    # 如果有状态更新，发送邮件
    if [ "$status_updated" = true ]; then
        send_alert "$alert_message"
    fi
}

# 创建状态文件（如果不存在）
touch "$status_file"

# 检查所有服务
for port in "${!services[@]}"; do
    check_service "$port" "${services[$port]}"
done
