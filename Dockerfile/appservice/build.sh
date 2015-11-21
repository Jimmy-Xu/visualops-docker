#!/bin/bash

check_rlt() {
  EXIT_CODE=$1
  EXIT_MSG=$2
  if [ $EXIT_CODE -ne 0 ];then
    echo $EXIT_MSG
    exit 1
  fi
}

show_title() {
  echo -e "\n"
  echo "---------------------------------------------------------------"
  echo $1
}

fn_exec() {
  echo "run command > $1"
  eval "$1"
}

fn_delete_container() {
  for i in madeiracloud-appservice madeiracloud-mongo madeiracloud-scribe madeiracloud-redis
  do
    echo -e "\n>>delete container: $i"
    fn_exec "(docker ps -a | grep $i > /dev/null 2>&1 ) && docker rm -f $i || echo 'old $i not exist'"
    check_rlt $? "delete test container $i failed"
  done
}

fn_test() {

  NO=$1
  IMAGE=$2

  show_title "[[ Test image: $IMAGE ]]"

  show_title "${NO}.1 clone api repo"
  API_DIR=$(pwd)/../../visualops/source/api
  if [ -d ${API_DIR} ];then
    echo "${API_DIR} exist, start pull"
    cd ${API_DIR}
    git pull
    check_rlt $? "pull api repo failed"
    cd -
  else
    echo "${API_DIR} not exist, start clone"
    git clone git@github.com:MadeiraCloud/madeiracloud-api.git $(pwd)/../../visualops/source/api
    check_rlt $? "clone api repo failed"
  fi

  show_title "${NO}.2 start dependent service - madeiracloud-redis"
  fn_exec "docker run -d --name madeiracloud-redis -v $(pwd)/../../visualops:/visualops -P madeiracloud/redis:2.6 /visualops/bin/start-redis.sh"
  check_rlt $? "start madeiracloud-redis failed"

  show_title "${NO}.3 start dependent service - madeiracloud-mongo"
  fn_exec "docker run -d --name madeiracloud-mongo --volumes-from madeiracloud-redis -P madeiracloud/mongo:2.6 /visualops/bin/start-mongo.sh"
  check_rlt $? "start madeiracloud-mongo failed"

  show_title "${NO}.4 start dependent service - madeiracloud-scribe"
  fn_exec "docker run -d --name madeiracloud-scribe --volumes-from madeiracloud-redis -P madeiracloud/scribe:centos7 /visualops/bin/start-scribe.sh"
  check_rlt $? "start madeiracloud-scribe failed"

  show_title "${NO}.5 start AppService"
  echo "for debug> docker run -it --rm --volumes-from madeiracloud-redis --link madeiracloud-redis:redis --link madeiracloud-mongo:mongo --link madeiracloud-scribe:scribe -P ${IMAGE} bash"
  fn_exec "docker run -d --name madeiracloud-appservice --volumes-from madeiracloud-redis --link madeiracloud-redis:redis --link madeiracloud-mongo:mongo --link madeiracloud-scribe:scribe -P ${IMAGE} /visualops/bin/start-appservice.sh"
  check_rlt $? "run AppService container failed"

  sleep 5

  show_title "${NO}.6 view log"
  fn_exec 'docker logs madeiracloud-appservice'
  check_rlt $? "view log failed"

}

##########################################
show_title "1 start build madeiracloud/appservice:centos7-base"
OLD_IMG=$(docker images | grep "^madeiracloud/appservice.*centos7-base " | awk '{print $3}')
time fn_exec 'docker build -t madeiracloud/appservice:centos7-base .'
check_rlt $? "build failed"
NEW_IMG=$(docker images | grep "^madeiracloud/appservice.*centos7-base " | awk '{print $3}')
if [ "${OLD_IMG}" != "${NEW_IMG}" ];then
  IMG_UPDATED=true
else
  IMG_UPDATED=false
fi

##########################################
show_title "2 delete old container: madeiracloud-appservice / madeiracloud-mongo / madeiracloud-scribe / madeiracloud-redis"
fn_delete_container

if [ "${IMG_UPDATED}" == "true" ];then

  fn_test 3 "madeiracloud/appservice:centos7-base"

  ##########################################
  show_title "4 delete test container: madeiracloud-appservice / madeiracloud-mongo / madeiracloud-scribe / madeiracloud-redis"
  fn_delete_container

  ##########################################
  show_title "5.1 start optimize image size for madeiracloud/appservice:centos7-base"
  fn_exec 'docker run --name madeiracloud-appservice madeiracloud/appservice:centos7-base bash'
  check_rlt $? "start temp container failed"

  show_title "5.2 export image(madeiracloud/appservice:centos7-base) to export.tar"
  fn_exec 'docker export madeiracloud-appservice > export.tar'
  check_rlt $? "export image to tar failed"

  show_title "5.3 import image(madeiracloud/appservice:centos7-optimized) from export.tar"
  ls -l export.tar
  fn_exec 'cat export.tar | docker import - madeiracloud/appservice:centos7-optimized'
  check_rlt $? "import image from tar"

  show_title "5.4 build madeiracloud/appservice:centos7 from madeiracloud/appservice:centos7-optimized"
  cd optimize
  time fn_exec 'docker build -t madeiracloud/appservice:centos7 .'
  check_rlt $? "build madeiracloud/appservice:centos7 failed"
  cd ..

  show_title "5.5 show image for madeiracloud/appservice:centos7"
  fn_exec 'docker images | grep madeiracloud/appservice.*centos7'
  check_rlt $? "show image failed"

  show_title "5.6 clear old data"
  fn_exec 'rm -rf export.tar; docker rm -f madeiracloud-appservice'
  check_rlt $? "clear old data"
else
  show_title "image not changed, skip optimize image"
fi

##########################################
fn_test 6 "madeiracloud/appservice:centos7"

##########################################
show_title "Done!"

