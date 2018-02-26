#!/bin/bash
############################################################################
#Author:        小刘子
#Function:      This script is used to restart the Hunan mahjong program.
#Version:       V1.0
#Date:          2017/12
############################################################################

# Shell Env
SHELL_NAME="mj_restart.sh"
SHELL_DIR="/home/zyts/project/mj"
LOCK_FILE="/tmp/${SHELL_NAME}.lock"
RUN_DIR_ROOT="/home/zyts/project/mj/run"
PID_FILE="server.pid"

#export PATH=/opt/app/msgpack140/lib:/opt/app/boost160/lib:/opt/app/curl749/lib:/opt/app/openssl/lib:$PATH
#bash

# Shell Lock
shell_lock(){
    touch $LOCK_FILE
}

shell_unlock(){
    rm -rf $LOCK_FILE
}

# shell usage
shell_usage(){
    echo -e "\e[1;31mUsage: $0 [ start | stop | restart ]\e[0m"
}


# 判断脚本是否在运行
if [ -f "$LOCK_FILE" ]
then
    echo "$SHELL_NAME is running" && exit
fi

# 如果没有在运行，则生成.lock文件
shell_lock

stop_process(){
    echo -e "\e[1;33mkill all process\e[0m"
    for PRO in zyloginGate  zygateServer  zyhallServer  zydbServer  zyplayerCenter Playerroom1 Playerroom2
    do
        cat ${RUN_DIR_ROOT}/${PRO}/${PID_FILE} | xargs kill -9 > /dev/null 2>&1
    done
}
# 重启各个模块
start_process(){
for PRO in zyplayerCenter zydbServer zyhallServer zygateServer zyloginGate  Playerroom1 Playerroom2
do
    echo -e "\e[1;35m restart $PRO \e[0m"
    PROCESS=$(cd ${RUN_DIR_ROOT}/${PRO} && ls zy* )
    cd ${RUN_DIR_ROOT}/${PRO} && ./${PROCESS} && sleep 2
    KEY=$(ps -ef | grep -v grep | grep $(cat ${RUN_DIR_ROOT}/${PRO}/${PID_FILE}))
    if [ -n "$KEY" ]
    then
        echo -e "\t restart $PRO successed."
    else
        echo -e "\t restart $PRO failed!" && shell_unlock && exit
  fi
done
}

main(){
    case $1 in
    start)
        start_process;
    ;;
    stop)
        stop_process;
    ;;
    restart)
        stop_process;
        start_process;
    ;;
    *)
        shell_usage;
     esac
}

main $1

shell_unlock
