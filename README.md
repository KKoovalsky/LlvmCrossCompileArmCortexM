# clang-rt, libc++, libc++abi and libunwind, cross-compiled for ARM bare-metal

Cross-compiled and fine-tuned LLVM libraries ...

## TODO

1. Add license.
4. Three build options: `Release`, `Debug`, `MinSizeRel`.
6. Document replacing LLVM, ARM GNU Toolchain and LLVM Project using `FETCH_CONTENT_SOURCE_DIR_*`.
7. Document what toolchains and versions are used.
8. According to ad.4, options we have:

* Python scripts for various builds,
* Or use CMake scripting: top-level build does nothing, the then e.g. ctest is used to build each of the configuration,
* Or use Ninja!

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
17. Document using different toolchain files.
18. Document how to use those libs from a compiler/linker command line or a `CMAKE_TOOLCHAIN_FILE`.
19. Document why `-Wl,--target2=rel` is needed. Link to ARM ABI documentation.
20. Where is `new` with `align` called from within the C++ libraries?
21. Document size of the binary similar to one compiled with ARM GNU Toolchain (a bit higher).
