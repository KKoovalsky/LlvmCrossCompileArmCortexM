# compiler-rt, libc++, libc++abi and libunwind, cross-compiled for ARM baremetal (ARM Cortex M)

Cross-compiled and fine-tuned LLVM libraries for ARM baremetal targets. The targeted systems are 
**arm\*-none-eabi** triplets, which don't run an OS (but can run e.g. an RTOS), thus, do not support threads, 
monotonic clock, filesystem, random device etc. Those are **ARM Cortex M** MCUs.

This project can compile:

* compiler-rt
* libc++
* libc++abi
* libunwind

Exceptions are supported by default, but can be turned off to spare the final binary size.

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

## Building

Currently, by default, Ubuntu is supported for building. To tweak it for your host machine, read on.

There is one major CMake CACHE variable, which defines the target for which the library will be built:

* `LLVM_BAREMETAL_ARM_TARGET_COMPILE_FLAGS` - by default equal to: 
`-mthumb -mcpu=cortex-m4 -mfloat-abi=hard -mfpu=fpv4-sp-d16`, what, basically, means that by default ARM Cortex M4 MCU,
with floating point support, is targeted. Change it to the corresponding target architecture, you want the libs be
compiled for.

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

### Disabling exceptions

To disable exceptions, run the CMake configure and generate step, with:

* `LIBCXXABI_ENABLE_EXCEPTIONS=OFF`
* `LIBCXX_ENABLE_EXCEPTIONS=OFF`

### Building compiler-rt only

Set the cache variable `LLVM_ARM_BAREMETAL_BUILD_COMPILER_RT_ONLY` to `ON`. It is set to `OFF` by default.

### Customizing LLVM project build 

The LLVM Project is built using CMake, and the main `CMakeLists.txt` for each of the subproject has multiple
CMake options and cache variables, which affect the build. One can e.g. turn on assertions, include docs, build
experimental library, ... Check out the main `CMakeLists.txt` of the subprojects for details.

## TODO

18. Document how to use those libs from a compiler/linker command line or a `CMAKE_TOOLCHAIN_FILE`.
19. Document why `-Wl,--target2=rel` is needed. Link to ARM ABI documentation.
21. Document size of the binary similar to one compiled with ARM GNU Toolchain (a bit higher).
28. Add 'Downloads' to GitHub with the library built for `armv7em`, all three configurations, with and without 
exceptions.

14. Include appropriate `libc`, `libm`, `libnosys`, `libc-nano`, `libg`, `librdimon.a`, `librdimon_nano.a`, 
`librdimon-v2m.a`, `librdpmon.a` for specified architecture AND include headers, from the ARM GNU Toolchain.
 One needs to translate the flags from ad.12 to proper
directory in the ARM GNU Toolchain, e.g.: `thumb/v7e-m+fp/hard`. It can be done either by the user, using a CMake
option, or automatically.
Automatically it can be done with:

```
./arm-none-eabi-gcc -mthumb -mcpu=cortex-m4 -mfloat-abi=hard -mfpu=fpv4-sp-d16 -print-file-name=libc.a
```
29. Document why initfini is there and the linkage. Document how to override it.
23. Create CPack components (`cpack_add_component`): C++ libs, clang-rt, C libs from the ARM GNU Toolchain. 
Beware: `CPACK_ARCHIVE_COMPONENT_INSTALL`!
24. CPack with multiple build directories setup can be used to pack artifacts from builds for various architectures.
26. Install license of ARM GNU Toolchain when CPack-ing.
27. Support `-frtti` on demand.
28. Support Cortex-M55 half-precision.

