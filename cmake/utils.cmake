function(ConfigurePackaging)

    set(CPACK_PACKAGE_NAME "LlvmArmBaremetal")
    set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "LLVM Project cross-compiled for ARM baremetal")
    set(CPACK_PACKAGE_VERSION_MAJOR ${PROJECT_VERSION_MAJOR})
    set(CPACK_PACKAGE_VERSION_MINOR ${PROJECT_VERSION_MINOR})
    set(CPACK_PACKAGE_VERSION_PATCH ${PROJECT_VERSION_PATCH})
    set(CPACK_VERBATIM_VARIABLES YES)
    set(CPACK_GENERATOR TGZ)
    set(CPACK_SYSTEM_NAME arm)
    set(CPACK_INCLUDE_TOPLEVEL_DIRECTORY OFF)

    set(version ${CPACK_PACKAGE_VERSION_MAJOR}.${CPACK_PACKAGE_VERSION_MINOR}.${CPACK_PACKAGE_VERSION_PATCH})
    # Save the name for other functions to utilize it, e.g. AddPackagingTarget().
    set(CPACK_PACKAGE_FILE_NAME ${CPACK_PACKAGE_NAME}-${version}-${CPACK_SYSTEM_NAME} PARENT_SCOPE)

    include(CPack)

endfunction()

function(AddPackagingTarget)

    GetSubarchitectureAndFpu(sub_and_fpu)

    if(LLVM_BAREMETAL_ARM_ENABLE_EXCEPTIONS)
        set(exceptions_str "-exceptions")
    else()
        set(exceptions_str "-no_exceptions")
    endif()

    # It assumes that the default 'cpack' invocation will create a *.tar.gz archive, with the name 
    # ${CPACK_PACKAGE_FILE_NAME}.tar.gz in the current directory, according to the config from ConfigurePackaging().

    # We could use the CPACK_POST_BUILD_SCRIPT to accomplish the renaming, but in multi-config builds, there is no
    # way to determine the current config, to append it to the name.
    add_custom_target(pack 
        COMMAND ${CMAKE_CPACK_COMMAND} -C $<CONFIG>
        COMMAND ${CMAKE_COMMAND} -E copy 
            ${CPACK_PACKAGE_FILE_NAME}.tar.gz
            ${CPACK_PACKAGE_FILE_NAME}-${sub_and_fpu}${exceptions_str}-$<CONFIG>.tar.gz
    )

endfunction()


function(GetSubarchitectureAndFpu result_out_var)

    string(FIND ${LLVM_BAREMETAL_ARM_TARGET_COMPILE_FLAGS} "cortex" cpu_begin)
    if(cpu_begin LESS 0)
        set(${result_out_var} "sub_unknown" PARENT_SCOPE)
        return()
    endif()

    # Get 'cortex-*' string from the compiler flags.
    string(SUBSTRING ${LLVM_BAREMETAL_ARM_TARGET_COMPILE_FLAGS} ${cpu_begin} -1 cpu)
    string(FIND ${cpu} " " cpu_end)
    string(SUBSTRING ${cpu} 0 ${cpu_end} cpu)

    string(FIND ${LLVM_BAREMETAL_ARM_TARGET_COMPILE_FLAGS} "fpu" fpu_begin)
    if(fpu_begin LESS 0)
        set(${result_out_var} "${cpu}-soft_float" PARENT_SCOPE)
        return()
    endif()

    # Set index after "fpu=" string
    math(EXPR fpu_begin "${fpu_begin} + 4" OUTPUT_FORMAT DECIMAL)
    string(SUBSTRING ${LLVM_BAREMETAL_ARM_TARGET_COMPILE_FLAGS} ${fpu_begin} -1 fpu)

    # '-mfpu' might not be at the end of the sting with the compilation flags.
    string(FIND ${fpu} " " fpu_end)
    if(fpu_end GREATER 0)
        string(SUBSTRING ${fpu} 0 ${fpu_end} fpu)
    endif()

    set(${result_out_var} "${cpu}-${fpu}" PARENT_SCOPE)

endfunction()
