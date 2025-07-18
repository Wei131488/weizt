#!/bin/bash

# 定义变量
ZIP_FILE="nw_test.zip"
UPLOAD_DIR="/data/bzc/backup_jar"
EXTRACT_DIR="$UPLOAD_DIR/extracted"
BACKUP_DIR="$UPLOAD_DIR/backup"
REMOTE_HOSTS=("192.168.1.22" "192.168.1.23" "192.168.1.24")  # 添加多台主机的IP地址
REMOTE_DIR="/data/bzc/backup_jar"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

# 1. 上传 nw_test.zip 到所有远程主机
for REMOTE_HOST in "${REMOTE_HOSTS[@]}"; do
    echo "将 $ZIP_FILE 发送到 $REMOTE_HOST:$REMOTE_DIR ..."
    scp "$UPLOAD_DIR/$ZIP_FILE" "$REMOTE_HOST:$REMOTE_DIR" || { echo "$REMOTE_HOST 文件发送失败"; exit 1; }
done

# 2. 解压缩 ZIP 文件
echo "解压缩 $ZIP_FILE..."
unzip -o "$UPLOAD_DIR/$ZIP_FILE" -d "$EXTRACT_DIR" || { echo "解压失败"; exit 1; }

# 3. 将解压后的文件复制到目标目录
echo "复制解压后的文件到 $UPLOAD_DIR..."
cp -r "$EXTRACT_DIR/"* "$UPLOAD_DIR/" || { echo "复制失败"; exit 1; }

# 4. 执行指定的脚本
SCRIPTS=("baibase_jar.sh" "baif_jar.sh" "bailiang_jar.sh" "baiplf_jar.sh" "baisaas_jar.sh" "baiying_jar.sh")

for SCRIPT in "${SCRIPTS[@]}"; do
    SCRIPT_PATH="$UPLOAD_DIR/$SCRIPT"
    
    if [[ -f "$SCRIPT_PATH" ]]; then
        echo "执行 $SCRIPT..."
        bash "$SCRIPT_PATH"
    else
        echo "$SCRIPT 不存在，跳过执行."
    fi
    
    sleep 5
done

# 5. 重命名并移动 nw_test.zip 到 backup 目录
NEW_ZIP_NAME="${ZIP_FILE%.zip}_$TIMESTAMP.zip"
echo "移动 $ZIP_FILE 到 $BACKUP_DIR/$NEW_ZIP_NAME..."
mv "$UPLOAD_DIR/$ZIP_FILE" "$BACKUP_DIR/$NEW_ZIP_NAME" || { echo "移动失败"; exit 1; }

echo "操作完成"
