FROM ubuntu:16.04

MAINTAINER scottslewis@gmail.com songweijia@gmail.com myles.l.pan@gmail.com

# use aliyun source mirror to accelerate
RUN  sed -i s@/archive.ubuntu.com/@/mirrors.tuna.tsinghua.edu.cn/@g /etc/apt/sources.list
RUN  apt-get clean
# add gcc-7 packages
RUN apt-get -y update
RUN apt-get install software-properties-common -y
RUN add-apt-repository ppa:ubuntu-toolchain-r/test -y
RUN apt-get -y update
RUN apt-get -y install gcc-7 g++-7
RUN update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-7 60 --slave /usr/bin/g++ g++ /usr/bin/g++-7
RUN update-alternatives --config gcc
ENV CC=gcc
ENV CXX=g++

# install other tools and dependencies
RUN apt-get -y install autoconf vim net-tools libssl-dev libreadline-dev libsnappy-dev libc-ares-dev \
librdmacm-dev libibverbs-dev libboost-dev libboost-system-dev \
libtool m4 automake wget curl make unzip iputils-ping git --fix-missing

# install other dependencies
COPY prerequisites/ /root/prerequisites
RUN ["chmod", "+x", "/root/prerequisites/install-cmake-3.18.sh"]
RUN ["chmod", "+x", "/root/prerequisites/install-spdlog.sh"]
RUN ["chmod", "+x", "/root/prerequisites/install-libfabric.sh"]
RUN ["chmod", "+x", "/root/prerequisites/install-mutils.sh"]
RUN ["chmod", "+x", "/root/prerequisites/install-mutils-containers.sh"]
RUN ["chmod", "+x", "/root/prerequisites/install-mutils-tasks.sh"]
RUN ["chmod", "+x", "/root/prerequisites/install-protobuf.sh"]
RUN ["chmod", "+x", "/root/prerequisites/install-grpc.sh"]
RUN ["chmod", "+x", "/root/prerequisites/install-json.sh"]

RUN ["/root/prerequisites/install-cmake-3.18.sh"]
RUN ["/root/prerequisites/install-spdlog.sh"]
RUN ["/root/prerequisites/install-libfabric.sh"]
RUN ["/root/prerequisites/install-mutils.sh"]
RUN ["/root/prerequisites/install-mutils-containers.sh"]
RUN ["/root/prerequisites/install-mutils-tasks.sh"]
RUN ["/root/prerequisites/install-json.sh"]
# RUN ["/root/prerequisites/install-grpc.sh"]
# RUN ["/root/prerequisites/install-protobuf.sh"]

# build derecho and cascade
COPY build/ /root/build
RUN ["chmod", "+x", "/root/build/build-derecho.sh"]
RUN ["chmod", "+x", "/root/build/build-cascade.sh"]

RUN ["/root/build/build-derecho.sh"]
RUN ["/root/build/build-cascade.sh"]

# configure derecho and cascade
COPY config/ /root/config
RUN ["chmod", "+x", "/root/config/config-derecho.sh"]

ENV LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH
ENV DERECHO_CONF_FILE=/derecho.cfg



