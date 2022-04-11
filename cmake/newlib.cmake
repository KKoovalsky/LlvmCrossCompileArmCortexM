################################################################################
# Functions
################################################################################
function(InstallNewlib)

    separate_arguments(get_libc_location_command NATIVE_COMMAND 
        "${ARM_GNU_TOOLCHAIN_PATH}/bin/arm-none-eabi-gcc ${LLVM_BAREMETAL_ARM_TARGET_COMPILE_FLAGS} -print-file-name=libc.a")
    execute_process(COMMAND ${get_libc_location_command} OUTPUT_VARIABLE path_to_libc)
   
    get_filename_component(newlib_dir ${path_to_libc} DIRECTORY)
    cmake_path(NORMAL_PATH newlib_dir)
    
    set(newlib_libs
        ${newlib_dir}/libc.a
        ${newlib_dir}/libc_nano.a
        ${newlib_dir}/libg.a
        ${newlib_dir}/libg_nano.a
        ${newlib_dir}/libm.a
        ${newlib_dir}/libnosys.a
        ${newlib_dir}/librdimon.a
        ${newlib_dir}/librdimon_nano.a
        ${newlib_dir}/librdimon-v2m.a
        ${newlib_dir}/librdpmon.a
    )

    install(FILES ${newlib_libs} DESTINATION lib/newlib)
    install(DIRECTORY ${ARM_GNU_TOOLCHAIN_PATH}/arm-none-eabi/include DESTINATION "."
        PATTERN "c++/*" EXCLUDE)
    install(FILES ${ARM_GNU_TOOLCHAIN_PATH}/share/doc/gcc-arm-none-eabi/license.txt 
        DESTINATION licenses/gcc-arm-none-eabi)

endfunction()

################################################################################
# Main script
################################################################################
InstallNewlib()
