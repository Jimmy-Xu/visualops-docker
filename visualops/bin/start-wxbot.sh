#!/bin/bash

show_usage(){
  cat<<COMMENT
  Usage:
    ./start-wxbot.sh help                                      #show help
    ./start-wxbot.sh run                                       #
COMMENT
}

show_help(){
  cat <<COMMENT

  To enter mrbot-wxbot, run the following command in another shell
  $ docker exec -it mrbot-wxbot bash

===========================================================================================

  # Enter project dir
  $ cd /visualops/source/wxbot

  # Start a live-reload server
  $ /visualops/bin/start-wxbot.sh run

===========================================================================================

COMMENT
}



fn_run(){

  MODE=$1

  if [[ -d ${MRBOT_HOME} ]]  && [[ -d ${MRBOT_HOME}/source/wxbot ]];then
    cd ${MRBOT_HOME}/source/wxbot
    echo "init..."

    #NPM_REGISTRY=https://registry.npm.taobao.org
    NPM_REGISTRY=http://registry.npmjs.org
    npm config set $NPM_REGISTRY

    npm install --unsafe-perm

    #production serve
    NODE_ENV=production npm start

    #development serve
    #npm start

  else
    echo "${MRBOT_HOME} or ${MRBOT_HOME}/source/wxbot not exist, exit"
  fi

}


##main###################################################
MRBOT_HOME=/visualops
case "$1" in
  help)
    show_help
    ;;
  run)
    fn_run "$2" "$3"
    ;;
  *)
    show_usage
esac




