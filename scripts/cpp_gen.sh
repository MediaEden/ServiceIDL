#!/bin/bash -e

SCRIPT=`pwd`/$0
FILENAME=`basename $SCRIPT`
PATHNAME=`dirname $SCRIPT`
ROOT=$PATHNAME/..
CURRENT_DIR=`pwd`
PROTOBUF_DIR=${ROOT}/protos
PROTOC_DIR=$ROOT/build/libdeps/build/bin
PREFIX_DIR=$ROOT/gen/cpp

SUDO=""
if [[ $EUID -ne 0 ]]; then
  SUDO="sudo -E"
fi

pushd ${PROTOC_DIR}
${SUDO} rm -rf ${PREFIX_DIR}
${SUDO} mkdir -p ${PREFIX_DIR}
${SUDO} protoc -I=${PROTOBUF_DIR} --cpp_out=${PREFIX_DIR} ${PROTOBUF_DIR}/example_service/examples.proto
${SUDO} protoc -I=${PROTOBUF_DIR} --grpc_out=${PREFIX_DIR} --plugin=protoc-gen-grpc=${PROTOC_DIR}/grpc_cpp_plugin ${PROTOBUF_DIR}/example_service/examples.proto
popd
