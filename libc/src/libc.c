/*
 * Copyright (C) KolibriOS team 2024. All rights reserved.
 * Distributed under terms of the GNU General Public License
 */

static int __errno;

#include <setjmp.h>
#include <stddef.h>
#include <sys/ksys.h>

#include "ctype.c"
#include "string.c"
#include "stdlib.c"

#include "libc_init.c"

__asm__(
    ".include \"setjmp.s\"\n\t"
    ".include \"string.s\"\n\t"
);

#include "export.c"
