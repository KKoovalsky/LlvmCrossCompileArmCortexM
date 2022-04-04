function(UseAlternativeFprintf)

    target_compile_definitions(cxx_static PRIVATE fprintf=fprintf_alternative)
    target_compile_definitions(cxxabi_static PRIVATE fprintf=fprintf_alternative)
    target_compile_definitions(unwind_static PRIVATE fprintf=fprintf_alternative)

    target_compile_definitions(cxx_static PRIVATE vfprintf=vfprintf_alternative)
    target_compile_definitions(cxxabi_static PRIVATE vfprintf=vfprintf_alternative)
    target_compile_definitions(unwind_static PRIVATE vfprintf=vfprintf_alternative)

    add_library(fprintf_alternative OBJECT ${CMAKE_SOURCE_DIR}/src/custom_fprintf.c)
    target_sources(cxx_static PRIVATE $<TARGET_OBJECTS:fprintf_alternative>)
    target_sources(cxxabi_static PRIVATE $<TARGET_OBJECTS:fprintf_alternative>)
    target_sources(unwind_static PRIVATE $<TARGET_OBJECTS:fprintf_alternative>)

endfunction()
