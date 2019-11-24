#!/bin/sh
DST="$1"
echo "Destination=$DST"

sudo mkdir -p $DST/tensorflow

sudo cp -RL ../tensorflow/tensorflow/core $DST/tensorflow
sudo cp -RL ../tensorflow/tensorflow/cc $DST/tensorflow

sudo mkdir -p $DST/third_party
sudo cp -RL ../tensorflow/third_party/eigen3 $DST/third_party

sudo cp -RL ../tensorflow/bazel-genfiles/tensorflow/cc $DST/tensorflow
sudo cp -RL ../tensorflow/bazel-genfiles/tensorflow/core $DST/tensorflow

sudo cp -RLf ../tensorflow/bazel-tensorflow/external/eigen_archive/unsupported $DST
sudo cp -RLf ../tensorflow/bazel-tensorflow/external/eigen_archive/Eigen $DST  
sudo cp -RLf ../tensorflow/bazel-tensorflow/external/com_google_absl/absl $DST
sudo cp -RLf ../tensorflow/bazel-tensorflow/external/com_google_protobuf/src/google $DST

sudo mkdir -p $DST/external
sudo cp -RL ../tensorflow/tensorflow/contrib/makefile/downloads/nsync $DST/external

