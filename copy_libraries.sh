#!/bin/sh
TF_SRC="$1"
DST="$2"
echo "Destination=$DST"

sudo mkdir -p $DST
sudo cp $TF_SRC/bazel-bin/tensorflow/libtensorflow_cc.so $DST
sudo cp $TF_SRC/bazel-bin/tensorflow/libtensorflow_framework.so $DST 
sudo cp $TF_SRC/bazel-bin/tensorflow/libtensorflow_framework.2.dylib $DST 

