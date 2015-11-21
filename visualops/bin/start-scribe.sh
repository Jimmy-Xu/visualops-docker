#!/bin/bash

MRBOT_HOME=/visualops
if [[ -d ${MRBOT_HOME} ]]  && [[ -f ${MRBOT_HOME}/conf/scribe.conf ]];then
	if [ ! -d ${MRBOT_HOME}/log/scribe ];then
		echo "${MRBOT_HOME}/log/scribe/ is missing, create it now..."
		mkdir -p ${MRBOT_HOME}/log/scribe
	fi
	echo "start scribed with ${MRBOT_HOME}/conf/scribe.conf"
	scribed ${MRBOT_HOME}/conf/scribe.conf
else
	echo "${MRBOT_HOME}/conf/scribe.conf not found, start scribe with default config"
	scribed
fi

