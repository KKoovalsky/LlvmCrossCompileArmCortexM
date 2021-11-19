cmake_minimum_required(VERSION 3.21)

set(CMAKE_BUILD_TYPE "Release" CACHE STRING "CMake build configuration")

file(REAL_PATH ${CMAKE_CURRENT_LIST_DIR}/../ PROJECT_ROOT_DIR)

include(cmake/dependencies.cmake)
ProvideLlvm()
ProvideArmGnuToolchain()
set(CMAKE_TOOLCHAIN_FILE ${CMAKE_CURRENT_LIST_DIR}/cmake/llvm_toolchain_file.cmake CACHE PATH
    "Path to the CMake's toolchain file")

project(LibclangRtArmCortex LANGUAGES CXX C ASM)

ProvideLlvmProject()

include(cmake/llvm_project.cmake)

EnableCompilerRt()
EnableLibunwind()
