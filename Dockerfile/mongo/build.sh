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

show_title "1 start build madeiracloud/mongo:2.6"
time docker build -t madeiracloud/mongo:2.6 .
check_rlt $? "build failed"

show_title "2 delete old container: madeiracloud-mongo"
(docker ps -a | grep madeiracloud-mongo) && docker rm -f madeiracloud-mongo || echo "old madeiracloud-mongo not exist"
check_rlt $? "delete old container failed"

##########################################

show_title "3.1 start mongodb server with default config, without volume"
docker run -d --name madeiracloud-mongo madeiracloud/mongo:2.6 mongod
check_rlt $? "run mongodb server container failed"

show_title "3.2 view log"
docker logs madeiracloud-mongo
check_rlt $? "view log failed"

show_title "3.3 test connect mongodb server with mongo cli(port:27017)"
docker run --rm -it --link madeiracloud-mongo:mongo madeiracloud/mongo:2.6 sh -c 'exec mongo "$MONGO_PORT_27017_TCP_ADDR:$MONGO_PORT_27017_TCP_PORT/test" -eval "printjson(db.stats())"'
check_rlt $? "connect failed"

show_title "3.4 delete test container"
docker rm -f madeiracloud-mongo
check_rlt $? "delete test container failed"

##########################################

show_title "Test for Linux"
show_title "4.1 start mongodb server with '/visualops/conf/mongo.conf', with volume"
docker run -d --name madeiracloud-mongo -v $(pwd)/../../visualops:/visualops -P madeiracloud/mongo:2.6 /visualops/bin/start-mongo.sh
check_rlt $? "run mongodb server container failed"

echo "check database"
if [ ! -f $(pwd)/../../visualops/db/mongodb/local.ns ];then
	echo "wait for create db ..."
	sleep 5
fi

show_title "4.2 view log"
docker logs madeiracloud-mongo
check_rlt $? "view log failed"

show_title "4.3 test connect mongodb server with mongo cli(port:8290)"
docker run --rm -it --link madeiracloud-mongo:mongo madeiracloud/mongo:2.6 sh -c 'exec mongo "$MONGO_PORT_8290_TCP_ADDR:$MONGO_PORT_8290_TCP_PORT/test" -eval "printjson(db.stats())"'
check_rlt $? "connect failed"

show_title "4.4 delete test container"
docker rm -f madeiracloud-mongo
check_rlt $? "delete test container failed"

##########################################

show_title "Test for Mac"
show_title "5.1 start mongodb server with '/visualops/conf/mongo-mac.conf', with volume"
docker run -d --name madeiracloud-mongo -v $(pwd)/../../visualops:/visualops -P madeiracloud/mongo:2.6 /visualops/bin/start-mongo.sh mac
check_rlt $? "run mongodb server container failed"

echo "check database"
docker exec -it madeiracloud-mongo ls /opt/visualops/db/mongodb/local.ns
if [ $? -ne 0 ];then
	echo "wait for create db ..."
	sleep 5
fi

show_title "5.2 view log"
docker logs madeiracloud-mongo
check_rlt $? "view log failed"

show_title "5.3 test connect mongodb server with mongo cli(port:8290)"
docker run --rm -it --link madeiracloud-mongo:mongo madeiracloud/mongo:2.6 sh -c 'exec mongo "$MONGO_PORT_8290_TCP_ADDR:$MONGO_PORT_8290_TCP_PORT/test" -eval "printjson(db.stats())"'
check_rlt $? "connect failed"

show_title "5.4 delete test container"
docker rm -f madeiracloud-mongo
check_rlt $? "delete test container failed"

##########################################

show_title "Done!"

