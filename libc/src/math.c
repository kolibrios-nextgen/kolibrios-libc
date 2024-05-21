/*
 * SDPX-FileCopyrightText: 1994-1996 DJ Delorie
 * SPDX-FileCopyrightText: 2024 KolibriOS-NG Team
 * SPDX-License-Identifier: GPL-2.0-only
 */

#include <math.h>

double cosh(double x)
{
    const double ebig = exp(fabs(x));
    return (ebig + 1.0 / ebig) / 2.0;
}

double sinh(double x)
{
    if (x >= 0.0) {
        const double epos = exp(x);
        return (epos - 1.0 / epos) / 2.0;
    } else {
        const double eneg = exp(-x);
        return (1.0 / eneg - eneg) / 2.0;
    }
}

double frexp(double x, int *exptr)
{
    union {
        double d;
        unsigned char c[8];
    } u;

    u.d = x;
    /*
     * The format of the number is:
     * Sign, 12 exponent bits, 51 mantissa bits
     * The exponent is 1023 biased and there is an implicit zero.
     * We get the exponent from the upper bits and set the exponent
     * to 0x3fe (1022).
     */
    *exptr = (int)(((u.c[7] & 0x7f) << 4) | (u.c[6] >> 4)) - 1022;
    u.c[7] &= 0x80;
    u.c[7] |= 0x3f;
    u.c[6] &= 0x0f;
    u.c[6] |= 0xe0;
    return u.d;
}

double ldexp(double v, int e)
{
    double two = 2.0;

    if (e < 0) {
        e = -e; /* This just might overflow on two-complement machines.  */
        if (e < 0)
            return 0.0;
        while (e > 0) {
            if (e & 1)
                v /= two;
            two *= two;
            e >>= 1;
        }
    } else if (e > 0) {
        while (e > 0) {
            if (e & 1)
                v *= two;
            two *= two;
            e >>= 1;
        }
    }
    return v;
}
