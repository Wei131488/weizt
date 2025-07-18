#!/bin/bash

# 数据库连接信息
DB_USER="zhongheprod"
DB_HOST="rm-e3vv1uo80e7h2h2l5.mysql.rds.ops.icloud.cnnc.cn"
DB_PORT="3306"
DB_PASS="Ndzh#053@jedMd"
SOURCE_DB="zhongheprod"
TARGET_DB="zhonghetest"
DUMP_FILE_STRUCTURE="/data/bzc/yunwei/mysql_bak/zhongheprod_structure.sql"
DUMP_FILE_DATA="/data/bzc/yunwei/mysql_bak/zhongheprod_data.sql"

# 导出 zhongheprod 数据库结构
echo "导出数据库 $SOURCE_DB 的表结构到 $DUMP_FILE_STRUCTURE ..."
mysqldump -u "$DB_USER" -h "$DB_HOST" -P "$DB_PORT" -p"$DB_PASS" --no-data --databases "$SOURCE_DB" --routines --triggers --events > "$DUMP_FILE_STRUCTURE"

if [ $? -ne 0 ]; then
    echo "导出数据库结构失败"
    exit 1
fi

# 导出 zhongheprod 数据库数据
echo "导出数据库 $SOURCE_DB 的数据到 $DUMP_FILE_DATA ..."
mysqldump -u "$DB_USER" -h "$DB_HOST" -P "$DB_PORT" -p"$DB_PASS" --no-create-info --databases "$SOURCE_DB" --single-transaction --quick --add-drop-table > "$DUMP_FILE_DATA"

if [ $? -ne 0 ]; then
    echo "导出数据库数据失败"
    exit 1
fi

# 删除 DEFINER 关键字
sed -i '/DEFINER/d' "$DUMP_FILE_STRUCTURE"
sed -i '/DEFINER/d' "$DUMP_FILE_DATA"
echo "已删除 DEFINER，准备同步到 $TARGET_DB ..."

# 清空 zhonghetest 数据库中的所有表数据
TABLES=$(mysql -u "$DB_USER" -h "$DB_HOST" -P "$DB_PORT" -p"$DB_PASS" -e "SHOW TABLES IN $TARGET_DB;" | awk '{ print \$1}' | grep -v '^Tables' )
for TABLE in $TABLES; do
    echo "清空表 $TABLE ..."
    mysql -u "$DB_USER" -h "$DB_HOST" -P "$DB_PORT" -p"$DB_PASS" -e "TRUNCATE TABLE $TARGET_DB.$TABLE;"
    if [ $? -ne 0 ]; then
        echo "清空表 $TABLE 失败"
        exit 1
    fi
done

# 导入结构到 zhonghetest 数据库
echo "导入表结构到数据库 $TARGET_DB ..."
mysql -u "$DB_USER" -h "$DB_HOST" -P "$DB_PORT" -p"$DB_PASS" "$TARGET_DB" < "$DUMP_FILE_STRUCTURE"

if [ $? -ne 0 ]; then
    echo "导入表结构失败"
    exit 1
fi

# 导入数据到 zhonghetest 数据库
echo "导入数据到数据库 $TARGET_DB ..."
mysql -u "$DB_USER" -h "$DB_HOST" -P "$DB_PORT" -p"$DB_PASS" "$TARGET_DB" < "$DUMP_FILE_DATA"

if [ $? -ne 0 ]; then
    echo "导入数据库数据失败"
    exit 1
fi

# 删除临时导出文件
echo "清理临时文件 $DUMP_FILE_STRUCTURE 和 $DUMP_FILE_DATA ..."
rm -f "$DUMP_FILE_STRUCTURE"
rm -f "$DUMP_FILE_DATA"

echo "数据库 $SOURCE_DB 的数据和结构成功同步到 $TARGET_DB"
