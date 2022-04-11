cmake_minimum_required(VERSION 3.21)
set(CMAKE_BUILD_TYPE "Release" CACHE STRING "CMake build configuration") 
file(REAL_PATH ${CMAKE_CURRENT_LIST_DIR}/../ PROJECT_ROOT_DIR)

include(cmake/dependencies.cmake)
ProvideLlvm()
ProvideArmGnuToolchain()
set(CMAKE_TOOLCHAIN_FILE ${CMAKE_CURRENT_LIST_DIR}/cmake/llvm_toolchain_file.cmake CACHE PATH
    "Path to the CMake's toolchain file")

project(LlvmArmBaremetal 
    VERSION 0.1.1
    LANGUAGES CXX C)

option(LLVM_BAREMETAL_ARM_BUILD_COMPILER_RT_ONLY 
    "If set to ON, will build only the compiler-rt, otherwise it will also build libc++, libc++abi and libunwind"
    OFF)
option(LLVM_BAREMETAL_ARM_INSTALL_NEWLIB "Install newlib libc and friends" ON)
option(LLVM_BAREMETAL_ARM_ENABLE_EXCEPTIONS "Enable exceptions in libc++ and libc++abi" ON)

if(LLVM_BAREMETAL_ARM_ENABLE_EXCEPTIONS)
    set(LIBCXX_ENABLE_EXCEPTIONS ON CACHE BOOL "" FORCE)
    set(LIBCXXABI_ENABLE_EXCEPTIONS ON CACHE BOOL "" FORCE)
else()
    set(LIBCXX_ENABLE_EXCEPTIONS OFF CACHE BOOL "" FORCE)
    set(LIBCXXABI_ENABLE_EXCEPTIONS OFF CACHE BOOL "" FORCE)
endif()

set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED OFF)
set(CMAKE_CXX_EXTENSIONS ON)

set(CMAKE_C_STANDARD 23)
set(CMAKE_C_STANDARD_REQUIRED OFF)
set(CMAKE_C_EXTENSIONS ON)

include(cmake/utils.cmake)
include(cmake/llvm_project.cmake)

ConfigurePackaging()
AddPackagingTarget()
ProvideLlvmProject()

EnableCompilerRt()
if(NOT LLVM_BAREMETAL_ARM_BUILD_COMPILER_RT_ONLY)
    EnableLibcxx()
    EnableLibcxxAbi()
    EnableLibunwind()
endif()

add_subdirectory(src)

if(LLVM_BAREMETAL_ARM_INSTALL_NEWLIB)
    include(cmake/newlib.cmake)
endif()
