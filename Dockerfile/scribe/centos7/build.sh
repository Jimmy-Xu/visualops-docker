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

fn_test_default() {

  NO=$1
  IMAGE=$2

  show_title "[[ Test image: $IMAGE ]]"

  show_title "${NO}.1 start scribed daemon with default config, without volume"
  fn_exec "docker run -d --name madeiracloud-scribe -P ${IMAGE} scribed"
  check_rlt $? "run scribed daemon container failed"

  echo "show container madeiracloud-scribe"
  docker ps -a | grep madeiracloud-scribe

  show_title "${NO}.2 view log"
  fn_exec 'docker logs madeiracloud-scribe'
  check_rlt $? "view log failed"

  show_title "${NO}.3 test scribed(write log)"
  fn_exec 'docker exec -it madeiracloud-scribe bash -c "echo `date` hello world! | scribe_cat test";'
  check_rlt $? "connect failed"

  sleep 8

  show_title "${NO}.4 test scribed(view log)"
  fn_exec 'docker exec -it madeiracloud-scribe bash -c "tail -n 10 /tmp/scribetest/test/test_current"'
  check_rlt $? "connect failed"

  show_title "${NO}.5 delete test container"
  fn_exec 'docker rm -f madeiracloud-scribe'
  check_rlt $? "delete test container failed"

}


fn_test() {

  NO=$1
  IMAGE=$2
  CONFIG=$3

  show_title "[[ Test image: $IMAGE ]]"

  show_title "${NO}.1 start scribed daemon with ${CONFIG}, with volume"
  fn_exec "docker run -d --name madeiracloud-scribe -v $(pwd)/../../../visualops:/visualops -P ${IMAGE} /visualops/bin/start-scribe.sh"
  check_rlt $? "run scribed daemon container failed"

  echo "show container madeiracloud-scribe"
  docker ps -a | grep madeiracloud-scribe

  show_title "${NO}.2 view log"
  fn_exec 'docker logs madeiracloud-scribe'
  check_rlt $? "view log failed"

  show_title "${NO}.3 test scribed(write log)"
  fn_exec 'docker run -it --rm --link madeiracloud-scribe:scribe madeiracloud/scribe:centos7 bash -c "echo `date` hello world! | scribe_cat -h \$SCRIBE_PORT_1463_TCP_ADDR:\$SCRIBE_PORT_1463_TCP_PORT test"'
  check_rlt $? "connect failed"

  sleep 8

  show_title "${NO}.4 test scribed(view log)"
  fn_exec 'docker exec -it madeiracloud-scribe bash -c "tail -n 10 /visualops/log/scribe/test/test_current"'
  check_rlt $? "connect failed"

  show_title "${NO}.5 delete test container"
  fn_exec 'docker rm -f madeiracloud-scribe'
  check_rlt $? "delete test container failed"

}

##########################################
show_title "1 start build madeiracloud/scribe:centos7-base"
OLD_IMG=$(docker images | grep "^madeiracloud/scribe.*centos7-base " | awk '{print $3}')
time fn_exec 'docker build -t madeiracloud/scribe:centos7-base .'
check_rlt $? "build failed"
NEW_IMG=$(docker images | grep "^madeiracloud/scribe.*centos7-base " | awk '{print $3}')
if [ "${OLD_IMG}" != "${NEW_IMG}" ];then
  IMG_UPDATED=true
else
  IMG_UPDATED=false
fi


##########################################
show_title "2 delete old container: madeiracloud-scribe"
fn_exec '(docker ps -a | grep madeiracloud-scribe > /dev/null 2>&1 ) && docker rm -f madeiracloud-scribe || echo "old madeiracloud-scribe not exist"'
check_rlt $? "delete old container failed"

##########################################
fn_test_default 3 "madeiracloud/scribe:centos7-base"

if [ "${IMG_UPDATED}" == "true" ];then
  ##########################################
  show_title "4.1 start optimize image size for madeiracloud/scribe:centos7-base"
  fn_exec 'docker run --name madeiracloud-scribe madeiracloud/scribe:centos7-base bash'
  check_rlt $? "start temp container failed"

  show_title "4.2 export image(madeiracloud/scribe:centos7-base) to export.tar"
  fn_exec 'docker export madeiracloud-scribe > export.tar'
  check_rlt $? "export image to tar failed"

  show_title "4.3 import image(madeiracloud/scribe:centos7-optimized) from export.tar"
  ls -l export.tar
  fn_exec 'cat export.tar | docker import - madeiracloud/scribe:centos7-optimized'
  check_rlt $? "import image from tar"

  show_title "4.4 build madeiracloud/scribe:centos7 from madeiracloud/scribe:optimized"
  cd optimize
  time fn_exec 'docker build -t madeiracloud/scribe:centos7 .'
  check_rlt $? "build madeiracloud/scribe:centos7 failed"
  cd ..

  show_title "4.5 show image for madeiracloud/scribe:centos7"
  fn_exec 'docker images | grep madeiracloud/scribe.*centos7'
  check_rlt $? "show image failed"

  show_title "4.6 clear old data"
  fn_exec 'rm -rf export.tar; docker rm -f madeiracloud-scribe'
  check_rlt $? "clear old data"
else
  show_title "4 image not changed, skip optimize image"
fi

##########################################
fn_test 5 "madeiracloud/scribe:centos7" "/visualops/conf/scribe.conf"

##########################################
show_title "Done!"

