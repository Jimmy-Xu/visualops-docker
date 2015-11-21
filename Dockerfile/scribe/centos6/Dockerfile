# madeiracloud/scribe:centos6-base
# VERSION 2015.11.21

FROM	centos:6.6
MAINTAINER Jimmy Xu<xjimmyshcn@gmail.com>

WORKDIR /root/

# Port
EXPOSE 1463

# install dependency
RUN yum install -y php libevent boost

# set env
ENV LD_LIBRARY_PATH /usr/local/lib
RUN echo /usr/local/lib > /etc/ld.so.conf.d/local.conf
RUN ldconfig

# install scribe from rpm
COPY rpm/ /root/
RUN rpm -ivh thrift/0.5.0-1/*.rpm
RUN rpm -ivh scribe/2.2-1/*.rpm
RUN rm -rf /root/rpm

RUN mkdir -p /usr/local/scribe
RUN ln -s /etc/scribed/default.conf /usr/local/scribe/scribe.conf

VOLUME /visualops

