#!/bin/bash

# 定义旧路径和新路径前缀
OLD_PREFIX="/mnt/installsoft/clickhouse/store"
NEW_PREFIX="/mnt/bzc/plugin/clickhouse/store"

# 查找所有指向旧路径的符号链接
find /mnt/bzc/plugin/clickhouse/data/solartest -type l | while read -r symlink; do
 TARGET=$(readlink "$symlink")
        
        # 检查目标是否具有旧路径前缀
if [[ "$TARGET" == $OLD_PREFIX* ]]; then
           # 构建新的目标路径
           NEW_TARGET="${TARGET/$OLD_PREFIX/$NEW_PREFIX}"
          
          # 更新符号链接
          ln -sf "$NEW_TARGET" "$symlink"
          echo "Updated: $symlink -> $NEW_TARGET"
       fi
done
