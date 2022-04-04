# Worklog

## 01.04.2022

Debugging cross-compiled libraries with Aura:

1. In `test_serial_logger` binary, compiled with `clang_with_cross_compiled_libs_device_toolchain.cmake` and Debug 
configuration, binary takes a lot of space because of the references to `fprintf` in:

```
_Unwind_VRS_Interpret
_Unwind_VRS_Get
_Unwind_VRS_Set
_Unwind_VRS_Pop
_ZN12_GLOBAL__N_114unwindOneFrameEjP21_Unwind_Control_BlockP15_Unwind_Context
_Unwind_RaiseException
_ZL13unwind_phase2P13unw_context_tP12unw_cursor_tP21_Unwind_Control_Blockb
_Unwind_Resume
_ZL20unwind_phase2_forcedP13unw_context_tP12unw_cursor_tP21_Unwind_Control_BlockPF19_Unwind_Reason_Codei14_Unwind_ActionPhS4_P15_Unwind_ContextPvESA_
_Unwind_GetLanguageSpecificData
_Unwind_GetRegionStart
_Unwind_DeleteException
unw_init_local
unw_get_reg
unw_set_reg
unw_get_fpreg
unw_set_fpreg
unw_step
unw_get_proc_info
unw_resume
unw_get_proc_name
unw_save_vfp_as_X
_ZN9libunwind12UnwindCursorINS_17LocalAddressSpaceENS_13Registers_armEE6getRegEi
_ZN9libunwind12UnwindCursorINS_17LocalAddressSpaceENS_13Registers_armEE6setRegEij
_ZN9libunwind12UnwindCursorINS_17LocalAddressSpaceENS_13Registers_armEE11getFloatRegEi
_ZN9libunwind12UnwindCursorINS_17LocalAddressSpaceENS_13Registers_armEE11setFloatRegEiy
_ZN9libunwind12UnwindCursorINS_17LocalAddressSpaceENS_13Registers_armEE24setInfoBasedOnIPRegisterEb
_ZN9libunwind12UnwindCursorINS_17LocalAddressSpaceENS_13Registers_armEE23getInfoFromEHABISectionEjRKNS_18UnwindInfoSectionsE
```

This was obtained with:

```
/path/to/objdump -Dr <binary> | grep 'bl.*<fprintf>' | cut -d':' -f1 | /path/to/addr2line -f -e <binary>
```

Example:

```
../common_dependencies/llvm-src/bin/llvm-objdump -Dr tests/device/test_serial_logger/test_serial_logger \
    | grep 'bl.*<fprintf>' | cut -d':' -f1 | \
    ../common_dependencies/llvm-src/bin/llvm-addr2line -f -e tests/device/test_serial_logger/test_serial_logger
```

2. Problem: `__assert_func()` is somehow pulled to Clang Release build, even though everywhere `-DNDEBUG` is used, 
what shall basically strip off `assert()` function. `nm` shows that `libc++abi` and `libunwind` reference `__assert_func()`.

Solution: it was due to `LIB*_ENABLE_ASSERTIONS` CMake option set to `ON`.

## 02.04.2022

* I have tested Aura with the cross compiled LLVM libs. Everything seems to work fine, except the exceptions. 
No exeption is properly caught. The test `logs_uncaught_exception` fails with a HardFault. I will try to resolve it.
* `build_llvm14` was built without `-fexceptions`, `-frtti`, but I rebuild it with those flags. It seems that it didn't
affect anything, though.

## 03.04.2022

* I have fixed the issues by using the `-Wl,target2=rel` flag, when cross-compiling Aura with the libraries from this
project.

## 04.04.2022

* `fprintf` optimization is irrelevant:

Irrelevant stuff from [TODOs](README.md#todo):

> 2. Force linking weak `fprintf_alternative` and `vfprintf_alternative` for each C++ library, by using `target_sources` 
> (e.g. `OBJECT` library). To do that this peace of code is needed:
> 
>       target_compile_definitions(cxx_static PRIVATE fprintf=fprintf_alternative)
>       target_compile_definitions(cxxabi_static PRIVATE fprintf=fprintf_alternative)
>       target_compile_definitions(unwind_static PRIVATE fprintf=fprintf_alternative)
>       
>       target_compile_definitions(cxx_static PRIVATE vfprintf=vfprintf_alternative)
>       target_compile_definitions(cxxabi_static PRIVATE vfprintf=vfprintf_alternative)
>       target_compile_definitions(unwind_static PRIVATE vfprintf=vfprintf_alternative)
> 
> * Document why, and how to fix it.
> * Add CMake option to control that.

Why this is irrelevant: I tested Aura Release build **without**: `fprintf` renaming to `fprintf_alternative`, nor
using weak linking to `fprintf_alternative`, and `fprintf` is not included in the binary. It means that the calls must 
have been added to the libc++ and libc++abi libraries because of the assertions enabled.
