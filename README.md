# compiler-rt, libc++, libc++abi and libunwind, cross-compiled for ARM baremetal (ARM Cortex M)

Cross-compiled and fine-tuned LLVM libraries for ARM baremetal targets. The targeted systems are 
**arm\*-none-eabi** triplets, which don't run an OS (but can run e.g. an RTOS), thus, do not support threads, 
monotonic clock, filesystem, random device etc. Those are **ARM Cortex M** MCUs.

This project provides:

* compiler-rt
* libc++
* libc++abi
* libunwind

The libraries are compiled in two flavors: with and without exceptions.

For `Release` and `MinSizeRel` packages, the final binary size is few kB higher than a binary compiled with ARM
GNU Toolchain.

## Supported architectures:

* Cortex M0, arch: v6-m, cpu: cortex-m0, float: [soft]
* Cortex M0+, arch: v6-m, cpu: cortex-m0plus, float: [soft]
* Cortex-M1, arch: v6-m, cpu: cortex-m1, float: [soft]
* Cortex-M3, arch: v7-m , cpu: cortex-m3, float: [soft]
* Cortex-M4, arch: v7e-m, cpu: cortex-m4, float: [fpv4-sp-d16; soft]
* Cortex-M7, arch: v7e-m, cpu: cortex-m7, float: [fpv5-sp-d16; fpv5-d16; soft]
* Cortex-M23, arch: v8-m\_baseline, cpu: cortex-m23, float: [soft]
* Cortex-M33, arch: v8-m\_mainline, cpu: cortex-m33, float: [fpv5-sp-d16; soft]
* Cortex-M55, arch: v8.1m\_mainline, cpu: cortex-m55, float: [fpv5-sp-d16; fpv5-d16; soft]

## Usage 

### What does a single Release package contain?

The intention of a single package is to have a complete header and library set, without the need for pulling 
various libraries from different places over the Internet. Single package contains all the C and C++ headers, as well
as libc and libraries needed to link C++ code.

In the [Releases](https://github.com/KKoovalsky/LlvmCrossCompileArmCortexM/releases) you can find a package compiled
for your architecture. Each package contains:

* `include` directory, and inside:
    - newlib libc headers, copied from the ARM GNU Toolchain, for the corresponding architecture.
    - `c++/v1` directory with headers from the cross-compiled LLVM libc++ library
* `lib` directory, which contains:
    - compiler-rt, libc++, libc++abi and libunwind cross-compiled LLVM libc++ libraries.
    - `libinitfini.a` which defines dummy `_init()` and `_fini()` symbols.
    - `newlib` directory, where the libc libraries and friends, are copied from the ARM GNU Toolchain, for the 
corresponding architecture.
* `licenses` directory, which contains software license for all the bundled libraries.

### Which package to choose?

The name of the package describes, what does it contain. The naming convention is:

> <Name>-<Version tag from this repo>-<Architecture and subarchitecture>-<Floating point support>-<Exception support>-<Build flavor>

* _Architecture and subarchitecture_ - arm-cortex-m4, or arm-cortex-m0plus, etc.
* _Floating point support_ - if compiled for architecture without FPU, the value is: *soft_float*. Otherwise, it's the
FPU name, e.g.: _fpv4-sp-d16_.
* _Exception support_ - whether compiled with exception support or without it.
* _Build flavor_ - may be:
    - `Release`: compiled with `-O3` and NO Debug symbols.
    - `Debug`: compiled with `-O0` and with Debug symbols.
    - `MinSizeRel`: compiled with `-Oz` and NO debug symbols.

### How to incorporate the libraries?

You can download the libraries manually, or using e.g. `FetchContent` CMake module, or any other automatic way.

When cross-compiling firmware with `clang`:

1. Add: 

```
-isystem <path_to_unpacked_lib>/include/c++/v1
-isystem <path_to_unpacked_lib>/include/ #A
```

to `clang` and `clang++` invocation. The order matters, because standard headers of libc++ use `#include_next`, to
include headers supplied with the libc.

2. Add:

```
-L<path_to_unpacked_lib>/lib/newlib #A
-L<path_to_unpacked_lib>/lib
-linitfini #A #B
-Wl,--target2=rel" #C
```

to the linker invocation.

**NOTE**:

1. If you don't want to use the bundled newlib libc, do not use the lines marked with **#A**.
2. A package contains dummy `_init()` and `_fini()` symbols, which are needed by the newlib libc (**#B**) Their bodies
are empty, but the newlib's libc links to them. Use of `_init()` and `_fini()` is obsolete in favor of init/fini arrays.
To use custom `_init()` and `_fini()`, simply, remove the line **#B**.
3. `-Wl,--target2=rel` flag (**#C**) is needed when using exceptions. Clang will create a `.got` section with exception 
handlers. Instead, we have to use the exception index table. This compile flag fixes that.

To build with another compiler, one would have to use `-nostlib` flag and link the runtime library, libc++ and others
by hand. By default, `clang` uses links to the libs from the LLVM Project, thus, `-nostdlib` is not needed when using
`clang`.

## Building from sources and installing

Currently, by default, Ubuntu is supported for building. To tweak it for your host machine, read on.

There is one major CMake CACHE variable, which defines the target for which the library will be built:

* `LLVM_BAREMETAL_ARM_TARGET_COMPILE_FLAGS` - by default equal to: 
`-mthumb -mcpu=cortex-m4 -mfloat-abi=hard -mfpu=fpv4-sp-d16`, what, basically, means that by default ARM Cortex M4 MCU,
with floating point support, is targeted. Change it to the corresponding target architecture, you want the libs be
compiled for.

newlib libc libraries (libc, libm, libg, librdimon, ...) will be installed by default, along with the headers.
This behaviour can be disabled through [tweaking](#tweaking).

### Basic single config building

Single config building is good when installing libraries built with just a single configuration.

```
mkdir build_single_config
cd build_single_config
cmake \
    -G"Unix Makefiles" \
    -DCMAKE_BUILD_TYPE=MinSizeRel \
    -DLLVM_BAREMETAL_ARM_TARGET_COMPILE_FLAGS="-mthumb -mcpu=cortex-m4 -mfloat-abi=hard -mfpu=fpv4-sp-d16" \
    ..

# Provide the path where to install the libraries
cmake -DCMAKE_INSTALL_PREFIX=/where/to/install/the/libraries ..
cmake --build . 
cmake --install . 

# One can also pack the resulting build outputs. See below to learn what is the result of this command.
cmake --build . --target pack
```

### Multi-config build

Building the library in multiple configurations is good, when bundling and deploying. This is also useful for
creating artifacts, later to upload them, or to have Release-built packages for "normal" work (aka, Release firmware),
but still have the library with Debug symbols by hand.

```
mkdir build
cd build
cmake \
    -G"Ninja Multi-Config" \
    -DCMAKE_CONFIGURATION_TYPES="Release;Debug;MinSizeRel" \
    -DLLVM_BAREMETAL_ARM_TARGET_COMPILE_FLAGS="-mthumb -mcpu=cortex-m4 -mfloat-abi=hard -mfpu=fpv4-sp-d16" \
    ..

cmake --build . --config Release
cmake --build . --config Debug
cmake --build . --config MinSizeRel

# To pack the corresponding outputs.
cmake --build . --target pack --config Release
cmake --build . --target pack --config Debug
cmake --build . --target pack --config MinSizeRel
```

### Build process explanation

By default:

1. Clang compiler, ARM GNU Toolchain and LLVM project will be downloaded (with `FetchContent`), to provide full-blown,
ready-to-go setup. Clang compiler is used as the default compiler. ARM GNU Toolchain is needed to provide cross-compiled
**newlib libc** implementation for our MCU architecture.

2. [llvm_toolchain_file.cmake](cmake/llvm_toolchain_file.cmake) will be used as the toolchain file.
To override it to use a custom toolchain file, set the `CMAKE_TOOLCHAIN_FILE` CMake cache variable. This is legit, 
because default `clang` build is assumed.

3. The `MinSizeRel` config option uses `-Oz` flag to optimize for size even more. This cache variable is set inside
the default toolchain file. If another toolchain file is used, then this `MinSizeRel` will use the standard
default value, defined by CMake vendors.

4. The `pack` target will pack all the libraries to a `tar.gz` archive, for the corresponding configuration.
The resulting archive name will be: _\<ProjectName\>-\<Version\>-\<Target\>-\<Config\>_, e.g.:

> LlvmArmBaremetal-0.1.1-armv7em-Debug.tar.gz

---

The currently used versions are:

* LLVM+Clang: 14.0.0
* LLVM Project: 14.0.0
* ARM GNU Toolchain: 10.3-2021.10

## Tweaking

Summary of CMake options and cache variables:

| Name | Default value | Description |
|------|---------------|-------------|
| LLVM_BAREMETAL_ARM_ENABLE_EXCEPTIONS | ON | Controls exceptions enabled in libc++ and libc++abi |
| LLVM_BAREMETAL_ARM_BUILD_COMPILER_RT_ONLY | OFF | When set to ON, will compile only compiler-rt, without libc++, libc++abi and libunwind |
| LLVM_BAREMETAL_ARM_INSTALL_NEWLIB | ON | Whether to install (ON), or not (OFF), newlib's libc implementation and friends, and its header files, which are bundled with the ARM GNU Toolchain, for corresponding architecture. |

### Changing paths to the toolchains and LLVM project

Since Clang compiler, ARM GNU Toolchain and LLVM project are downloaded using the `FetchContent` CMake module, we
can override them with CMake CACHE:

* `FETCH_CONTENT_SOURCE_DIR_LLVM` - controls the path to the LLVM + Clang suite.
* `FETCH_CONTENT_SOURCE_DIR_ARMGNUTOOLCHAIN` - controls the path to the ARM GNU Toolchain.
* `FETCH_CONTENT_SOURCE_DIR_LLVM_PROJECT` - controls the path to the LLVM project (compiler-rt, libc++, libc++abi,
libunwind, ... sourcers).

This can be useful when those packages already reside on your hard drive. In total they are quite heavy, so this
is a large optimization.

If your host machine is not Ubuntu 18+, you must provide proper LLVM + Clang suite for your system.

### Using custom toolchain file

The standard CMake approach applies here. Note that, when using a custom toolchain file, override the
`FETCH_CONTENT_SOURCE_DIR_LLVM` to a dummy value, to prevent CMake from downloading LLVM + Clang.

### Customizing LLVM project build 

The LLVM Project is built using CMake, and the main `CMakeLists.txt` for each of the subproject has multiple
CMake options and cache variables, which affect the build. One can e.g. turn on assertions, include docs, build
experimental library, ... Check out the main `CMakeLists.txt` of the subprojects for details.

## TODO

33. Document the helper script - inside README.md, but also (more important) inside the script itself.
29. Add 'Downloads' to GitHub with the library built for `armv7em`, all three configurations, with and without 
exceptions.

23. Create CPack components (`cpack_add_component`): C++ libs, clang-rt, C libs from the ARM GNU Toolchain. 
Beware: `CPACK_ARCHIVE_COMPONENT_INSTALL`!
24. CPack with multiple build directories setup can be used to pack artifacts from builds for various architectures.
27. Support `-frtti` on demand.
28. Support Cortex-M55 half-precision.

