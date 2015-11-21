#!/bin/bash

MRBOT_HOME=/visualops
if [[ -d ${MRBOT_HOME} ]]  && [[ -f ${MRBOT_HOME}/conf/redis.conf ]];then
	if [ ! -f ${MRBOT_HOME}/log/redis.log ];then
		echo "${MRBOT_HOME}/log/redis.log is missing, create it now..."
		touch ${MRBOT_HOME}/log/redis.log
	fi
	echo "start redis-server with ${MRBOT_HOME}/conf/redis.conf"
	redis-server ${MRBOT_HOME}/conf/redis.conf
else
	echo "${MRBOT_HOME}/conf/redis.conf not found, start redis-server with default config"
	redis-server
fi

