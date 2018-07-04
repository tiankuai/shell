#!/bin/bash
# bak sql and to hill
#功能说明：本功能用于备份mongodb
# Created by tiank on 2018/06/08.
set -e
#PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:/usr/local/mysql/bin
#export PATH
#数据库地址
dbpath='/usr/local/mongodb/bin/'
dbip='118.190.117'
#数据库用户名
dbuser='cas'
#数据库密码
dbpasswd='cas@admin'
#数据库名,可以定义多个数据库，中间以空格隔开，如：test test1 test2
dbname='dudu_cas'
#备份时间
backtime=`date +%Y%m%d%H%M%S`
#日志备份路径
logpath='/home/tiank/mongobak'
#数据备份路径
datapath='/home/tiank/mongobak'
#日志记录头部
echo ‘”备份时间为${backtime},备份数据库表 ${dbname} 开始” >> ${logpath}/mongobak.log
#正式备份数据库
for table in $dbname; do
#cd ${dbpath}
#source=`mysqldump -h${dbip} -u${dbuser} -p${dbpasswd} ${table} | gzip > ${datapath}/${dbname}${backtime}.sql.gz`
source=`/usr/local/mongodb/bin/mongodump -h ${dbip} -d ${table} --out ${datapath} -u ${dbuser} -p ${dbpasswd}`
#/usr/local/mongodb/bin/mongodump -d ${table} -o ${datapath} -u ${dbuser} -p ${dbpasswd} && echo $?
#删掉之前的
delete=`find ${datapath} -mtime +30 -name "*.gz" -exec rm -rf {} \;` 
#备份成功以下操作
if [ "$?" == 0 ];then
cd $datapath
#为节约硬盘空间，将数据库压缩
tar -zcvf ${table}${backtime}.tar.gz ${table} > /dev/null
#删除原始文件，只留压缩后文件
rm  -rf  ${datapath}/${table}
echo “数据库表 ${dbname} 备份成功!!” >> ${logpath}/mongobak.log
else
#备份失败则进行以下操作
echo “数据库表 ${dbname} 备份失败!!” >> ${logpath}/mongobak.log
fi
done

