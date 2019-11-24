#!/bin/sh

PROJECT_NAME="$1"
SRC_NAME="$2"

rm -rf build
cmake -DPROJECT_NAME=${PROJECT_NAME} -DSRC_NAME=${SRC_NAME} -H. -Bbuild && 
echo &&
cmake --build build &&
echo &&
./build/${PROJECT_NAME}
echo
