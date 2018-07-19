#!/bin/bash
# bak sql and to hill
#功能说明：本功能用于备份数据库
# Created by tiank on 2018/06/07.
set -e
#PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:/usr/local/mysql/bin
#export PATH
#数据库地址
dbip='rm-m5e286yn'
#数据库用户名
dbuser='haitong'
#数据库密码
dbpasswd='haitong'
#数据库名,可以定义多个数据库，中间以空格隔开，如：test test1 test2
dbname='_ht'
#DAYS=15代表删除15天前的备份，即只保留近15天的备份
DAYS=7
#备份时间
backtime=`date +%Y%m%d%H%M%S`
#日志备份路径
logpath='/home/tiank/mysqlbackup/myqlbak.log'
#数据备份路径
datapath='/home/tiank/mysqlbackup'
#create backup dir，校验是否存在backup目录
if [ ! -d "$datapath" ]; then
    mkdir -p "$datapath"
fi
if [ ! -d "$logpath" ]; then
    touch "$logpath"
fi
#日志记录头部
echo ‘”备份时间为${backtime},备份数据库表 ${dbname} 开始” >> ${logpath}
#正式备份数据库
for table in $dbname; do
source=`mysqldump -h${dbip} -u${dbuser} -p${dbpasswd} ${table} | gzip > ${datapath}/${table}${backtime}.sql.gz`
#删掉之前的
delete=`find ${datapath} -mtime +${DAYS} -name "*.gz" -exec rm -rf {} \;` 
#备份成功以下操作
if [ "$?" == 0 ];then
#cd $datapath
#为节约硬盘空间，将数据库压缩
#tar jcf ${table}${backtime}.tar.bz2 ${backtime}.sql > /dev/null
#删除原始文件，只留压缩后文件
#rm -f ${datapath}/${backtime}.sql
echo “数据库表 ${table} 备份成功!!” >> ${logpath}
else
#备份失败则进行以下操作
echo “数据库表 ${table} 备份失败!!” >> ${logpath}
fi
done

