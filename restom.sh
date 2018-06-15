#!/bin/bash
#restart zheshangzhengquan yingyongfuwuqi tomcat yingyong create by tiank 18-06-15
TomcatNum=`ps -ef |grep java|grep tomcat |grep -v grep|wc -l`

if [ "$TomcatNum" = 0 ];
then
    echo 'NO HAVE TOMCAT' && exit
else
    echo "HAVE-${TomcatNum}-TOMCAT"
fi
ps aux | grep "java" | grep "zs_pro" | awk  '{printf $2}'  | xargs  kill  -9 > /dev/null && echo 'stop dudao'
sleep 1
ps aux | grep "java" | grep "wx_tomcat " | awk  '{printf $2}'  | xargs  kill  -9 > /dev/null && echo 'stop wexin'
sleep 1
/bin/bash  /home/zs_pro/tomcat/bin/startup.sh > /dev/null && echo 'start dudao'
sleep 2
/bin/bash  /home/wx_tomcat/bin/startup.sh > /dev/null && echo 'start wexin'