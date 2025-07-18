#!/bin/bash

source /etc/profile

# 设置日期和时间
day=$(date "+%Y%m%d")
daytime=$(date "+%Y%m%d-%H:%M")

# 定义输出文件目录和文件名
free_dir=/data/bzc/yunwei/topcpu/
file_name=${free_dir}toplog_${day}.txt

# 确保输出目录存在
if [ ! -d "${free_dir}" ]; then
    mkdir -p ${free_dir}
fi

# 获取 top 命令的输出
top_output=$(top -b -n 1)

# 提取 top 面板的头部信息（通常为前7行）
top_header=$(echo "$top_output" | head -n 7)

# 提取 CPU 使用最高的前15行
top_cpu=$(echo "$top_output" | sed -n '8,$p' | sort -nrk 9 | head -n 15)

# 提取内存使用最高的前15行
top_mem=$(echo "$top_output" | sed -n '8,$p' | sort -nrk 10 | head -n 15)

# 使用 free 命令提取内存使用信息
mem_info=$(free -m | grep Mem)
total=$(echo "$mem_info" | awk '{print $2}')
used=$(echo "$mem_info" | awk '{print $3}')
free=$(echo "$mem_info" | awk '{print $4}')
buffers=$(echo "$mem_info" | awk '{print $6}')

# 提取并解析 CPU 使用信息
cpu_info=$(echo "$top_output" | grep "%Cpu(s)")
user_cpu=$(echo "$cpu_info" | awk '{print $2}')
system_cpu=$(echo "$cpu_info" | awk '{print $4}')
idle_cpu=$(echo "$cpu_info" | awk '{print $8}')

# 计算内存相关的百分比
used_percent=$(awk "BEGIN {printf \"%.2f\", ($used/$total)*100}")
free_percent=$(awk "BEGIN {printf \"%.2f\", ($free/$total)*100}")
buffers_percent=$(awk "BEGIN {printf \"%.2f\", ($buffers/$total)*100}")

# 调试输出
echo "Debug: Mem Info: Total=$total, Used=$used (${used_percent}%), Free=$free (${free_percent}%), Buffers=$buffers (${buffers_percent}%)"
echo "Debug: CPU Info: User CPU=$user_cpu, System CPU=$system_cpu, Idle CPU=$idle_cpu"

# 确保成功提取了数值
if [[ -z "$total" || -z "$used" || -z "$free" || -z "$buffers" || -z "$user_cpu" || -z "$system_cpu" || -z "$idle_cpu" ]]; then
    echo "Error: Unable to extract information from top output."
    exit 1
fi

# 输出到文件
{
    echo "$top_header"
    echo "CPU使用最高的前15个进程："
    echo "$top_cpu"
    echo ""
    echo "内存使用最高的前15个进程："
    echo "$top_mem"
    echo ""
    echo "Mem:  ${used_percent}% used, ${free_percent}% free, ${buffers_percent}% buffers"
    echo "CPU:  ${user_cpu}% user, ${system_cpu}% system, ${idle_cpu}% idle"
    echo "$daytime CPU监控结束！"
    echo ""
} >> ${file_name}

# 检查内存使用是否超过80%
used_scaled=$((used * 10))
total_scaled=$((total * 8))

if (( used_scaled >= total_scaled )); then
    echo "$daytime 内存使用超过80%，进行进程详细输出" >> ${file_name}

    # 提取 CPU 使用最高的前15个进程的 PID
    cpu_pids=$(echo "$top_cpu" | awk '{print $1}')
    # 提取内存使用最高的前15个进程的 PID
    mem_pids=$(echo "$top_mem" | awk '{print $1}')

    # 合并两个 PID 列表并去重
    all_pids=$(echo -e "$cpu_pids\n$mem_pids" | sort -u)

    for pid in $all_pids; do
        if [[ $pid =~ ^[0-9]+$ ]]; then
            ps_ef_output=$(ps -ef | awk -v pid="$pid" '$2 == pid')
            if [[ -n "$ps_ef_output" ]]; then
                echo "PID: $pid" >> ${file_name}
                echo "$ps_ef_output" >> ${file_name}
                echo "" >> ${file_name}
            else
                echo "Warning: No process found for PID: $pid" >> ${file_name}
            fi
        fi
    done

    echo "$daytime 内存使用超过80%-内存监控结束" >> ${file_name}
fi

echo "$daytime 本次监控结束" >> ${file_name}

# 清理7天前的旧文件
find ${free_dir} -name 'toplog_*.txt' -type f -mtime +7 -exec rm -f {} \;

