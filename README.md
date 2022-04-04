# clang-rt, libc++, libc++abi and libunwind, cross-compiled for ARM bare-metal

Cross-compiled and fine-tuned LLVM libraries ...

## Building

Currently, by default, Ubuntu is supported for building. To tweak it for your host machine, read on to tweak the build.

Building the library in multiple configurations is recommended, thus, use Ninja-Multi Config CMake generator:

```
mkdir build
cd build
cmake -G"Ninja Multi-Config" -DCMAKE_CONFIGURATION_TYPES="Release;Debug;MinSizeRel" ..
cmake --build . --config Release
cmake --build . --config Debug
cmake --build . --config MinSizeRel
```

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

## TODO

1. Add license - research licensing when downloading LLVM Project as a dependency.
7. Document what toolchains and versions are used.
9. Add option `BUILD_COMPILER_RT_ONLY` to disable C++ libraries building.
10. Build without exceptions, and support every build option for ad.4.
11. Document that CMake options from the LLVM project may be overriden.
12. This set of options: `-mthumb -mcpu=cortex-m4 -mfloat-abi=hard -mfpu=fpv4-sp-d16`, shall be a CMake cache variable.
13. Pack all includes to `include` and libs to `lib` as an arifact. Use `CPack` for that?
14. Include appropriate `libc`, `libm`, `libnosys`, `libc-nano`, `libg`, `librdimon.a`, `librdimon_nano.a`, 
`librdimon-v2m.a`, `librdpmon.a` for specified architecture AND include headers, from the ARM GNU Toolchain.
 One needs to translate the flags from ad.12 to proper
directory in the ARM GNU Toolchain, e.g.: `thumb/v7e-m+fp/hard`. It can be done either by the user, using a CMake
option, or automatically.
15. `CMAKE_*_COMPILER_TARGET` must also be changed accordingly.
16. Implement weak `posix_memalign` or `new/delete` with align parameter.
18. Document how to use those libs from a compiler/linker command line or a `CMAKE_TOOLCHAIN_FILE`.
19. Document why `-Wl,--target2=rel` is needed. Link to ARM ABI documentation.
20. Where is `new` with `align` called from within the C++ libraries?
21. Document size of the binary similar to one compiled with ARM GNU Toolchain (a bit higher).
22. Find a way to override `CPACK_SYSTEM_NAME` from the target architecture, uses 'Generic' even when changing
`CPACK_SYSTEM_NAME`. Create default `CPACK_*` config.
