#!/bin/bash

show_usage(){
  cat<<COMMENT
  Usage:
    ./start-ui.sh help                                      #show help
    ./start-ui.sh init                                      #npm install
    ./start-ui.sh run                                       #ionic serve (connect to backend => bot.jiecao.pw)
    ./start-ui.sh build                                     #build for android
    ./start-ui.sh run <backend_port> <host_os_ip>           #ionic serve (connect to backend => <host_ip>:<port>)

    ./start-ui.sh init-and-sleep                            #init and sleep
    ./start-ui.sh init-and-build                            #init and build for android
    ./start-ui.sh init-and-run                              #init and ionic serve (connect to backend => bot.jiecao.pw)
    ./start-ui.sh init-and-run <backend_port> <host_os_ip>  #init and ionic serve (connect to backend => <host_ip>:<port>)

COMMENT
}

show_help(){
  cat <<COMMENT

  To enter mrbot-ui, run the following command in another shell
  $ docker exec -it mrbot-ui bash

===========================================================================================

  # Enter project dir
  $ cd /visualops/source/mrbot-ui

  # Build for android
  $ /visualops/bin/start-ui.sh build

  # Start a live-reload server
  $ /visualops/bin/start-ui.sh run

  # Start a live-reload server
  $ /visualops/bin/start-ui.sh run <BACKEND_DOMAIN>


===========================================================================================

COMMENT
}



fn_init(){

  MODE=$1

  if [[ -d ${MRBOT_HOME} ]]  && [[ -d ${MRBOT_HOME}/source/mrbot-ui ]];then
    cd ${MRBOT_HOME}/source/mrbot-ui
    echo "init..."

    #NPM_REGISTRY=https://registry.npm.taobao.org
    NPM_REGISTRY=registry http://registry.npmjs.org
    npm config set registry $NPM_REGISTRY

    npm install --unsafe-perm
    npm rebuild node-sass

    case "$MODE" in
      sleep)
        while true;do sleep 10;done
        ;;
      build)
        fn_build
        ;;
      run)
        fn_run $2 $3
        ;;
      *)
        echo "init only."
        ;;
    esac
  else
    echo "${MRBOT_HOME} or ${MRBOT_HOME}/source/mrbot-ui not exist, exit"
  fi

}

fn_run(){
  PORT=$1
  DOMAIN=$2
  echo "[fn_run]DOMAIN: ${DOMAIN}"
  cd ${MRBOT_HOME}/source/mrbot-ui
  if [[ "$DOMAIN" == "" ]];then
    DOMAIN="bot.jiecao.pw"
  else
    if [[ ! -z $PORT ]] || [[ $PORT == "80" ]] ;then
      DOMAIN="${DOMAIN}:${PORT}"
    else
      DOMAIN="${DOMAIN}"
    fi
  fi
  if [ -f www/js/constant.coffee ];then
    echo "update 'DOMAIN' url in 'www/js/constant.coffee'"
    echo "found nginx, connect to nginx( 'http://${DOMAIN}' )"
    sed -i "s/DOMAIN.*/DOMAIN    : 'http:\/\/${DOMAIN}'/" www/js/constant.coffee
  fi

  if [ -f www/js/notification/NotificationServices.coffee ];then
    echo "update 'PUSH_SERVER_URL' url in 'www/js/notification/NotificationServices.coffee'"
    echo "use websocket ( PUSH_SERVER_URL = 'ws:\/\/${DOMAIN}\/ws\/' )"
    sed -i "s/PUSH_SERVER_URL.*ws.*/PUSH_SERVER_URL = 'ws:\/\/${DOMAIN}\/ws\/'/" www/js/notification/NotificationServices.coffee
  fi

  echo "backend info"
  grep "DOMAIN" www/js/constant.coffee
  echo
  echo "run 'ionic serve' ..."
  echo "-----------------------------------------"
  ETH_IP=$(ip -f inet addr | grep eth0 -A1 |grep inet | awk '{print $2}' | cut -d"/" -f1)
  ionic serve --address ${ETH_IP}

}


fn_build(){
  cd ${MRBOT_HOME}/source/mrbot-ui
  echo "start build for android"
  ionic platform add android
  echo "----------------------------------"
  #fix build bug for plugin com.synconset.imagepicker under android
  ##patch start##################
  for f in platforms/android/AndroidManifest.xml plugins/com.synconset.imagepicker/plugin.xml
  do
    echo "#patch: $f"
    grep "com.synconset.MultiImageChooserActivity" -A1 $f | grep intent-filter
    if [ $? -eq 0 ];then
      echo "need patch for pugins/com.synconset.imagepicker"
      sed -i '/com.synconset.MultiImageChooserActivity/{n;d}' $f
    else
      echo "already patched"
    fi
  done
  echo "#patch: plugins/android.json"
  sed -i '/com.synconset.MultiImageChooserActivity/s/<intent-filter \/>//g' plugins/android.json
  ##patch end###################

  echo "----------------------------------"
  echo "#compile all"
  expect <<!
set timeout 30
spawn ionic serve
expect "Finished 'ionic' after" { send "q\r" } \
"Address Selection:" { send "1\r" } \
"ionic $" { send "q\r" }
!
  echo "----------------------------------"
  echo "#build android"
  ionic build android
}

##main###################################################
MRBOT_HOME=/visualops
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
  init-and-build)
    fn_init "build"
    ;;
  init-and-run)
    fn_init "run" "$2" "$3"
    ;;
  build)
    fn_build
    ;;
  run)
    fn_run "$2" "$3"
    ;;
  *)
    show_usage
esac




