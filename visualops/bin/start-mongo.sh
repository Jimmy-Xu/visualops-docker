#!/bin/bash
#usage

#for linux
#./start-mongo.sh

#for mac
#./start-mongo.sh mac

MRBOT_HOME=/visualops

run_with_default() {
	echo "start mongodb with default config"
	mongod
}

run_under_linux() {
	echo "run mongo under linux"
	chown -R root:root ${MRBOT_HOME}/log
	echo "start mongodb with ${MRBOT_HOME}/conf/mongodb.conf"
	echo "--------------------------------"
	cat ${MRBOT_HOME}/conf/mongodb.conf
	echo "--------------------------------"
	mkdir -p ${MRBOT_HOME}/db/mongodb
	if [ -f ${MRBOT_HOME}/db/mongodb/mongod.lock ];then
		echo "found old ${MRBOT_HOME}/db/mongodb/mongod.lock, remove it now"
		rm -rf ${MRBOT_HOME}/db/mongodb/mongod.lock
	fi
	if [ ! -d ${MRBOT_HOME}/db/mongodb ];then
		mkdir -p ${MRBOT_HOME}/db/mongodb
		echo "init database..."
	fi
	echo "start mongod service"
	mongod -f ${MRBOT_HOME}/conf/mongodb.conf
}

run_under_mac() {
	echo "run mongo under macosx"
	echo "start mongodb with ${MRBOT_HOME}/conf/mongodb-mac.conf"
	echo "--------------------------------"
	cat ${MRBOT_HOME}/conf/mongodb-mac.conf
	echo "--------------------------------"
	if [ -f /opt${MRBOT_HOME}/db/mongodb/mongod.lock ];then
		echo "found old /opt${MRBOT_HOME}/db/mongodb/mongod.lock, remove it now"
		rm -rf /opt${MRBOT_HOME}/db/mongodb/mongod.lock
	fi
	if [ ! -d /opt${MRBOT_HOME}/db/mongodb ];then
		mkdir -p /opt${MRBOT_HOME}/db/mongodb
		echo "init database..."
	fi
	echo "start mongod service"
	mongod -f ${MRBOT_HOME}/conf/mongodb-mac.conf
}


###########
# main
###########
if [[ -d ${MRBOT_HOME} ]]  && [[ -f ${MRBOT_HOME}/conf/mongodb.conf ]] && [[ $# -eq 0 ]];then
	run_under_linux
elif [[ -d ${MRBOT_HOME} ]]  && [[ -f ${MRBOT_HOME}/conf/mongodb-mac.conf ]] && [[ $# -eq 1 ]] && [[ $1 == "mac" ]] ;then
	run_under_mac
else
	run_with_default
fi


