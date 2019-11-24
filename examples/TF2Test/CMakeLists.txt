cmake_minimum_required(VERSION 3.9)
project(${PROJECT_NAME})

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

set(LIB_PATH $ENV{HOME}/Documents/src/tensorflow-libs/r2.0)
message("${LIB_PATH}")
include_directories(
        ${LIB_PATH}/include 
        ${LIB_PATH}/include/google
        ${LIB_PATH}/include/external/nsync/public)

link_directories(${LIB_PATH}/lib)
add_executable(${PROJECT_NAME} ${SRC_NAME})
target_link_libraries(${PROJECT_NAME} tensorflow_cc tensorflow_framework)
