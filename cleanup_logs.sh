#!/bin/bash

#  定义要清理日志的目录数组
log_dirs=("/data/log1"  "/data/log2")

#  遍历目录数组
for  dir  in  "${log_dirs[@]}";  do
      #  检查目录是否存在
      if  [  -d  "$dir"  ];  then
          #  找到目录下所有.log文件并删除7天前的日志
          find  "$dir"  -name  '*.log'  -type  f  -mtime  +7  -exec  rm  -f  {}  \;
      else
          echo  "Directory  $dir  does  not  exist."
      fi
done

echo  "Log  cleanup  completed."