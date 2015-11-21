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
  echo ""
  echo "---------------------------------------------------------------"
  echo $1
}

fn_exec() {
  echo "run command > $1"
  eval "$1"
}

fn_delete_container() {
  for i in madeiracloud-nginx madeiracloud-appservice madeiracloud-mongo madeiracloud-scribe madeiracloud-redis
  do
    echo -e "\n>>delete container: $i"
    fn_exec "(docker ps -a | grep $i > /dev/null 2>&1 ) && docker rm -f $i || echo 'old $i not exist'"
    check_rlt $? "delete test container $i failed"
  done
}


show_title "1 start build madeiracloud/nginx:1.9.4"
time docker build -t madeiracloud/nginx:1.9.4 .
check_rlt $? "build failed"

show_title "2) delete old container: madeiracloud-nginx / madeiracloud-appservice / madeiracloud-mongo / madeiracloud-scribe / madeiracloud-redis"
fn_delete_container

##########################################

show_title "3.1 start nginx service with default config, without volume"
docker run -d --name madeiracloud-nginx -P madeiracloud/nginx:1.9.4 nginx -g "daemon off;"
check_rlt $? "run nginx service container failed"

show_title "3.2 view log"
docker logs madeiracloud-nginx
check_rlt $? "view log failed"

show_title "3.3 test connect nginx service with curl"
HOST_PORT=$(docker inspect --format='{{(index (index .NetworkSettings.Ports "80/tcp") 0).HostPort}}' madeiracloud-nginx)
curl -sSL http://localhost:${HOST_PORT} | grep "Welcome to nginx!"
check_rlt $? "connect failed"

show_title "3.4 delete test container"
docker rm -f madeiracloud-nginx
check_rlt $? "delete test container failed"

##########################################

show_title "4 Start nginx service with /visualops/conf/nginx.conf, with volume"

show_title "1) delete old container: madeiracloud-nginx / madeiracloud-appservice / madeiracloud-mongo / madeiracloud-scribe / madeiracloud-redis"
fn_delete_container

show_title "2) start dependent service - madeiracloud-redis"
fn_exec "docker run -d --name madeiracloud-redis -v $(pwd)/../../visualops:/visualops -P madeiracloud/redis:2.6 /visualops/bin/start-redis.sh"
check_rlt $? "start madeiracloud-redis failed"

show_title "3) start dependent service - madeiracloud-mongo"
fn_exec "docker run -d --name madeiracloud-mongo --volumes-from madeiracloud-redis -P madeiracloud/mongo:2.6 /visualops/bin/start-mongo.sh"
check_rlt $? "start madeiracloud-mongo failed"

show_title "4) start dependent service - madeiracloud-scribe"
fn_exec "docker run -d --name madeiracloud-scribe --volumes-from madeiracloud-redis -P madeiracloud/scribe:centos7 /visualops/bin/start-scribe.sh"
check_rlt $? "start madeiracloud-scribe failed"

show_title "5) start AppService"
fn_exec "docker run -d --name madeiracloud-appservice --volumes-from madeiracloud-redis --link madeiracloud-redis:redis --link madeiracloud-mongo:mongo --link madeiracloud-scribe:scribe -P madeiracloud/appservice:centos7 /visualops/bin/start-appservice.sh"
check_rlt $? "run AppService container failed"

show_title "6) start nginx"
fn_exec "docker run -d --name madeiracloud-nginx --volumes-from madeiracloud-redis --link madeiracloud-appservice:appservice -P madeiracloud/nginx:1.9.4 /visualops/bin/start-nginx.sh"
check_rlt $? "run nginx service container failed"

sleep 5

show_title "7) view log"
fn_exec "docker logs madeiracloud-nginx"
check_rlt $? "view log failed"

sleep 5

show_title "8) test connect nginx service with curl"
HOST_PORT=$(docker inspect --format='{{(index (index .NetworkSettings.Ports "80/tcp") 0).HostPort}}' madeiracloud-nginx)
echo -e "\nUser register"
echo "curl -X POST http://localhost:${HOST_PORT}/account -d '{\"phone\":\"jimmy\",\"name\":\"jimmy\",\"password\":\"aaa123aa\"}' | xargs -i printf {}"
curl -X POST http://localhost:${HOST_PORT}/account -d '{"phone":"jimmy","name":"jimmy","password":"aaa123aa"}' | xargs -i printf {}

echo -e "\n\nUser login"
echo "curl -X POST http://localhost:${HOST_PORT}/session -d '{\"phone\":\"jimmy\",\"password\":\"aaa123aa\"}' | xargs -i printf {}"
curl -X POST http://localhost:${HOST_PORT}/session -d '{"phone":"jimmy","password":"aaa123aa"}' | xargs -i printf {}
check_rlt $? "login failed"

##########################################
show_title "Done!"

