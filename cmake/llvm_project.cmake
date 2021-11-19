function(EnableCompilerRt)

    set(CLANG_COMPILER_PATH_PREFIX ${LLVM_TOOLCHAIN_PATH}/bin)
    set(COMPILER_RT_BUILD_BUILTINS ON CACHE BOOL "")
    set(COMPILER_RT_BUILD_SANITIZERS OFF CACHE BOOL "")
    set(COMPILER_RT_BUILD_XRAY OFF CACHE BOOL "")
    set(COMPILER_RT_BUILD_LIBFUZZER OFF CACHE BOOL "")
    set(COMPILER_RT_BUILD_PROFILE OFF CACHE BOOL "")
    set(COMPILER_RT_BAREMETAL_BUILD ON CACHE BOOL "")
    set(COMPILER_RT_DEFAULT_TARGET_ONLY ON CACHE BOOL "")
    set(LLVM_CONFIG_PATH ${CLANG_COMPILER_PATH_PREFIX}/llvm-config CACHE PATH "")
    set(COMPILER_RT_BAREMETAL_BUILD ON CACHE BOOL "")
    set(COMPILER_RT_DEFAULT_TARGET_ONLY ON CACHE BOOL "")

    add_subdirectory(${LLVM_PROJECT_PATH}/compiler-rt)

endfunction()

function(EnableLibunwind)

    option(LIBUNWIND_ENABLE_SHARED "Build libunwind as a shared library." OFF)
    option(LIBUNWIND_ENABLE_CROSS_UNWINDING "Enable cross-platform unwinding support." ON)
    option(LIBUNWIND_ENABLE_THREADS "Build libunwind with threading support." OFF)
    option(LIBUNWIND_USE_COMPILER_RT "Use compiler-rt instead of libgcc" OFF)
    option(LIBUNWIND_INCLUDE_DOCS "Build the libunwind documentation." OFF)
    option(LIBUNWIND_INCLUDE_TESTS "Build the libunwind tests." OFF)
    option(LIBUNWIND_IS_BAREMETAL "Build libunwind for baremetal targets." ON)
    option(LIBUNWIND_REMEMBER_HEAP_ALLOC "Use heap instead of the stack for .cfi_remember_state." ON)

    # option(LIBUNWIND_USE_COMPILER_RT "Use compiler-rt instead of libgcc" OFF)

    add_subdirectory(${LLVM_PROJECT_PATH}/libunwind)

endfunction()
