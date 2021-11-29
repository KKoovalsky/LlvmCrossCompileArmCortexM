set(CLANG_COMPILER_PATH_PREFIX ${LLVM_TOOLCHAIN_PATH}/bin)

# Without that you will get linking error related to no _exit symbol when CMake tests gcc compile.
set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)

set(CMAKE_SYSTEM_NAME Generic)

set(CMAKE_C_COMPILER ${CLANG_COMPILER_PATH_PREFIX}/clang)
set(CMAKE_CXX_COMPILER ${CLANG_COMPILER_PATH_PREFIX}/clang++)
set(CMAKE_ASM_COMPILER ${CLANG_COMPILER_PATH_PREFIX}/clang)
set(CMAKE_LINKER ${CLANG_COMPILER_PATH_PREFIX}/lld)

set(CMAKE_AR ${CLANG_COMPILER_PATH_PREFIX}/llvm-ar)
set(CMAKE_OBJCOPY ${CLANG_COMPILER_PATH_PREFIX}/llvm-objcopy)
set(CMAKE_OBJCOPY_BIN ${CLANG_COMPILER_PATH_PREFIX}/llvm-objcopy)
set(CMAKE_RANLIB ${CLANG_COMPILER_PATH_PREFIX}/llvm-ranlib)
set(CMAKE_STRIP ${CLANG_COMPILER_PATH_PREFIX}/llvm-strip)
set(CMAKE_SIZE_BIN ${CLANG_COMPILER_PATH_PREFIX}/llvm-size)
set(CMAKE_NM ${CLANG_COMPILER_PATH_PREFIX}/llvm-nm)

set(gcc_c_system_include_dir "${ARM_GNU_TOOLCHAIN_PATH}/arm-none-eabi/include/")

string(CONCAT basic_flags
    " -mthumb -mcpu=cortex-m4 -mfloat-abi=hard -mfpu=fpv4-sp-d16"
    " -nodefaultlibs"
    " --sysroot=${ARM_GNU_TOOLCHAIN_SYSROOT}"
    " -fdata-sections -ffunction-sections"
    " -isystem ${gcc_c_system_include_dir}"
)

set(compile_c_flags "${basic_flags}")
set(compile_cxx_flags "${basic_flags}")

set(standard_libraries_dir "${ARM_GNU_TOOLCHAIN_PATH}/arm-none-eabi/lib/thumb/v7e-m+fp/hard/")
string(CONCAT extra_linker_flags
    " -Wl,--gc-sections"
    " -L${standard_libraries_dir}"
    " -lc -lm")

set(CMAKE_C_FLAGS_INIT "${compile_c_flags}")
set(CMAKE_CXX_FLAGS_INIT "${compile_cxx_flags}")
set(CMAKE_ASM_FLAGS_INIT  "${basic_flags}")
set(CMAKE_EXE_LINKER_FLAGS_INIT "${basic_flags} ${extra_linker_flags}")

set(CMAKE_C_COMPILER_TARGET arm-none-eabi)
set(CMAKE_CXX_COMPILER_TARGET arm-none-eabi)
set(CMAKE_ASM_COMPILER_TARGET arm-none-eabi)
