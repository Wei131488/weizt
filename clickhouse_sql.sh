#!/bin/bash
# 定义计数器以显示进度
counter=1

# 获取待处理的文件总数/root/test/clickhouse_sql/目录根据实际来做导入
total_files=$(ls /root/test/clickhouse_sql/*.sql | wc -l)

for file in /root/test/clickhouse_sql/*.sql
do
  echo "[$counter/$total_files] Importing SQL from $file ..."
  clickhouse-client -h 10.218.134.109 --user solarmonitor --password 'bzc@2022*qwe123' -d solarmonitor < "$file" > /dev/null 2>&1
  counter=$((counter + 1))
done
