function(ProvideLlvm)

    include(FetchContent)

    FetchContent_Declare(
        Llvm
        URL https://github.com/llvm/llvm-project/releases/download/llvmorg-13.0.0/clang+llvm-13.0.0-x86_64-linux-gnu-ubuntu-20.04.tar.xz
        URL_HASH SHA256=2c2fb857af97f41a5032e9ecadf7f78d3eff389a5cd3c9ec620d24f134ceb3c8
    )

    FetchContent_MakeAvailable(Llvm)

    FetchContent_GetProperties(Llvm SOURCE_DIR LLVM_TOOLCHAIN_SOURCE_DIR)

    set(LLVM_TOOLCHAIN_PATH "${LLVM_TOOLCHAIN_SOURCE_DIR}" CACHE PATH "Path to the LLVM toolchain") 

endfunction()

function(ProvideArmGnuToolchain)

    include(FetchContent)

    FetchContent_Declare(
        ArmGnuToolchain
        URL https://developer.arm.com/-/media/Files/downloads/gnu-rm/10.3-2021.10/gcc-arm-none-eabi-10.3-2021.10-x86_64-linux.tar.bz2
        URL_HASH MD5=2383e4eb4ea23f248d33adc70dc3227e
    )

    FetchContent_MakeAvailable(ArmGnuToolchain)

    FetchContent_GetProperties(ArmGnuToolchain SOURCE_DIR ARM_GNU_TOOLCHAIN_SOURCE_DIR)

    set(ARM_GNU_TOOLCHAIN_PATH "${ARM_GNU_TOOLCHAIN_SOURCE_DIR}" CACHE PATH "Path to the ARM GNU toolchain")

endfunction()

function(ProvideLlvmProject)

    include(FetchContent)

    FetchContent_Declare(
        LlvmProject
        GIT_REPOSITORY  https://github.com/llvm/llvm-project.git
        GIT_TAG         1ed5a90f70eb04997a27026dfc2d9cae1d8cfa75
    )

    FetchContent_MakeAvailable(LlvmProject)

    FetchContent_GetProperties(LlvmProject SOURCE_DIR llvm_project_source_dir)

    set(LLVM_PROJECT_PATH "${llvm_project_source_dir}" CACHE PATH "Path to the LLVM project")

endfunction()
