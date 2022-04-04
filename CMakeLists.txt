cmake_minimum_required(VERSION 3.21)

set(CMAKE_BUILD_TYPE "Release" CACHE STRING "CMake build configuration")

file(REAL_PATH ${CMAKE_CURRENT_LIST_DIR}/../ PROJECT_ROOT_DIR)

include(cmake/dependencies.cmake)
ProvideLlvm()
ProvideArmGnuToolchain()
set(CMAKE_TOOLCHAIN_FILE ${CMAKE_CURRENT_LIST_DIR}/cmake/llvm_toolchain_file.cmake CACHE PATH
    "Path to the CMake's toolchain file")

project(LibclangRtArmCortex LANGUAGES CXX C ASM)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS ON)

set(CMAKE_C_STANDARD 23)
set(CMAKE_C_STANDARD_REQUIRED OFF)
set(CMAKE_C_EXTENSIONS ON)

ProvideLlvmProject()

include(cmake/llvm_project.cmake)
include(cmake/tweaks.cmake)

EnableCompilerRt()
EnableLibcxx()
EnableLibcxxAbi()
EnableLibunwind()

UseAlternativeFprintf()
