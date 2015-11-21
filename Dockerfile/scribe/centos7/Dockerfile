# madeiracloud/scribe:centos7-base
# VERSION 2015.11.21

FROM centos:7.1.1503
MAINTAINER Jimmy Xu<xjimmyshcn@gmail.com>

#set env
ENV LD_LIBRARY_PATH /usr/local/lib
RUN echo /usr/local/lib > /etc/ld.so.conf.d/local.conf

# Install necessary tools(4min)
RUN time yum install -y unzip make autoconf automake gcc-c++ byacc flex bison libevent libevent-devel openssl-devel python-devel boost boost-devel php-cli php-devel libtool
RUN ldconfig

#copy thrift and scribe zipfile
WORKDIR /root/
COPY src/* /root/
RUN unzip thrift-0.5.x.zip
RUN unzip scribe-master.zip

#build thrift
WORKDIR /root/thrift-0.5.x/
RUN ./bootstrap.sh && ./configure

#begin patch thrift
RUN make ;\
if [ -f ./compiler/cpp/thrifty.hh ];then\
	echo "[patch1] Fix 'thrifty.h: No such file or directory' issue";\
	sed -i "s/thrifty.h\"/thrifty.hh\"/g" ./compiler/cpp/src/thriftl.ll ./compiler/cpp/thriftl.cc;\
	grep "include.*thrifty.h"  ./compiler/cpp/src/thriftl.ll ./compiler/cpp/thriftl.cc;\
fi;\
if [ -f ./lib/php/src/ext/thrift_protocol/php_thrift_protocol.cpp ];then\
	echo "[patch2] Fix 'function_entry' does not name a type issue";\
	sed -i "s/ function_entry/ zend_function_entry/g" ./lib/php/src/ext/thrift_protocol/php_thrift_protocol.cpp;\
	grep "function_entry"  ./lib/php/src/ext/thrift_protocol/php_thrift_protocol.cpp;\
fi;\
echo "finish patch for thrift, start make..."
#end patch thrift

RUN make && make install
RUN cd lib/py/ && python setup.py install

#build fb303
WORKDIR /root/thrift-0.5.x/contrib/fb303/
RUN ./bootstrap.sh && ./configure CPPFLAGS="-DHAVE_INTTYPES_H -DHAVE_NETINET_IN_H"
RUN make && make install
RUN cd py/ && python setup.py install

#build scribe
ADD src/scribe-master.zip /root/
WORKDIR /root/scribe-master

#begin patch for BOOST_FILESYSTEM_VERSION 3
RUN ./bootstrap.sh;\
./configure CPPFLAGS="-DHAVE_INTTYPES_H -DHAVE_NETINET_IN_H -DBOOST_FILESYSTEM_VERSION=2" LIBS="-lboost_system -lboost_filesystem";\
echo "[patch1] Fix 'error Compiling Filesystem version 3 file with BOOST_FILESYSTEM_VERSION defined!= 3' issue";\
sed -i "s/BOOST_FILESYSTEM_VERSION=2/BOOST_FILESYSTEM_VERSION=3/g" Makefile lib/py/Makefile src/Makefile config.status;\
grep "BOOST_FILESYSTEM_VERSION=" * -r;\
echo "finish patch for scribe, start make..."
#end patch for BOOST_FILESYSTEM_VERSION 3

RUN make && make install
RUN cd lib/py/ && python setup.py install

#remove unused package
RUN yum remove -y unzip make autoconf automake gcc-c++ gcc byacc flex bison libevent-devel openssl-devel python-devel boost-devel php-devel libtool glibc-devel
RUN yum remove -y libselinux-devel krb5-devel libcom_err-devel libverto-devel libstdc++-devel pcre-devel zlib-devel libsepol-devel perl libicu
RUN yum clean all

RUN ldconfig

#keep config and example
COPY ./etc/scribed/default.conf /etc/scribed/default.conf

RUN mkdir -p /usr/local/scribe
RUN ln -s /etc/scribed/default.conf /usr/local/scribe/scribe.conf

RUN mkdir -p /root/scribe-examples/
RUN mv /root/scribe-master/examples/* /root/scribe-examples/
RUN chmod +x /root/scribe-examples/scribe_cat
RUN ln -s /root/scribe-examples/scribe_cat /usr/bin/scribe_cat

#remove sourcefile
RUN rm -rf /root/thrift-0.5.x
WORKDIR /root/

# Port
EXPOSE 1463

# Volume
VOLUME /visualops

