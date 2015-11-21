#madeiracloud/appservice:centos7
# VERSION 2015.11.21

FROM	madeiracloud/appservice:centos7-optimized
MAINTAINER Jimmy Xu<xjimmyshcn@gmail.com>

#set env
ENV PYTHON_EGG_CACHE /visualops/.python-eggs
ENV PYTHONPATH /visualops/source/api/Source
ENV INSTANT_HOME /visualops
ENV LD_LIBRARY_PATH /usr/lib64:/usr/lib:/usr/local/lib

#volume
VOLUME /visualops

#port
EXPOSE 8700

#execute
WORKDIR /root/
CMD ["./start-service.sh"]

