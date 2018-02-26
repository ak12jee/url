#!/bin/bash
############################################################################
#Author:        小刘子
#Function:      This script is used to restart the Hunan mahjong program.
#Version:       V1.0
#Date:          2017/12
############################################################################

# Shell Env
SHELL_NAME="qqhemj_update.sh"
SHELL_DIR="/home/zyts/project/mj"
LOCK_FILE="/tmp/${SHELL_NAME}.lock"
PROJECT="$1"
VERSION="$2"
PACKAGE="${PROJECT}-${VERSION}.tar.gz"
RUN_DIR_ROOT="/home/zyts/project/mj/run"
PACK_DIR="/home/zyts/project/mj/source/bin"
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
    echo -e "\e[1;31mUsage: $0 [ FRAME | qqhemj | PAODEKUAI | DOUNIU | PAOHUZI [version] ] \e[0m"
    echo "例如： $0 qqhemj 201706291020"
}

# 判断脚本是否在运行
if [ -f "$LOCK_FILE" ]
then
    echo "$SHELL_NAME is running" && exit
fi

# 如果没有在运行，则生成.lock文件
shell_lock


# 更新主框架
update_frame(){
    for PRO in zyplayerCenter zydbServer zyhallServer zygateServer  zyloginGate
    do
        echo -e "\e[1;35mKill process $PRO\e[0m"
        cat ${RUN_DIR_ROOT}/${PRO}/${PID_FILE} | xargs kill -9 > /dev/null 2>&1
    done
    for PRO in zyplayerCenter zydbServer zyhallServer zygateServer  zyloginGate
    do
        echo -e "\e[1;35mUpdating $PRO \e[0m"        
        rm -rf $RUN_DIR_ROOT/$PRO/zy*
        cp -a ${PACK_DIR}/${PRO} ${RUN_DIR_ROOT}/${PRO}/
        cd ${RUN_DIR_ROOT}/${PRO} && ./${PRO} && sleep 5
        KEY=$(ps -ef | grep -v grep | grep $(cat ${RUN_DIR_ROOT}/${PRO}/${PID_FILE}))
        if [ -n "$KEY" ]
        then
            echo -e "\t updating $PRO successed."
        else
            echo -e "\t updating $PRO failed!" && shell_unlock && exit
        fi
done
}

# 定义更新RoomServer的通用函数
update_rs(){
    a=$1
    echo -e "\e[1;35mUpdating Playerroom${a} \e[0m"
    cat ${RUN_DIR_ROOT}/Playerroom${a}/${PID_FILE} | xargs kill -9 > /dev/null 2>&1
    rm -rf ${RUN_DIR_ROOT}/Playerroom${a}/zy*
    cp -a ${PACK_DIR}/zyroomServer ${RUN_DIR_ROOT}/Playerroom${a}/
    cd ${RUN_DIR_ROOT}/Playerroom${a} && ./zyroomServer && sleep 5
    KEY=$(ps -ef | grep -v grep | grep $(cat ${RUN_DIR_ROOT}/Playerroom${a}/${PID_FILE}))
    if [ -n "$KEY" ]
    then
        echo -e "\t updating Playerroom${a} successed."
    else
        echo -e "\t updating Playerroom${a} failed!"
    fi

}

# 更新湖南麻将RoomServer
update_qqhemj(){
    for ((i=1;i<=2;i++))
    do
        update_rs $i
    done
}

# 更新湖南跑得快RoomServer
update_paodekuai(){
    for i in 5 6 7 10
    do
        update_rs $i
    done
}

# 更新湖南斗牛RoomServer
update_douniu(){
    for ((i=8;i<=9;i++))
    do
        update_rs $i
    done
}

# 更新湖南跑胡子RoomServer
update_paohuzi(){
    for ((i=11;i<=12;i++))
    do
        update_rs $i
    done
}

main(){
    case $1 in
    FRAME)
        update_frame;
    ;;
    qqhemj)
        update_qqhemj;
    ;;
    PAODEKUAI)
        update_paodekuai;
    ;;
    DOUNIU)
        update_douniu;
    ;;
    PAOHUZI)
        update_paohuzi;
    ;;
    *)
        shell_usage;
  esac
}

main $1

shell_unlock
