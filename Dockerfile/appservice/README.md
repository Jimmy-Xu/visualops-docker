## description
 madeiracloud/appservice:centos7 is based madeiracloud/scribed:centos7, so madeiracloud/appservice:centos7 include two service: `scribed` and `AppService`

## clone api repo
    git clone git@github.com:MadeiraCloud/madeiracloud-api.git visualops/source/api
    cd visualops/source/api && git checkout develop && cd ../../..

## build
    time docker build -t madeiracloud/appservice:base .


