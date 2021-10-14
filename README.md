# TensorFlow C++ Libraries

Personal notes on how to build TensorFlow C++ libraries on macOS



## TensorFlow r2.0 on macOS

TensorFlow-2.0.0 

CPU only with computation features such as AVX, AVX2, FMA, SSE4.2

Python 3.6

Bazel 0.24.1

Apple clang version 11.0.0 (clang-1100.0.33.12) 



### Prerequisites

Install XCode command line tool

Install Homebrew

Install necessary dependencies/packages:

```bash
brew install autoconf automake libtool cmake
brew install python@2 # or python (for python 3)
```

```
pip install -U --user pip six numpy wheel setuptools mock
pip install -U --user keras_applications --no-deps
pip install -U --user keras_preprocessing --no-deps
```



### Install Bazel

Download installer from https://github.com/bazelbuild/bazel/releases

```bash
chmod +x bazel-0.24.1-installer-darwin-x86_64.sh
./bazel-0.24.1-installer-darwin-x86_64.sh --user
```

Choos the version of Bazel based on a TensorFlow version you want to build. Check tested build configurations [here](https://www.tensorflow.org/install/source#tested_build_configurations). 

To check if Bazel is working

```bash
bazel version
```

If not, add `export PATH="\$PATH:\$HOME/bin"` in .bash_profile, re-open Terminal and try again.



### Get TensorFlow source

```bash
git clone https://github.com/tensorflow/tensorflow.git
cd tensorflow
```

```bash
git checkout r2.0
```

To see a list of TF versions: https://www.tensorflow.org/versions



### Run configure

```bash
./configure
```

(Here, I used python3 path by finding a path with command, `which python3`)



### Compile the framework

#### libtensorflow_cc.so

For CPU only optimized (release) version with the use of CPU features:

```bash
bazel build -c opt --copt=-mavx --copt=-mavx2 --copt=-mfma --copt=-msse4.2 --config=opt //tensorflow:libtensorflow_cc.so
```

*  `--config=monolithic`: configuration for a mostly static, monolithic build to ship your program and be compatible with other processors.
* remove ` --copt=-mavx --copt=-mavx2 --copt=-mfma  --copt=-msse4.2` if your CPU doesn't support the features.
* `--config=v1` : build TensorFlow 1.x instead of 2.x.

For CPU only debug version:

```bash
bazel build //tensorflow:libtensorflow_cc.so
```

For GPU optimized (release) version:

```bash
bazel build -c opt --config=opt --config=cuda //tensorflow:libtensorflow_cc.so
```



#### libtensorflow_framework.so

For CPU only optimized (release) version with the use of CPU features:

```bash
bazel build -c opt --copt=-mavx --copt=-mavx2 --copt=-mfma --copt=-msse4.2 --config=opt //tensorflow:libtensorflow_framework.so
```

For CPU only debug version:

```bash
bazel build //tensorflow:libtensorflow_framework.so
```

For GPU optimized (release) version:

```bash
bazel build -c opt --config=opt --config=cuda //tensorflow:libtensorflow_framework.so
```



### Download other dependencies

```bash
tensorflow/contrib/makefile/download_dependencies.sh
```



### Copy headers

To automatically copy necessary header files, use the given `copy_headers.sh` insider the root of your destination folder for the libraries:

```bash
cd [path/to/your/dst/]
./copy_headers.sh r2.0/include
```

You could add or remove paths for required dependencies in `copy_headers.sh`.

### Copy libraries

To automatically copy the libraries, use the given `copy_libraries.sh` insider the root of your destination folder for the libraries:

```bash
./copy_libraries.sh ../tensorflow r2.0/lib
```


Or, if you want to do the same manually, copy libraries:

```bash
cp [path/to/tensorflow/src]/bazel-bin/tensorflow/{libtensorflow_cc.so, libtensorflow_framework.so, libtensorflow_framework.2.dylib} [path/to/your/dst/]
```

(`libtensorflow_framework.2.dylib` is for the version compiled with CPU features ??)

#### macOS only

To clean a machine specific id in the lib and to use RPATH with CMake:

```bash
./fix_rpath.sh r2.0/lib
```

Or, manually:

```bash
cd [path/to/your/dst/]

sudo install_name_tool -id "@rpath/libtensorflow_cc.so" libtensorflow_cc.so
sudo install_name_tool -id "@rpath/libtensorflow_framework.so" libtensorflow_framework.so
sudo install_name_tool -id "@rpath/libtensorflow_framework.2.dylib" libtensorflow_framework.2.dylib 
```

To check whether it is fixed:

```bash
otool -L libtensorflow_cc.so
```

If it is fixed, you should see something like as below:

```bash
r2.0/lib/libtensorflow_cc.so:
	@rpath/libtensorflow_cc.so (compatibility version 0.0.0, current version 0.0.0)
	/usr/lib/libc++.1.dylib (compatibility version 1.0.0, current version 800.7.0)
	@rpath/libtensorflow_framework.2.dylib (compatibility version 0.0.0, current version 0.0.0)
	/usr/lib/libSystem.B.dylib (compatibility version 1.0.0, current version 1281.0.0)
	/System/Library/Frameworks/CoreFoundation.framework/Versions/A/CoreFoundation (compatibility version 150.0.0, current version 1673.126.0)
	/System/Library/Frameworks/Security.framework/Versions/A/Security (compatibility version 1.0.0, current version 59306.41.2)
	/System/Library/Frameworks/IOKit.framework/Versions/A/IOKit (compatibility version 1.0.0, current version 275.0.0)
	/System/Library/Frameworks/Foundation.framework/Versions/C/Foundation (compatibility version 300.0.0, current version 1673.126.0)
	/usr/lib/libobjc.A.dylib (compatibility version 1.0.0, current version 228.0.0)
```



### Test C++ code

Create `main.cpp` and `CMakeLists.txt` in the same folder, for example `examples/TF2Test/`.

- `main.cpp`

``` c++
#include <iostream>
#include <vector>
#include "tensorflow/cc/client/client_session.h"
#include "tensorflow/cc/ops/standard_ops.h"

int main() {

    using namespace tensorflow;
    using namespace tensorflow::ops;
    Scope root = Scope::NewRootScope();

    auto A = Const(root, {{1.f, 2.f}, {3.f, 4.f}});
    auto b = Const(root, {{5.f, 6.f}});
    auto x = MatMul(root.WithOpName("v"), A, b, MatMul::TransposeB(true));
    std::vector<Tensor> outputs;

    std::unique_ptr<ClientSession> session = std::make_unique<ClientSession>(root);
    TF_CHECK_OK(session->Run({x}, &outputs));
    std::cout << outputs[0].matrix<float>();

}
```

- `CMakeLists.txt`
  - Caution: You must change `LIB_PATH` with your lib path `path/to/your/dst/r2.0`. Below example assumes the lib path as  `~/Documents/src/tensorflow-libs/r2.0`.

```cmake
cmake_minimum_required(VERSION 3.9)
project(tf2test)

# C++14 for Tensorflow r2.0 otherwise cause error about 'std::make_unique'
set(CMAKE_CXX_STANDARD 14)
set(CMAKE_VERBOSE_MAKEFILE ON)

# use, i.e. don't skip the full RPATH for the build tree
SET(CMAKE_SKIP_BUILD_RPATH  FALSE)

# when building, don't use the install RPATH already
# (but later on when installing)
SET(CMAKE_BUILD_WITH_INSTALL_RPATH FALSE)
SET(CMAKE_INSTALL_RPATH "${CMAKE_INSTALL_PREFIX}/lib")

# add the automatically determined parts of the RPATH
# which point to directories outside the build tree to the install RPATH
SET(CMAKE_INSTALL_RPATH_USE_LINK_PATH TRUE)

# the RPATH to be used when installing, but only if it's not a system directory
LIST(FIND CMAKE_PLATFORM_IMPLICIT_LINK_DIRECTORIES "${CMAKE_INSTALL_PREFIX}/lib" isSystemDir)
IF("${isSystemDir}" STREQUAL "-1")
   SET(CMAKE_INSTALL_RPATH "${CMAKE_INSTALL_PREFIX}/lib")
ENDIF("${isSystemDir}" STREQUAL "-1")


# Here, you must set LIB_PATH with your lib path
set(LIB_PATH $ENV{HOME}/Documents/src/tensorflow-libs/r2.0) 
message("${LIB_PATH}")

# Include headers
include_directories(
        ${LIB_PATH}/include
        ${LIB_PATH}/include/google
        ${LIB_PATH}/include/external/nsync/public)

# Link libraries
link_directories(${LIB_PATH}/lib)
add_executable(tf2test main.cpp)
target_link_libraries(tf2test tensorflow_cc tensorflow_framework)
```

Compile and build:

```
cmake -H. -Bbuild
cmake --build build
```

Run and see the result:

```
./build/tf2test
17
39
```

Or, you can do the same by create `run.sh` in `examples/TF2Test/`.

- `run.sh`

```bash
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
```

Run:

```
./run.sh main main.cpp
```



#### Using `run.sh` in the root folder

Without making `CMakeLists.txt` and `run.sh ` files individually for each project, you can use the same files in a root folder. Note that  `run.sh` given in the root folder differs from the above.

Make sure your folder structure is as below:

```
[path/to/your/dst/]
  +-- CMakeLists.txt
  +-- run.sh
  +-- r2.0/
  +-- examples/
      |-- TF2Test/
          |-- main.cpp
```

And run:

```bash
./run.sh main examples/TF2Test/main.cpp
```



### References

* https://www.tensorflow.org/install/source
* http://blog.blitzblit.com/2017/06/11/creating-tensorflow-c-headers-and-libraries/
* https://itnext.io/how-to-use-your-c-muscle-using-tensorflow-2-0-and-xcode-without-using-bazel-builds-9dc82d5e7f80
* https://github.com/memo/ofxMSATensorFlow
  * https://github.com/memo/ofxMSATensorFlow/wiki/Rebuilding-library-from-scratch-(for-advanced-users)
  * https://github.com/memo/ofxMSATensorFlow/issues/14
  * https://github.com/memo/ofxMSATensorFlow/tree/master/scripts/ubuntu
* https://stackoverflow.com/a/55612771
* https://stackoverflow.com/questions/47131894/why-is-there-a-compile-error-using-tensorflow-c-api-on-
* https://stackoverflow.com/questions/47697761/cmake-run-time-error-dyld-library-not-loaded-for-dynamically-linked-resourcemac

* https://gitlab.kitware.com/cmake/community/wikis/doc/cmake/RPATH-handling
* https://qin.laya.com/tech_coding_help/dylib_linking.html
* http://www.bitbionic.com/2017/08/18/run-your-keras-models-in-c-tensorflow/

For Unbuntu/Linux 

* https://medium.com/@fanzongshaoxing/use-tensorflow-c-api-with-opencv3-bacb83ca5683
* https://github.com/FloopCZ/tensorflow_cc
* https://github.com/cjweeks/tensorflow-cmake
  * https://medium.com/@TomPJacobs/c-tensorflow-a-journey-bdecbbdd0f65

For Windows

* https://github.com/hluu11/SimpleTF-CPP