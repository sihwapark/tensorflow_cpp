#!/bin/sh
DST="$1"
echo "Destination=$DST"

sudo install_name_tool -id "@rpath/libtensorflow_cc.so" $DST/libtensorflow_cc.so
sudo install_name_tool -id "@rpath/libtensorflow_framework.so" $DST/libtensorflow_framework.so
sudo install_name_tool -id "@rpath/libtensorflow_framework.2.dylib" $DST/libtensorflow_framework.2.dylib
