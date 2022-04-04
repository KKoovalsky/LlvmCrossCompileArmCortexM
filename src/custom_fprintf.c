#include <stdio.h>

__attribute((weak)) int fprintf_alternative(FILE* restrict stream, const char* restrict format, ...)
{
    (void) stream;
    (void) format;
    return 0;
}

__attribute((weak)) int vfprintf_alternative(const char* restrict format, va_list vlist)
{
    (void) format;
    (void) vlist;
    return 0;
}

