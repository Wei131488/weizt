#!/bin/bash

# 设置日志目录
BASE_DIR="/data/bzc/yunwei/atopcpu"
DATE_DIR=$(date +'%Y_%m_%d')
TIMESTAMP=$(date +'%Y%m%d_%H%M%S')
OUTPUT_FILE="$BASE_DIR/$DATE_DIR/output_$TIMESTAMP.txt"
SERVER_IO_FILE="$BASE_DIR/$DATE_DIR/server_io_$TIMESTAMP.log"

# 创建日志目录（如果不存在）
mkdir -p "$BASE_DIR/$DATE_DIR"

# 执行 atop 命令并写入二进制日志文件
atop -w "$OUTPUT_FILE" 10 3

# 清空 server_io 日志文件
> "$SERVER_IO_FILE"

# 检查 atop 日志文件是否生成成功
if [[ ! -f "$OUTPUT_FILE" ]]; then
    echo "Error: atop log file $OUTPUT_FILE not found!"
    exit 1
fi

# 解析 atop 二进制日志文件，提取所需信息并生成 server_io 日志文件
atop -r "$OUTPUT_FILE" 2>/dev/null | while read -r line; do
    # 解析读取的行，获取 PID 和 CMD
    pid=$(echo "$line" | awk '{print $1}')  # PID 假设是第一列
    cmd=$(echo "$line" | awk '{for(i=2;i<=NF;i++) printf $i " "; print ""}')  # CMD 假设是第二列到最后

    # 过滤 CMD 中包含 "java" 的进程
    if [[ "$cmd" == *"java"* ]]; then
        # 提取进程详细信息
        process_info=$(ps -p "$pid" -o pid,ppid,%cpu,%mem,cmd --no-headers 2>/dev/null)

        # 检查是否已经存在于 server_io 日志文件中
        if ! grep -Fxq "$process_info" "$SERVER_IO_FILE"; then
            # 如果不存在，追加写入 server_io 日志文件
            echo "$process_info" >> "$SERVER_IO_FILE"
        fi
    fi
done

echo "Filtered server IO logs have been generated at $SERVER_IO_FILE"

# 清理三天前的日志目录并将其压缩
find "$BASE_DIR" -type d -name '20*_*' -mtime +3 -exec zip -r '{}.zip' '{}' \; -exec rm -rf '{}' \;

# 删除一个月前的压缩包
find "$BASE_DIR" -type f -name '*.zip' -mtime +30 -exec rm -f '{}' \;

echo "Log has been generated at $OUTPUT_FILE and $SERVER_IO_FILE"

