echo "start donload thrift and scribe"
echo

CUR_DIR=$(pwd)
SCRIBE_VER=2.2-1
URL=http://rpm.sys.fm/centos/6/x86_64


#download scribe
mkdir -p rpm/scribe/${SCRIBE_VER}
cd rpm/scribe/${SCRIBE_VER}
pwd
wget -c ${URL}/scribe-python-${SCRIBE_VER}.el6.x86_64.rpm
wget -c ${URL}/scribe-${SCRIBE_VER}.el6.x86_64.rpm

cd ${CUR_DIR}
#download thrift
for ver in 0.5.0-1 0.8.0-1 #0.9.0-1
do
	mkdir -p rpm/thrift/${ver}
	cd rpm/thrift/${ver}
	pwd
	echo "download thrift (${ver})"
	wget -c ${URL}/thrift-cpp-devel-${ver}.el6.x86_64.rpm
	wget -c ${URL}/thrift-cpp-${ver}.el6.x86_64.rpm
	wget -c ${URL}/fb303-php-${ver}.el6.x86_64.rpm
	wget -c ${URL}/thrift-php-${ver}.el6.x86_64.rpm
	wget -c ${URL}/fb303-python-${ver}.el6.x86_64.rpm
	wget -c ${URL}/thrift-python-${ver}.el6.x86_64.rpm
	wget -c ${URL}/thrift-${ver}.el6.x86_64.rpm
	wget -c ${URL}/fb303-${ver}.el6.x86_64.rpm
	cd ${CUR_DIR}
done


