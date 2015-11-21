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


show_title "1 start build madeiracloud/redis:2.6"
time fn_exec "docker build -t madeiracloud/redis:2.6 ."
check_rlt $? "build failed"

show_title "2 delete old container: madeiracloud-redis"
(docker ps -a | grep madeiracloud-redis) && docker rm -f madeiracloud-redis || echo "old madeiracloud-redis not exist"
check_rlt $? "delete old container failed"

##########################################

show_title "3.1 start redis-server with default config, without volume"
fn_exec "docker run -d --name madeiracloud-redis -P madeiracloud/redis:2.6 bash -c 'redis-server'"
check_rlt $? "run redis-server container failed"

show_title "3.2 view log"
fn_exec "docker logs madeiracloud-redis"
check_rlt $? "view log failed"

show_title "3.3 test connect redis-server with redis-cli(port:6379)"
fn_exec "docker run --rm -it --link madeiracloud-redis:redis madeiracloud/redis:2.6 sh -c 'exec redis-cli -h \$REDIS_PORT_6379_TCP_ADDR -p \$REDIS_PORT_6379_TCP_PORT ping'"
check_rlt $? "connect failed"

show_title "3.4 delete test container"
fn_exec "docker rm -f madeiracloud-redis"
check_rlt $? "delete test container failed"

##########################################

show_title "4.1 start redis-server with '/visualops/conf/redis.conf', with volume"
fn_exec "docker run -d --name madeiracloud-redis -v $(pwd)/../../visualops:/visualops -P madeiracloud/redis:2.6 /visualops/bin/start-redis.sh"
check_rlt $? "run redis-server container failed"


show_title "4.2 view log"
fn_exec "docker logs madeiracloud-redis"
check_rlt $? "view log failed"

show_title "4.3 test connect redis-server with redis-cli(port:8285)"
fn_exec "docker run --rm -it --link madeiracloud-redis:redis madeiracloud/redis:2.6 sh -c 'exec redis-cli -h \$REDIS_PORT_8285_TCP_ADDR -p \$REDIS_PORT_8285_TCP_PORT ping'"
check_rlt $? "connect failed"

show_title "4.4 delete test container"
fn_exec "docker rm -f madeiracloud-redis"
check_rlt $? "delete test container failed"

##########################################

show_title "Done!"


