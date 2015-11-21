#madeiracloud/appservice:centos7-base
# VERSION 2015.11.21

FROM	madeiracloud/scribe:centos7
MAINTAINER Jimmy Xu<xjimmyshcn@gmail.com>

WORKDIR /root/

#install client(redis,mongo)
RUN yum install -y epel-release
RUN yum install -y mongodb
RUN yum install -y redis

#install python lib
RUN yum install -y python-setuptools python-devel gcc libffi-devel openssl-devel
RUN easy_install pip

#fix "InsecurePlatformWarning: A true SSLContext object is not available" for python < 2.7.9
RUN pip install -U requests[security]

#motor => certifi-2015.4.28 greenlet-0.4.7 pymongo-2.8 tornado-4.2.1
RUN pip install certifi==2015.4.28
RUN pip install tornado==4.2.1
RUN pip install greenlet==0.4.7
RUN pip install pymongo==2.8
RUN pip install motor==0.4

#bcrypt => cffi-1.2.1 pycparser-2.14 six-1.9.0
RUN pip install cffi==1.2.1
RUN pip install pycparser==2.14
RUN pip install six==1.9.0
RUN pip install bcrypt==2.0.0

RUN pip install bencode==1.0 pyparsing==2.0.3 jsonschema==2.5.1 meld3==1.0.2
RUN pip install redis==2.10.3 tornado-redis==2.4.18
RUN pip install qiniu==7.0.5 jpush==3.1.2
RUN pip install requests==2.8.1 futures==3.0.3 requests-futures==0.9.5

#clean rpm cache
RUN yum remove -y gcc
RUN yum clean all
RUN ldconfig

#set env
ENV PYTHON_EGG_CACHE /visualops/.python-eggs
ENV PYTHONPATH /visualops/source/api/Source
ENV LD_LIBRARY_PATH /usr/lib64:/usr/lib:/usr/local/lib
ENV INSTANT_HOME /visualops

#port
EXPOSE 8700

#volume
VOLUME /visualops

