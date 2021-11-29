function(EnableCompilerRt)

    set(CLANG_COMPILER_PATH_PREFIX ${LLVM_TOOLCHAIN_PATH}/bin)
    set(COMPILER_RT_BUILD_BUILTINS ON CACHE BOOL "")
    set(COMPILER_RT_BUILD_SANITIZERS OFF CACHE BOOL "")
    set(COMPILER_RT_BUILD_XRAY OFF CACHE BOOL "")
    set(COMPILER_RT_BUILD_LIBFUZZER OFF CACHE BOOL "")
    set(COMPILER_RT_BUILD_PROFILE OFF CACHE BOOL "")
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

function(EnableLibcxx)

    option(LIBCXX_ENABLE_SHARED "Build libc++ as a shared library." OFF)
    option(LIBCXX_ENABLE_EXPERIMENTAL_LIBRARY "Build libc++experimental.a" OFF)
    option(LIBCXX_ENABLE_FILESYSTEM "Build filesystem as part of the main libc++ library" OFF)
    option(LIBCXX_INCLUDE_TESTS "Build the libc++ tests." OFF)
    option(LIBCXX_ENABLE_RANDOM_DEVICE
      "Whether to include support for std::random_device in the library. Disabling
       this can be useful when building the library for platforms that don't have
       a source of randomness, such as some embedded platforms. When this is not
       supported, most of <random> will still be available, but std::random_device
       will not." OFF)
    option(LIBCXX_ENABLE_LOCALIZATION
      "Whether to include support for localization in the library. Disabling
       localization can be useful when porting to platforms that don't support
       the C locale API (e.g. embedded). When localization is not supported,
       several parts of the library will be disabled: <iostream>, <regex>, <locale>
       will be completely unusable, and other parts may be only partly available." OFF)
    option(LIBCXX_ENABLE_UNICODE
      "Whether to include support for Unicode in the library. Disabling Unicode can
       be useful when porting to platforms that don't support UTF-8 encoding (e.g.
       embedded)." OFF)
    option(LIBCXX_ENABLE_WIDE_CHARACTERS
      "Whether to include support for wide characters in the library. Disabling
       wide character support can be useful when porting to platforms that don't
       support the C functionality for wide characters. When wide characters are
       not supported, several parts of the library will be disabled, notably the
       wide character specializations of std::basic_string." ON)
    option(LIBCXX_ENABLE_INCOMPLETE_FEATURES
        "Whether to enable support for incomplete library features. Incomplete features
        are new library features under development. These features don't guarantee
        ABI stability nor the quality of completed library features. Vendors
        shipping the library may want to disable this option." OFF)

    option(LIBCXX_INCLUDE_BENCHMARKS "Build the libc++ benchmarks and their dependencies" OFF)
    option(LIBCXX_INCLUDE_DOCS "Build the libc++ documentation." OFF)
    option(LIBCXX_USE_COMPILER_RT "Use compiler-rt instead of libgcc" ON)
    option(LIBCXX_ENABLE_STATIC_ABI_LIBRARY
      "Use a static copy of the ABI library when linking libc++.
      This option cannot be used with LIBCXX_ENABLE_ABI_LINKER_SCRIPT." OFF)
    option(LIBCXX_ENABLE_THREADS "Build libc++ with support for threads." OFF)
    option(LIBCXX_ENABLE_MONOTONIC_CLOCK
      "Build libc++ with support for a monotonic clock.
      This option may only be set to OFF when LIBCXX_ENABLE_THREADS=OFF." OFF)
    option(LIBCXX_CONFIGURE_IDE "Configure libcxx for use within an IDE" OFF)

    option(LIBCXX_ENABLE_ABI_LINKER_SCRIPT "Use and install a linker script for the given ABI library" OFF)

    add_subdirectory(${LLVM_PROJECT_PATH}/libcxx libcxx)

    target_compile_definitions(cxx_static PRIVATE _LIBCPP_HAS_NO_LIBRARY_ALIGNED_ALLOCATION)

endfunction()

function(EnableLibcxxAbi)

    option(LIBCXXABI_USE_COMPILER_RT "Use compiler-rt instead of libgcc" ON)
    option(LIBCXXABI_ENABLE_THREADS "Build with threads enabled" OFF)
    option(LIBCXXABI_INCLUDE_TESTS "Generate build targets for the libc++abi unit tests." OFF)

    option(LIBCXXABI_ENABLE_SHARED "Build libc++abi as a shared library." OFF)
    option(LIBCXXABI_BAREMETAL "Build libc++abi for baremetal targets." ON)
    option(LIBCXXABI_SILENT_TERMINATE "Set this to make the terminate handler default to a silent alternative" ON)
    option(LIBCXXABI_NON_DEMANGLING_TERMINATE "Set this to make the terminate handler avoid demangling" ON)

    add_subdirectory(${LLVM_PROJECT_PATH}/libcxxabi libcxxabi)

    target_compile_definitions(cxxabi_static PRIVATE _LIBCPP_HAS_NO_LIBRARY_ALIGNED_ALLOCATION)

endfunction()
