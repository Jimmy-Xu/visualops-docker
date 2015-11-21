#!/bin/bash

show_usage(){
	cat <<COMMENT
  ./start-appservice.sh help
  ./start-appservice.sh init
  ./start-appservice.sh init-and-sleep
  ./start-appservice.sh init-and-run
COMMENT
}

show_help(){
	cat <<COMMENT

  To enter mrbot-appservice, run the following command in another shell
  $ docker exec -it mrbot-appservice bash

===========================================================================================
  You can manually start AppService service in the container

  #1)as front:
    /visualops/source/api/Source/Forge/AppService/AppService.py -f -p 8700

  #2)as backend:
    /visualops/source/api/Source/Forge/AppService/AppService.py -p 8700 &
    tail -f /visualops/log/scribe/aps-Gearman.AppService/aps-Gearman.AppService_current

  /*AppService source is under visualops/source/api
  AppService log is under visualops/log/scribe/aps-Gearman.AppService*/

===========================================================================================

COMMENT
}


fn_init(){
	#######################################################################################
	MRBOT_HOME=/visualops
	MODE=$1
	if [[ -d ${MRBOT_HOME} ]] && [[ -f ${MRBOT_HOME}/conf/instant.cfg.template ]] ;then

		cp ${MRBOT_HOME}/conf/instant.cfg.template ${MRBOT_HOME}/conf/instant.cfg

		#config redis
		echo "---------------------------------------------------------------------"
		echo "modify redis parameter in ${MRBOT_HOME}/conf/instant.cfg"
		sed -i "s/redis_host:.*$/redis_host: "${REDIS_PORT_8285_TCP_ADDR}"/g" ${MRBOT_HOME}/conf/instant.cfg
		sed -i "s/redis_port:.*$/redis_port: "${REDIS_PORT_8285_TCP_PORT}"/g" ${MRBOT_HOME}/conf/instant.cfg
		grep "redis_" ${MRBOT_HOME}/conf/instant.cfg

		#config scribe
	       	echo "---------------------------------------------------------------------" 
		echo "modify scribe parameter in ${MRBOT_HOME}/conf/instant.cfg"
	        sed -i "s/scribe_host:.*$/scribe_host: "${SCRIBE_PORT_1463_TCP_ADDR}"/g" ${MRBOT_HOME}/conf/instant.cfg
	        sed -i "s/scribe_port:.*$/scribe_port: "${SCRIBE_PORT_1463_TCP_PORT}"/g" ${MRBOT_HOME}/conf/instant.cfg
	        grep "scribe_" ${MRBOT_HOME}/conf/instant.cfg

		#config mongo
		echo "---------------------------------------------------------------------"
		echo "modify mongo parameter in ${MRBOT_HOME}/conf/instant.cfg"
		sed -i "s/mongodb_host:.*$/mongodb_host: "${MONGO_PORT_8290_TCP_ADDR}"/g" ${MRBOT_HOME}/conf/instant.cfg
		sed -i "s/mongodb_port:.*$/mongodb_port: "${MONGO_PORT_8290_TCP_PORT}"/g" ${MRBOT_HOME}/conf/instant.cfg
		grep "mongodb_" ${MRBOT_HOME}/conf/instant.cfg

		#test redis
		echo "---------------------------------------------------------------------"
		echo "test connect redis '$REDIS_PORT_8285_TCP_ADDR:$REDIS_PORT_8285_TCP_PORT' "
		redis-cli -h "$REDIS_PORT_8285_TCP_ADDR" -p "$REDIS_PORT_8285_TCP_PORT" ping
		if [ $? -ne 0 ];then
			echo "redis not ready, exit!"
			exit 1
		fi

		#test scribe
		echo "---------------------------------------------------------------------"
	        echo "test connect scribe '$SCRIBE_PORT_1463_TCP_ADDR:$SCRIBE_PORT_1463_TCP_PORT' "
	        echo `date` hello world | scribe_cat -h $SCRIBE_PORT_1463_TCP_ADDR:$SCRIBE_PORT_1463_TCP_PORT test
		if [ $? -ne 0 ];then
			echo "scribe not ready, exit!"
			exit 1
		fi
		tail -n 10 /visualops/log/scribe/test/test_current

		#test mongo
		echo "wait for mongo start"
		RETRY=1
		RETRY_MAX=10
		SLEEP_TIME=6
		while [ $RETRY -le ${RETRY_MAX} ]
		do
			echo "---------------------------------------------------------------------"
			echo "RETRY: $RETRY"
			echo "test connect mongodb '$MONGO_PORT_8290_TCP_ADDR:$MONGO_PORT_8290_TCP_PORT/test'"
			mongo $MONGO_PORT_8290_TCP_ADDR:$MONGO_PORT_8290_TCP_PORT/test -eval "printjson(db.stats())"
			if [ $? -ne 0 ];then
				if [ $RETRY -eq ${RETRY_MAX} ];then
					echo "connect mongodb failed(timeout)"
					exit 1
				else
					echo "mongodb not ready, wait ${SLEEP_TIME}s to retry!"
				fi
			else
				echo "connect mongodb succeed!"
				break
			fi
			sleep ${SLEEP_TIME}
			RETRY=$((RETRY+1))
		done
	    echo "---------------------------------------------------------------------"
		chown root:root ${MRBOT_HOME}/log/scribe -R

		echo "start scribe"
		scribed ${MRBOT_HOME}/conf/scribe.conf &
		sleep 5
		pgrep scribed
		if [ $? -ne 0 ];then
			echo "scribe not start, exit"
			exit 1
		else
			echo "scribe start succeed!"
			echo
		fi

		echo "---------------------------------------------------------------------"
		echo "set env for AppService"
		echo "---------------------------------------------------------------------"
		export PYTHON_EGG_CACHE=${MRBOT_HOME}/.python-eggs
		export PYTHONPATH=${MRBOT_HOME}/source/api/Source
		export INSTANT_HOME=${MRBOT_HOME}
		export LD_LIBRARY_PATH=/usr/local/lib

		echo "---------------------------------------------------------------------"
		rm -rf ${MRBOT_HOME}/lock/AppService.lock
		case "$MODE" in
			sleep)
				echo "init and sleep"
				while true;do sleep 10;done
				;;
			run)
				echo "init and run appservice"
				python ${MRBOT_HOME}/source/api/Source/Forge/AppService/AppService.py -p 8700
				;;
			*)
				echo "init only."
		esac
		echo "---------------------------------------------------------------------"
	else
		echo "${MRBOT_HOME} or ${MRBOT_HOME}/conf/instant.cfg.template not exist, exit"
		exit 1
	fi
}


##main###################################################

case "$1" in
	help)
		show_help
		;;
	init)
		fn_init
		;;
	init-and-sleep)
		fn_init "sleep"
		;;
	init-and-run)
		fn_init "run"
		;;
	*)
		show_usage
esac



