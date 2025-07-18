#!/bin/bash

# 数据库连接信息
SOURCE_DB_USER="hdzhprod"
SOURCE_DB_HOST="172.16.241.6"
SOURCE_DB_PASS="He^7dnezhd293JD"
TARGET_DB_USER="hdzhprod"
TARGET_DB_HOST="172.16.241.2"
TARGET_DB_PASS="He^7dnezhd293JD"
BACKUP_DIR="/data/bzc/plugin/mysql/data"
DB_NAME="hdzhprod"

# 创建备份目录（如果不存在）
mkdir -p "$BACKUP_DIR"

# 获取当前日期，用于备份文件命名
CURRENT_DATE=$(date +"%Y%m%d")

# 备份数据库
BACKUP_FILE="$BACKUP_DIR/${DB_NAME}_${CURRENT_DATE}.sql"

echo "开始备份数据库 $DB_NAME 到 $BACKUP_FILE ..."
mysqldump -u"$SOURCE_DB_USER" -h"$SOURCE_DB_HOST" -p"$SOURCE_DB_PASS" "$DB_NAME" > "$BACKUP_FILE"

if [ $? -ne 0 ]; then
    echo "数据库备份失败！"
    exit 1
fi

echo "数据库备份成功！"

# 清理三天前的备份文件
find "$BACKUP_DIR" -type f -name "${DB_NAME}_*.sql" -mtime +3 -exec rm -f {} \;

echo "已删除三天前的备份文件。"

# 将备份导入到目标数据库
echo "开始将备份数据同步到目标数据库 $TARGET_DB_HOST ..."
mysql -u"$TARGET_DB_USER" -h"$TARGET_DB_HOST" -p"$TARGET_DB_PASS" "$DB_NAME" < "$BACKUP_FILE"

if [ $? -ne 0 ]; then
    echo "数据同步到目标数据库失败！"
    exit 1
fi

echo "数据同步到目标数据库成功！"
