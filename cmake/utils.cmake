function(ConfigurePackaging)

    set(CPACK_PACKAGE_NAME "LlvmArmBaremetal")
    set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "LLVM Project cross-compiled for ARM baremetal")
    set(CPACK_PACKAGE_VERSION_MAJOR ${PROJECT_VERSION_MAJOR})
    set(CPACK_PACKAGE_VERSION_MINOR ${PROJECT_VERSION_MINOR})
    set(CPACK_PACKAGE_VERSION_PATCH ${PROJECT_VERSION_PATCH})
    set(CPACK_VERBATIM_VARIABLES YES)
    set(CPACK_GENERATOR TGZ)
    set(CPACK_SYSTEM_NAME armv7em)
    set(CPACK_INCLUDE_TOPLEVEL_DIRECTORY OFF)

    set(version ${CPACK_PACKAGE_VERSION_MAJOR}.${CPACK_PACKAGE_VERSION_MINOR}.${CPACK_PACKAGE_VERSION_PATCH})
    # Save the name for other functions to utilize it, e.g. AddPackagingTarget().
    set(CPACK_PACKAGE_FILE_NAME ${CPACK_PACKAGE_NAME}-${version}-${CPACK_SYSTEM_NAME} PARENT_SCOPE)

    include(CPack)

endfunction()

function(AddPackagingTarget)

    # It assumes that the default 'cpack' invocation will create a *.tar.gz archive, with the name 
    # ${CPACK_PACKAGE_FILE_NAME}.tar.gz in the current directory, according to the config from ConfigurePackaging().
    add_custom_target(pack 
        COMMAND ${CMAKE_CPACK_COMMAND} -C $<CONFIG>
        COMMAND ${CMAKE_COMMAND} -E copy ${CPACK_PACKAGE_FILE_NAME}.tar.gz ${CPACK_PACKAGE_FILE_NAME}-$<CONFIG>.tar.gz
    )

endfunction()
