#!/bin/bash -e

#==============================#

SCRIPT=`pwd`/$0
FILENAME=`basename $SCRIPT`
PATHNAME=`dirname $SCRIPT`
ROOT=$PATHNAME/..
CURRENT_DIR=`pwd`
BUILD_DIR=$ROOT/gen
LIB_DIR=$BUILD_DIR/cpp
PREFIX_DIR=$LIB_DIR/build/

CPP=false
JAVA=false

SUDO=""
if [[ $EUID -ne 0 ]]; then
  SUDO="sudo -E"
fi

parse_arguments() {
  while [ "$1" != "" ]; do
    case $1 in
      "--cpp")
        CPP=true
        ;;
      "--java")
        JAVA=true
        ;;
    esac
    shift
  done
}
parse_arguments $*

if [ "$CPP" = "true" ]; then
  echo "Generating CPP protos/grpc output"
  . cpp_gen.sh
fi
if [ "$JAVA" = "true" ]; then
  echo "Generating JAVA protos/grpc output"
  . gen_jave.sh
fi
