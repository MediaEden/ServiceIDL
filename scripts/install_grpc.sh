#!/bin/bash -e

#==============================#

SCRIPT=`pwd`/$0
FILENAME=`basename $SCRIPT`
PATHNAME=`dirname $SCRIPT`
ROOT=$PATHNAME/..
BUILD_DIR=$ROOT/build
CURRENT_DIR=`pwd`
LIB_DIR=$BUILD_DIR/libdeps
PREFIX_DIR=$LIB_DIR/build/

DEBUG=false
CLEANUP=false
INCR_INSTALL=false

SUDO=""
if [[ $EUID -ne 0 ]]; then
  SUDO="sudo -E"
fi

parse_arguments() {
  while [ "$1" != "" ]; do
    case $1 in
      "--debug")
        DEBUG=true
        ;;
      "--cleanup")
        CLEANUP=true
        ;;
      "--incremental")
        INCR_INSTALL=true
        ;;
     esac
     shift
   done
}
parse_arguments $*

#==============================#

if [ "$CLEANUP" = "true" ]; then
  echo "Cleaning up..."
  if [ -d $BUILD_DIR ]; then
    rm -rf $BUILD_DIR
  fi
fi

#==============================#

install_apt_deps() {
  ${SUDO} apt update
  ${SUDO} apt install build-essential autoconf libtool pkg-config -y
  ${SUDO} apt install libssl-dev -y
}

install_cmake() {
  ${SUDO} apt update
  ${SUDO} apt install wget
  wget -q -O cmake-linux.sh https://github.com/Kitware/CMake/releases/download/v3.19.6/cmake-3.19.6-Linux-x86_64.sh
  
  # global cmake change ... need check
  ${SUDO} sh cmake-linux.sh -- --skip-license --prefix=/usr
  rm cmake-linux.sh
}

install_grpc() {
  local DIR="grpc"
  MY_INSTALL_DIR=$PREFIX_DIR

  mkdir -p ${LIB_DIR}
  pushd ${LIB_DIR}

  rm -rf ${DIR}
  git clone --recurse-submodules -b v1.38.0 https://github.com/grpc/grpc
  pushd ${DIR}
  mkdir -p cmake/build
  pushd cmake/build
  cmake  \
    -DCMAKE_BUILD_TYPE=Release  \
    -DCMAKE_INSTALL_PREFIX=$MY_INSTALL_DIR \
    -DgRPC_INSTALL=ON  \
    -DgRPC_BUILD_TESTS=OFF  \
		-DgRPC_ABSL_PROVIDER=module  \
		-DgRPC_CARES_PROVIDER=module  \
		-DgRPC_PROTOBUF_PROVIDER=module  \
		-DgRPC_RE2_PROVIDER=module  \
		-DgRPC_SSL_PROVIDER=module  \
  	-DgRPC_ZLIB_PROVIDER=module  \
    -DBUILD_SHARED_LIBS=ON  \
    ../..
  make -j4
  make install
  popd
  popd
  popd 
}

#==============================#

mkdir -p $PREFIX_DIR

install_apt_deps
install_cmake                    // need 3.13 or later
install_grpc

