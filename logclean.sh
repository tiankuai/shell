#!/bin/bash
# cleaning the tomcat logs and  bak
# Created by tiank on 2018/06/05.
set -e
#定义常量：日期、tomcat启动个数、日志备份路径和备份日志
Date=`date +%Y%m%d%H%M%S`
TomcatNum=`ps -ef |grep java|grep tomcat |grep -v grep|wc -l`
LogBakPath=/root/logbak
LogBakLog=$LogBakPath/logbak.log
#create backup dir，校验是否存在日志backup目录
if [ ! -d "$LogBakPath" ]; then
    mkdir -p "$LogBakPath"
fi
#定义日志备份函数
function baking()
{
    #截取日志的绝对路径和项目名称
    LogPath=`echo $1|awk -F /catalina.out '{print $1}'`
    PathItem=`echo $1 |awk -F / '{print $3}'`
    #压缩备份日志并用日期做记录
    tar --warning=no-file-changed -zcvPf $LogPath/catalina.tar.gz  $LogPath/catalina.out && echo "----${PathItem}-bakingtime-${Date}----" >> ${LogBakLog}
    mv -v "$LogPath/catalina.tar.gz" "$LogBakPath/$PathItem$Date.tar.gz" && echo "----${PathItem}-bakEnd----" >> ${LogBakLog}
}
#定义日志清理函数
function cleaning()
{
    #截取日志的绝对路经
    LogPath=`echo $1|awk -F catalina.out '{print $1}'`
	PathItem=`echo $1 |awk -F / '{print $3}'`
    #清理除了主日志的其他超出五天的日志文件
    find $LogPath -mtime +5 -name "*201?*" -exec rm -rf {} \; && echo "----${PathItem}--cleaningtime--${Date}----" >> ${LogBakLog}
    #使用echo清空catalina.out主日志
    echo ' ' > $1 && echo "----${PathItem}-cleanEnd----" >> ${LogBakLog}
}
#判断tomcat是否存在
if [ "$TomcatNum" = 0 ];
then
    exit
fi
    #找到所有含有catalina.out的路径遍历备份和清理函数
    for _curvar in `find / -name catalina.out`;do
        sleep 1
        baking ${_curvar} && cleaning ${_curvar}
        sleep 1
    done

