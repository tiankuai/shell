#!/bin/bash
# 简单的tomcat自动化部署脚本 by.tiank.2017-10-17
# 
# 一、实现功能：
# 1、检查tomcat进程是否存在，如果存在则kill掉
# 2、备份现有war包到tomcat/backup目录
#   tar -cf ecssportal.war backup/
#   若目录中有以前的war包,则删掉
# 3、复制当前目录新war包到tomcat/webapps目录
#    使用unzip解析war包，删除war包。使用另一个脚本更换其中的ftl文件。
# 4、启动tomcat
# 5、显示tomcat日志
# 
# 二、注意：
#  1、使用时，需要先修改backup_path,tomcat_path路径
#  2、目录下同时存在autodeploy.sh和server.war
#  3、目录下同时存在新的communicateMonth.ftlx
# 三、执行命令
# ./autodeploy.sh  server 
# 例如 ./autodeploy.sh  ROOT
#
#规定变量，其中有一个ftl.sh是为了更改ROOT/WEB-INF/classes/template中的ftl文件所写
path=`pwd`
now=`date +%Y%m%d%H%M%S`
ftl_path=$path/ftl.sh
tomcat_path=$path/tomcat
backup_path=$path/backup
# 参数校验，校验此目录下是否存在server对应的war包
deploywar=$1
if [ -e "$deploywar.war" ]; then
  echo -e "\033[34m war archive: $deploywar.war \033[0m"
else 
  echo -e "\033[31m war archive '$deploywar.war' not exists \033[0m"
  exit -1
fi
#create backup dir，校验是否存在backup目录
if [ ! -d "$backup_path" ]; then
  mkdir "$backup_path"
fi
echo "tomcat home: $tomcat_path"
echo "backup path: $backup_path"
echo 'try to stop tomcat...'
#使用pid将tomcat关闭（注意过滤的命令书写）
pid=`ps aux|grep "java"|grep "$tomcat_path"|awk '{printf $2}'`
if [ -n $pid ]; then
  echo "tomcat pid: $pid";
  kill -9 $pid;
fi
echo 'stop tomcat finished...'
echo 'backup old archive...' 
#删除旧备份，将旧文件打包备份到backup目录中
tar -cvf $tomcat_path/webapps/$deploywar.tar $tomcat_path/webapps/$deploywar
if [ -f "$tomcat_path/webapps/$deploywar.tar" ]; then
  rm -rf $backup_path/ROOT*
  mv -v "$tomcat_path/webapps/$deploywar.tar" "$backup_path/$deploywar$now.tar";  
fi
#公司主机tomcat习惯会留有旧的war包，这次将其删除
if [ -f "$tomcat_path/webapps/$deploywar.war" ]; then
  rm -rf $tomcat_path/webapps/$deploywar.war;  
fi
#清空目录和work旧归档工作缓存
echo 'delete old archive...' 
rm -rf $tomcat_path/webapps/$deploywar 
echo 'delete old archive work cache...'
rm -rf $tomcat_path/work/Catalina/localhost/$deploywar/ 
echo "copy $deploywar.war archive to webapps.."
mkdir $tomcat_path/webapps/$deploywar
#复制并解析新的war包
cp -v "$deploywar.war" "$tomcat_path/webapps/$deploywar"
echo 'uzip file,delete file'   
cd $tomcat_path/webapps/$deploywar/
unzip $tomcat_path/webapps/$deploywar/$deploywar.war 
rm -rf $tomcat_path/webapps/$deploywar/$deploywar.war
#这是执行了替换ftl文件的sh脚本命令，组件式
#source $ftl_path
cd $path
./ftl.sh
echo -e "\033[32m"
echo 'startup tomcat...'
#sh $tomcat_path/bin/startup.sh
# 启动tomcat，上面的命令有bug需重启，使用下面的命令可以成功
cd $tomcat_path/bin
./startup.sh
sleep 3
#打开日志监控
tail -10f $tomcat_path/logs/catalina.out
