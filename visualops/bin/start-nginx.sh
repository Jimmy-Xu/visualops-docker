#!/bin/bash

MRBOT_HOME=/visualops
NGINX_DIR=${MRBOT_HOME}/conf/nginx
NGINX_CFG=$NGINX_DIR/nginx.conf
API_CFG=$NGINX_DIR/visualops/api.conf
WX_CFG=$NGINX_DIR/visualops/wxbot.jiecao.pw.conf

env

if [[ -d ${MRBOT_HOME} ]] && [[ -f ${API_CFG}.template ]] && [[ -f ${WX_CFG}.template ]] ;then

	cp ${API_CFG}.template ${API_CFG}
	echo "modify ip for AppService in ${API_CFG}"
	sed -i "s/127.0.0.1:/"${APPSERVICE_PORT_8700_TCP_ADDR}":/g" ${API_CFG}
	grep ${APPSERVICE_PORT_8700_TCP_ADDR}":" ${API_CFG}
	echo "---------------------------------------------------------------------"

	cp ${WX_CFG}.template ${WX_CFG}
	echo "modify ip for WeChat in ${WX_CFG}"
	sed -i "s/127.0.0.1:/"${WXBOT_PORT_7865_TCP_ADDR}":/g" ${WX_CFG}
	grep ${WXBOT_PORT_7865_TCP_ADDR}":" ${WX_CFG}
	echo "---------------------------------------------------------------------"

	#test conf
	echo "test ${NGINX_CFG}"
	nginx -t -c ${NGINX_CFG}

	#start service
	echo "start nginx with ${NGINX_CFG}"
	nginx -c ${NGINX_CFG}

else
	echo "${MRBOT_HOME} or ${API_CFG}.template or ${WX_CFG}.template not found, start nginx service with default config"
	nginx
fi


