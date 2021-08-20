module mpdec.mpdec;

import std.stdio;
import core.stdc.stdint;
import core.stdc.stdlib;

// This a D translation of the original C header for libmpdec (mpdecimal.h)
// following the guidelines at https://dlang.org/spec/interfaceToC.html 
// written by Pablo De Nápoli.

// The copyright notice of the original sotware is the following:

/*
 * Copyright (c) 2008-2016 Stefan Krah. All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 */

// (this modified version is distributed under the same conditions).

extern (C)
{
	char *mpd_version();

/******************************************************************************/
/*                              Configuration                                 */
/******************************************************************************/

// We use the 64 bit version

	/* types for modular and base arithmetic */

	const MPD_UINT_MAX = UINT64_MAX;
	const MPD_BITS_PER_UINT = 64;
	alias mpd_uint_t=uint64_t ;  /* unsigned mod type */

	const MPD_SIZE_MAX=SIZE_MAX;
	alias mpd_size_t=size_t ; /* unsigned size type */

	/* type for exp, digits, len, prec */
	const MPD_SSIZE_MAX=INT64_MAX;
	const MPD_SSIZE_MIN=INT64_MIN;
	alias mpd_ssize_t=int64_t;
	alias _mpd_strtossize=strtoll;


/* decimal arithmetic */
const MPD_RADIX =10000000000000000000;  /* 10**19 */
const MPD_RDIGITS= 19;
const MPD_MAX_POW10=19;
const MPD_EXPDIGITS=19;  /* MPD_EXPDIGITS <= MPD_RDIGITS+1 */

const MPD_MAXTRANSFORM_2N=4294967296;      /* 2**32 */
const MPD_MAX_PREC=999999999999999999;
const MPD_MAX_PREC_LOG2=64;
const MPD_ELIMIT=1000000000000000000;
const MPD_MAX_EMAX=999999999999999999;    /* ELIMIT-1 */
const MPD_MIN_EMIN=(-999999999999999999);  /* -EMAX */
const MPD_MIN_ETINY=(MPD_MIN_EMIN-(MPD_MAX_PREC-1));
const MPD_EXP_INF=2000000000000000001;
const MPD_EXP_CLAMP=(-4000000000000000001);
const MPD_MAXIMPORT=105263157894736842L; /* ceil((2*MPD_MAX_PREC)/MPD_RDIGITS) */

/******************************************************************************/
/*                                Context                                     */
/******************************************************************************/

enum {
    MPD_ROUND_UP,          /* round away from 0               */
    MPD_ROUND_DOWN,        /* round toward 0 (truncate)       */
    MPD_ROUND_CEILING,     /* round toward +infinity          */
    MPD_ROUND_FLOOR,       /* round toward -infinity          */
    MPD_ROUND_HALF_UP,     /* 0.5 is rounded up               */
    MPD_ROUND_HALF_DOWN,   /* 0.5 is rounded down             */
    MPD_ROUND_HALF_EVEN,   /* 0.5 is rounded to even          */
    MPD_ROUND_05UP,        /* round zero or five away from 0  */
    MPD_ROUND_TRUNC,       /* truncate, but set infinity      */
    MPD_ROUND_GUARD
};

enum { MPD_CLAMP_DEFAULT, MPD_CLAMP_IEEE_754, MPD_CLAMP_GUARD };

extern const char *[MPD_ROUND_GUARD]mpd_round_string;
extern const char *[MPD_CLAMP_GUARD]mpd_clamp_string;

	struct mpd_context_t {
    mpd_ssize_t prec;   /* precision */
    mpd_ssize_t emax;   /* max positive exp */
    mpd_ssize_t emin;   /* min negative exp */
    uint32_t traps;     /* status events that should be trapped */
    uint32_t status;    /* status flags */
    uint32_t newtrap;   /* set by mpd_addstatus_raise() */
    int      round;     /* rounding mode */
    int      clamp;     /* clamp mode */
    int      allcr;     /* all functions correctly rounded */
	} ;

	void mpd_dflt_traphandler(mpd_context_t *);

void mpd_setminalloc(mpd_ssize_t n);
void mpd_init(mpd_context_t *ctx, mpd_ssize_t prec);

void mpd_maxcontext(mpd_context_t *ctx);
void mpd_defaultcontext(mpd_context_t *ctx);
void mpd_basiccontext(mpd_context_t *ctx);
int mpd_ieee_context(mpd_context_t *ctx, int bits);

mpd_ssize_t mpd_getprec(const mpd_context_t *ctx);
mpd_ssize_t mpd_getemax(const mpd_context_t *ctx);
mpd_ssize_t mpd_getemin(const mpd_context_t *ctx);
int mpd_getround(const mpd_context_t *ctx);
uint32_t mpd_gettraps(const mpd_context_t *ctx);
uint32_t mpd_getstatus(const mpd_context_t *ctx);
int mpd_getclamp(const mpd_context_t *ctx);
int mpd_getcr(const mpd_context_t *ctx);

int mpd_qsetprec(mpd_context_t *ctx, mpd_ssize_t prec);
int mpd_qsetemax(mpd_context_t *ctx, mpd_ssize_t emax);
int mpd_qsetemin(mpd_context_t *ctx, mpd_ssize_t emin);
int mpd_qsetround(mpd_context_t *ctx, int newround);
int mpd_qsettraps(mpd_context_t *ctx, uint32_t flags);
int mpd_qsetstatus(mpd_context_t *ctx, uint32_t flags);
int mpd_qsetclamp(mpd_context_t *ctx, int c);
int mpd_qsetcr(mpd_context_t *ctx, int c);
void mpd_addstatus_raise(mpd_context_t *ctx, uint32_t flags);


/******************************************************************************/
/*                           Decimal Arithmetic                               */
/******************************************************************************/


/* mpd_t flags */
const MPD_POS=                 	cast(uint8_t)0;
const MPD_NEG=                	cast(uint8_t)1;
const MPD_INF=                 	cast(uint8_t)2;
const MPD_NAN=                  cast(uint8_t)4;
const MPD_SNAN=                 cast(uint8_t)8;
const MPD_SPECIAL=  (MPD_INF|MPD_NAN|MPD_SNAN);
const MPD_STATIC=              	cast(uint8_t)16;
const MPD_STATIC_DATA=         	cast(uint8_t)32;
const MPD_SHARED_DATA=          cast(uint8_t)64;
const MPD_CONST_DATA=           cast(uint8_t)128;
const MPD_DATAFLAGS=  (MPD_STATIC_DATA|MPD_SHARED_DATA|MPD_CONST_DATA);


/* mpd_t */
struct mpd_t {
    uint8_t flags;
    mpd_ssize_t exp;
    mpd_ssize_t digits;
    mpd_ssize_t len;
    mpd_ssize_t alloc;
    mpd_uint_t *data;
};

alias uchar = char; /* chars are unsigned in D */


/******************************************************************************/
/*                       Quiet, thread-safe functions                         */
/******************************************************************************/

/* format specification */
struct mpd_spec_t {
    mpd_ssize_t min_width; /* minimum field width */
    mpd_ssize_t prec;      /* fraction digits or significant digits */
    char type;             /* conversion specifier */
    char alignment;        /* alignment : the original name was align but it is a reserved keyword in D */
    char sign;             /* sign printing/alignment */
    char[5] fill;          /* fill character */
    const char *dot;       /* decimal point */
    const char *sep;       /* thousands separator */
    const char *grouping;  /* grouping of digits */
};

/* output to a string */
char *mpd_to_sci(const mpd_t *dec, int fmt);
char *mpd_to_eng(const mpd_t *dec, int fmt);
mpd_ssize_t mpd_to_sci_size(char **res, const mpd_t *dec, int fmt);
mpd_ssize_t mpd_to_eng_size(char **res, const mpd_t *dec, int fmt);
int mpd_validate_lconv(mpd_spec_t *spec);
int mpd_parse_fmt_str(mpd_spec_t *spec, const char *fmt, int caps);
char *mpd_qformat_spec(const mpd_t *dec, const mpd_spec_t *spec, const mpd_context_t *ctx, uint32_t *status);
char *mpd_qformat(const mpd_t *dec, const char *fmt, const mpd_context_t *ctx, uint32_t *status);

const MPD_NUM_FLAGS=15;
const MPD_MAX_FLAG_STRING=208;
const MPD_MAX_FLAG_LIST = MPD_MAX_FLAG_STRING+18;
const MPD_MAX_SIGNAL_LIST=12;
int mpd_snprint_flags(char *dest, int nmemb, uint32_t flags);
int mpd_lsnprint_flags(char *dest, int nmemb, uint32_t flags, const char*[] flag_string);
int mpd_lsnprint_signals(char *dest, int nmemb, uint32_t flags, const char*[] flag_string);

/* output to a file */
void mpd_fprint(FILE *file, const mpd_t *dec);
void mpd_print(const mpd_t *dec);

/* assignment from a string */
void mpd_qset_string(mpd_t *dec, const char *s, const mpd_context_t *ctx, uint32_t *status);

/* set to NaN with error flags */
void mpd_seterror(mpd_t *result, uint32_t flags, uint32_t *status);
/* set a special with sign and type */
void mpd_setspecial(mpd_t *dec, uint8_t sign, uint8_t type);
/* set coefficient to zero or all nines */
void mpd_zerocoeff(mpd_t *result);
void mpd_qmaxcoeff(mpd_t *result, const mpd_context_t *ctx, uint32_t *status);

/* quietly assign a C integer type to an mpd_t */
void mpd_qset_ssize(mpd_t *result, mpd_ssize_t a, const mpd_context_t *ctx, uint32_t *status);
void mpd_qset_i32(mpd_t *result, int32_t a, const mpd_context_t *ctx, uint32_t *status);
void mpd_qset_uint(mpd_t *result, mpd_uint_t a, const mpd_context_t *ctx, uint32_t *status);
void mpd_qset_u32(mpd_t *result, uint32_t a, const mpd_context_t *ctx, uint32_t *status);
void mpd_qset_i64(mpd_t *result, int64_t a, const mpd_context_t *ctx, uint32_t *status);
void mpd_qset_u64(mpd_t *result, uint64_t a, const mpd_context_t *ctx, uint32_t *status);

/* quietly assign a C integer type to an mpd_t with a static coefficient */
void mpd_qsset_ssize(mpd_t *result, mpd_ssize_t a, const mpd_context_t *ctx, uint32_t *status);
void mpd_qsset_i32(mpd_t *result, int32_t a, const mpd_context_t *ctx, uint32_t *status);
void mpd_qsset_uint(mpd_t *result, mpd_uint_t a, const mpd_context_t *ctx, uint32_t *status);
void mpd_qsset_u32(mpd_t *result, uint32_t a, const mpd_context_t *ctx, uint32_t *status);

/* quietly get a C integer type from an mpd_t */
mpd_ssize_t mpd_qget_ssize(const mpd_t *dec, uint32_t *status);
mpd_uint_t mpd_qget_uint(const mpd_t *dec, uint32_t *status);
mpd_uint_t mpd_qabs_uint(const mpd_t *dec, uint32_t *status);

int32_t mpd_qget_i32(const mpd_t *dec, uint32_t *status);
uint32_t mpd_qget_u32(const mpd_t *dec, uint32_t *status);
int64_t mpd_qget_i64(const mpd_t *dec, uint32_t *status);
uint64_t mpd_qget_u64(const mpd_t *dec, uint32_t *status);

/* quiet functions */
int mpd_qcheck_nan(mpd_t *nanresult, const mpd_t *a, const mpd_context_t *ctx, uint32_t *status);
int mpd_qcheck_nans(mpd_t *nanresult, const mpd_t *a, const mpd_t *b, const mpd_context_t *ctx, uint32_t *status);
void mpd_qfinalize(mpd_t *result, const mpd_context_t *ctx, uint32_t *status);

char *mpd_class(const mpd_t *a, const mpd_context_t *ctx);

int mpd_qcopy(mpd_t *result, const mpd_t *a,  uint32_t *status);
mpd_t *mpd_qncopy(const mpd_t *a);
int mpd_qcopy_abs(mpd_t *result, const mpd_t *a, uint32_t *status);
int mpd_qcopy_negate(mpd_t *result, const mpd_t *a, uint32_t *status);
int mpd_qcopy_sign(mpd_t *result, const mpd_t *a, const mpd_t *b, uint32_t *status);

void mpd_qand(mpd_t *result, const mpd_t *a, const mpd_t *b, const mpd_context_t *ctx, uint32_t *status);
void mpd_qinvert(mpd_t *result, const mpd_t *a, const mpd_context_t *ctx, uint32_t *status);
void mpd_qlogb(mpd_t *result, const mpd_t *a, const mpd_context_t *ctx, uint32_t *status);
void mpd_qor(mpd_t *result, const mpd_t *a, const mpd_t *b, const mpd_context_t *ctx, uint32_t *status);
void mpd_qscaleb(mpd_t *result, const mpd_t *a, const mpd_t *b, const mpd_context_t *ctx, uint32_t *status);
void mpd_qxor(mpd_t *result, const mpd_t *a, const mpd_t *b, const mpd_context_t *ctx, uint32_t *status);
int mpd_same_quantum(const mpd_t *a, const mpd_t *b);

void mpd_qrotate(mpd_t *result, const mpd_t *a, const mpd_t *b, const mpd_context_t *ctx, uint32_t *status);
int mpd_qshiftl(mpd_t *result, const mpd_t *a, mpd_ssize_t n, uint32_t *status);
mpd_uint_t mpd_qshiftr(mpd_t *result, const mpd_t *a, mpd_ssize_t n, uint32_t *status);
mpd_uint_t mpd_qshiftr_inplace(mpd_t *result, mpd_ssize_t n);
void mpd_qshift(mpd_t *result, const mpd_t *a, const mpd_t *b, const mpd_context_t *ctx, uint32_t *status);
void mpd_qshiftn(mpd_t *result, const mpd_t *a, mpd_ssize_t n, const mpd_context_t *ctx, uint32_t *status);

int mpd_qcmp(const mpd_t *a, const mpd_t *b, uint32_t *status);
int mpd_qcompare(mpd_t *result, const mpd_t *a, const mpd_t *b, const mpd_context_t *ctx, uint32_t *status);
int mpd_qcompare_signal(mpd_t *result, const mpd_t *a, const mpd_t *b, const mpd_context_t *ctx, uint32_t *status);
int mpd_cmp_total(const mpd_t *a, const mpd_t *b);
int mpd_cmp_total_mag(const mpd_t *a, const mpd_t *b);
int mpd_compare_total(mpd_t *result, const mpd_t *a, const mpd_t *b);
int mpd_compare_total_mag(mpd_t *result, const mpd_t *a, const mpd_t *b);

void mpd_qround_to_intx(mpd_t *result, const mpd_t *a, const mpd_context_t *ctx, uint32_t *status);
void mpd_qround_to_int(mpd_t *result, const mpd_t *a, const mpd_context_t *ctx, uint32_t *status);
void mpd_qtrunc(mpd_t *result, const mpd_t *a, const mpd_context_t *ctx, uint32_t *status);
void mpd_qfloor(mpd_t *result, const mpd_t *a, const mpd_context_t *ctx, uint32_t *status);
void mpd_qceil(mpd_t *result, const mpd_t *a, const mpd_context_t *ctx, uint32_t *status);

void mpd_qabs(mpd_t *result, const mpd_t *a, const mpd_context_t *ctx, uint32_t *status);
void mpd_qmax(mpd_t *result, const mpd_t *a, const mpd_t *b, const mpd_context_t *ctx, uint32_t *status);
void mpd_qmax_mag(mpd_t *result, const mpd_t *a, const mpd_t *b, const mpd_context_t *ctx, uint32_t *status);
void mpd_qmin(mpd_t *result, const mpd_t *a, const mpd_t *b, const mpd_context_t *ctx, uint32_t *status);
void mpd_qmin_mag(mpd_t *result, const mpd_t *a, const mpd_t *b, const mpd_context_t *ctx, uint32_t *status);
void mpd_qminus(mpd_t *result, const mpd_t *a, const mpd_context_t *ctx, uint32_t *status);
void mpd_qplus(mpd_t *result, const mpd_t *a, const mpd_context_t *ctx, uint32_t *status);
void mpd_qnext_minus(mpd_t *result, const mpd_t *a, const mpd_context_t *ctx, uint32_t *status);
void mpd_qnext_plus(mpd_t *result, const mpd_t *a, const mpd_context_t *ctx, uint32_t *status);
void mpd_qnext_toward(mpd_t *result, const mpd_t *a, const mpd_t *b, const mpd_context_t *ctx, uint32_t *status);
void mpd_qquantize(mpd_t *result, const mpd_t *a, const mpd_t *b, const mpd_context_t *ctx, uint32_t *status);
void mpd_qrescale(mpd_t *result, const mpd_t *a, mpd_ssize_t exp, const mpd_context_t *ctx, uint32_t *status);
void mpd_qrescale_fmt(mpd_t *result, const mpd_t *a, mpd_ssize_t exp, const mpd_context_t *ctx, uint32_t *status);
void mpd_qreduce(mpd_t *result, const mpd_t *a, const mpd_context_t *ctx, uint32_t *status);
void mpd_qadd(mpd_t *result, const mpd_t *a, const mpd_t *b, const mpd_context_t *ctx, uint32_t *status);
void mpd_qadd_ssize(mpd_t *result, const mpd_t *a, mpd_ssize_t b, const mpd_context_t *ctx, uint32_t *status);
void mpd_qadd_i32(mpd_t *result, const mpd_t *a, int32_t b, const mpd_context_t *ctx, uint32_t *status);
void mpd_qadd_uint(mpd_t *result, const mpd_t *a, mpd_uint_t b, const mpd_context_t *ctx, uint32_t *status);
void mpd_qadd_u32(mpd_t *result, const mpd_t *a, uint32_t b, const mpd_context_t *ctx, uint32_t *status);
void mpd_qsub(mpd_t *result, const mpd_t *a, const mpd_t *b, const mpd_context_t *ctx, uint32_t *status);
void mpd_qsub_ssize(mpd_t *result, const mpd_t *a, mpd_ssize_t b, const mpd_context_t *ctx, uint32_t *status);
void mpd_qsub_i32(mpd_t *result, const mpd_t *a, int32_t b, const mpd_context_t *ctx, uint32_t *status);
void mpd_qsub_uint(mpd_t *result, const mpd_t *a, mpd_uint_t b, const mpd_context_t *ctx, uint32_t *status);
void mpd_qsub_u32(mpd_t *result, const mpd_t *a, uint32_t b, const mpd_context_t *ctx, uint32_t *status);
void mpd_qmul(mpd_t *result, const mpd_t *a, const mpd_t *b, const mpd_context_t *ctx, uint32_t *status);
void mpd_qmul_ssize(mpd_t *result, const mpd_t *a, mpd_ssize_t b, const mpd_context_t *ctx, uint32_t *status);
void mpd_qmul_i32(mpd_t *result, const mpd_t *a, int32_t b, const mpd_context_t *ctx, uint32_t *status);
void mpd_qmul_uint(mpd_t *result, const mpd_t *a, mpd_uint_t b, const mpd_context_t *ctx, uint32_t *status);
void mpd_qmul_u32(mpd_t *result, const mpd_t *a, uint32_t b, const mpd_context_t *ctx, uint32_t *status);
void mpd_qfma(mpd_t *result, const mpd_t *a, const mpd_t *b, const mpd_t *c, const mpd_context_t *ctx, uint32_t *status);
void mpd_qdiv(mpd_t *q, const mpd_t *a, const mpd_t *b, const mpd_context_t *ctx, uint32_t *status);
void mpd_qdiv_ssize(mpd_t *result, const mpd_t *a, mpd_ssize_t b, const mpd_context_t *ctx, uint32_t *status);
void mpd_qdiv_i32(mpd_t *result, const mpd_t *a, int32_t b, const mpd_context_t *ctx, uint32_t *status);
void mpd_qdiv_uint(mpd_t *result, const mpd_t *a, mpd_uint_t b, const mpd_context_t *ctx, uint32_t *status);
void mpd_qdiv_u32(mpd_t *result, const mpd_t *a, uint32_t b, const mpd_context_t *ctx, uint32_t *status);
void mpd_qdivint(mpd_t *q, const mpd_t *a, const mpd_t *b, const mpd_context_t *ctx, uint32_t *status);
void mpd_qrem(mpd_t *r, const mpd_t *a, const mpd_t *b, const mpd_context_t *ctx, uint32_t *status);
void mpd_qrem_near(mpd_t *r, const mpd_t *a, const mpd_t *b, const mpd_context_t *ctx, uint32_t *status);
void mpd_qdivmod(mpd_t *q, mpd_t *r, const mpd_t *a, const mpd_t *b, const mpd_context_t *ctx, uint32_t *status);
void mpd_qpow(mpd_t *result, const mpd_t *base, const mpd_t *exp, const mpd_context_t *ctx, uint32_t *status);
void mpd_qpowmod(mpd_t *result, const mpd_t *base, const mpd_t *exp, const mpd_t *mod, const mpd_context_t *ctx, uint32_t *status);
void mpd_qexp(mpd_t *result, const mpd_t *a, const mpd_context_t *ctx, uint32_t *status);
void mpd_qln10(mpd_t *result, mpd_ssize_t prec, uint32_t *status);
void mpd_qln(mpd_t *result, const mpd_t *a, const mpd_context_t *ctx, uint32_t *status);
void mpd_qlog10(mpd_t *result, const mpd_t *a, const mpd_context_t *ctx, uint32_t *status);
void mpd_qsqrt(mpd_t *result, const mpd_t *a, const mpd_context_t *ctx, uint32_t *status);
void mpd_qinvroot(mpd_t *result, const mpd_t *a, const mpd_context_t *ctx, uint32_t *status);

void mpd_qadd_i64(mpd_t *result, const mpd_t *a, int64_t b, const mpd_context_t *ctx, uint32_t *status);
void mpd_qadd_u64(mpd_t *result, const mpd_t *a, uint64_t b, const mpd_context_t *ctx, uint32_t *status);
void mpd_qsub_i64(mpd_t *result, const mpd_t *a, int64_t b, const mpd_context_t *ctx, uint32_t *status);
void mpd_qsub_u64(mpd_t *result, const mpd_t *a, uint64_t b, const mpd_context_t *ctx, uint32_t *status);
void mpd_qmul_i64(mpd_t *result, const mpd_t *a, int64_t b, const mpd_context_t *ctx, uint32_t *status);
void mpd_qmul_u64(mpd_t *result, const mpd_t *a, uint64_t b, const mpd_context_t *ctx, uint32_t *status);
void mpd_qdiv_i64(mpd_t *result, const mpd_t *a, int64_t b, const mpd_context_t *ctx, uint32_t *status);
void mpd_qdiv_u64(mpd_t *result, const mpd_t *a, uint64_t b, const mpd_context_t *ctx, uint32_t *status);

size_t mpd_sizeinbase(const mpd_t *a, uint32_t base);
void mpd_qimport_u16(mpd_t *result, const uint16_t *srcdata, size_t srclen,
                     uint8_t srcsign, uint32_t srcbase,
                     const mpd_context_t *ctx, uint32_t *status);
void mpd_qimport_u32(mpd_t *result, const uint32_t *srcdata, size_t srclen,
                     uint8_t srcsign, uint32_t srcbase,
                     const mpd_context_t *ctx, uint32_t *status);
size_t mpd_qexport_u16(uint16_t **rdata, size_t rlen, uint32_t base,
                       const mpd_t *src, uint32_t *status);
size_t mpd_qexport_u32(uint32_t **rdata, size_t rlen, uint32_t base,
                       const mpd_t *src, uint32_t *status);


/******************************************************************************/
/*                           Signalling functions                             */
/******************************************************************************/


char *mpd_format(const mpd_t *dec, const char *fmt, mpd_context_t *ctx);
void mpd_import_u16(mpd_t *result, const uint16_t *srcdata, size_t srclen, uint8_t srcsign, uint32_t base, mpd_context_t *ctx);
void mpd_import_u32(mpd_t *result, const uint32_t *srcdata, size_t srclen, uint8_t srcsign, uint32_t base, mpd_context_t *ctx);
size_t mpd_export_u16(uint16_t **rdata, size_t rlen, uint32_t base, const mpd_t *src, mpd_context_t *ctx);
size_t mpd_export_u32(uint32_t **rdata, size_t rlen, uint32_t base, const mpd_t *src, mpd_context_t *ctx);
void mpd_finalize(mpd_t *result, mpd_context_t *ctx);
int mpd_check_nan(mpd_t *result, const mpd_t *a, mpd_context_t *ctx);
int mpd_check_nans(mpd_t *result, const mpd_t *a, const mpd_t *b, mpd_context_t *ctx);
void mpd_set_string(mpd_t *result, const char *s, mpd_context_t *ctx);
void mpd_maxcoeff(mpd_t *result, mpd_context_t *ctx);
void mpd_sset_ssize(mpd_t *result, mpd_ssize_t a, mpd_context_t *ctx);
void mpd_sset_i32(mpd_t *result, int32_t a, mpd_context_t *ctx);
void mpd_sset_uint(mpd_t *result, mpd_uint_t a, mpd_context_t *ctx);
void mpd_sset_u32(mpd_t *result, uint32_t a, mpd_context_t *ctx);
void mpd_set_ssize(mpd_t *result, mpd_ssize_t a, mpd_context_t *ctx);
void mpd_set_i32(mpd_t *result, int32_t a, mpd_context_t *ctx);
void mpd_set_uint(mpd_t *result, mpd_uint_t a, mpd_context_t *ctx);
void mpd_set_u32(mpd_t *result, uint32_t a, mpd_context_t *ctx);
void mpd_set_i64(mpd_t *result, int64_t a, mpd_context_t *ctx);
void mpd_set_u64(mpd_t *result, uint64_t a, mpd_context_t *ctx);

mpd_ssize_t mpd_get_ssize(const mpd_t *a, mpd_context_t *ctx);
mpd_uint_t mpd_get_uint(const mpd_t *a, mpd_context_t *ctx);
mpd_uint_t mpd_abs_uint(const mpd_t *a, mpd_context_t *ctx);
int32_t mpd_get_i32(const mpd_t *a, mpd_context_t *ctx);
uint32_t mpd_get_u32(const mpd_t *a, mpd_context_t *ctx);
int64_t mpd_get_i64(const mpd_t *a, mpd_context_t *ctx);
uint64_t mpd_get_u64(const mpd_t *a, mpd_context_t *ctx);
void mpd_and(mpd_t *result, const mpd_t *a, const mpd_t *b, mpd_context_t *ctx);
void mpd_copy(mpd_t *result, const mpd_t *a, mpd_context_t *ctx);
void mpd_canonical(mpd_t *result, const mpd_t *a, mpd_context_t *ctx);
void mpd_copy_abs(mpd_t *result, const mpd_t *a, mpd_context_t *ctx);
void mpd_copy_negate(mpd_t *result, const mpd_t *a, mpd_context_t *ctx);
void mpd_copy_sign(mpd_t *result, const mpd_t *a, const mpd_t *b, mpd_context_t *ctx);
void mpd_invert(mpd_t *result, const mpd_t *a, mpd_context_t *ctx);
void mpd_logb(mpd_t *result, const mpd_t *a, mpd_context_t *ctx);
void mpd_or(mpd_t *result, const mpd_t *a, const mpd_t *b, mpd_context_t *ctx);
void mpd_rotate(mpd_t *result, const mpd_t *a, const mpd_t *b, mpd_context_t *ctx);
void mpd_scaleb(mpd_t *result, const mpd_t *a, const mpd_t *b, mpd_context_t *ctx);
void mpd_shiftl(mpd_t *result, const mpd_t *a, mpd_ssize_t n, mpd_context_t *ctx);
mpd_uint_t mpd_shiftr(mpd_t *result, const mpd_t *a, mpd_ssize_t n, mpd_context_t *ctx);
void mpd_shiftn(mpd_t *result, const mpd_t *a, mpd_ssize_t n, mpd_context_t *ctx);
void mpd_shift(mpd_t *result, const mpd_t *a, const mpd_t *b, mpd_context_t *ctx);
void mpd_xor(mpd_t *result, const mpd_t *a, const mpd_t *b, mpd_context_t *ctx);
void mpd_abs(mpd_t *result, const mpd_t *a, mpd_context_t *ctx);
int mpd_cmp(const mpd_t *a, const mpd_t *b, mpd_context_t *ctx);
int mpd_compare(mpd_t *result, const mpd_t *a, const mpd_t *b, mpd_context_t *ctx);
int mpd_compare_signal(mpd_t *result, const mpd_t *a, const mpd_t *b, mpd_context_t *ctx);
void mpd_add(mpd_t *result, const mpd_t *a, const mpd_t *b, mpd_context_t *ctx);
void mpd_add_ssize(mpd_t *result, const mpd_t *a, mpd_ssize_t b, mpd_context_t *ctx);
void mpd_add_i32(mpd_t *result, const mpd_t *a, int32_t b, mpd_context_t *ctx);
void mpd_add_uint(mpd_t *result, const mpd_t *a, mpd_uint_t b, mpd_context_t *ctx);
void mpd_add_u32(mpd_t *result, const mpd_t *a, uint32_t b, mpd_context_t *ctx);
void mpd_sub(mpd_t *result, const mpd_t *a, const mpd_t *b, mpd_context_t *ctx);
void mpd_sub_ssize(mpd_t *result, const mpd_t *a, mpd_ssize_t b, mpd_context_t *ctx);
void mpd_sub_i32(mpd_t *result, const mpd_t *a, int32_t b, mpd_context_t *ctx);
void mpd_sub_uint(mpd_t *result, const mpd_t *a, mpd_uint_t b, mpd_context_t *ctx);
void mpd_sub_u32(mpd_t *result, const mpd_t *a, uint32_t b, mpd_context_t *ctx);
void mpd_div(mpd_t *q, const mpd_t *a, const mpd_t *b, mpd_context_t *ctx);
void mpd_div_ssize(mpd_t *result, const mpd_t *a, mpd_ssize_t b, mpd_context_t *ctx);
void mpd_div_i32(mpd_t *result, const mpd_t *a, int32_t b, mpd_context_t *ctx);
void mpd_div_uint(mpd_t *result, const mpd_t *a, mpd_uint_t b, mpd_context_t *ctx);
void mpd_div_u32(mpd_t *result, const mpd_t *a, uint32_t b, mpd_context_t *ctx);
void mpd_divmod(mpd_t *q, mpd_t *r, const mpd_t *a, const mpd_t *b, mpd_context_t *ctx);
void mpd_divint(mpd_t *q, const mpd_t *a, const mpd_t *b, mpd_context_t *ctx);
void mpd_exp(mpd_t *result, const mpd_t *a, mpd_context_t *ctx);
void mpd_fma(mpd_t *result, const mpd_t *a, const mpd_t *b, const mpd_t *c, mpd_context_t *ctx);
void mpd_ln(mpd_t *result, const mpd_t *a, mpd_context_t *ctx);
void mpd_log10(mpd_t *result, const mpd_t *a, mpd_context_t *ctx);
void mpd_max(mpd_t *result, const mpd_t *a, const mpd_t *b, mpd_context_t *ctx);
void mpd_max_mag(mpd_t *result, const mpd_t *a, const mpd_t *b, mpd_context_t *ctx);
void mpd_min(mpd_t *result, const mpd_t *a, const mpd_t *b, mpd_context_t *ctx);
void mpd_min_mag(mpd_t *result, const mpd_t *a, const mpd_t *b, mpd_context_t *ctx);
void mpd_minus(mpd_t *result, const mpd_t *a, mpd_context_t *ctx);
void mpd_mul(mpd_t *result, const mpd_t *a, const mpd_t *b, mpd_context_t *ctx);
void mpd_mul_ssize(mpd_t *result, const mpd_t *a, mpd_ssize_t b, mpd_context_t *ctx);
void mpd_mul_i32(mpd_t *result, const mpd_t *a, int32_t b, mpd_context_t *ctx);
void mpd_mul_uint(mpd_t *result, const mpd_t *a, mpd_uint_t b, mpd_context_t *ctx);
void mpd_mul_u32(mpd_t *result, const mpd_t *a, uint32_t b, mpd_context_t *ctx);
void mpd_next_minus(mpd_t *result, const mpd_t *a, mpd_context_t *ctx);
void mpd_next_plus(mpd_t *result, const mpd_t *a, mpd_context_t *ctx);
void mpd_next_toward(mpd_t *result, const mpd_t *a, const mpd_t *b, mpd_context_t *ctx);
void mpd_plus(mpd_t *result, const mpd_t *a, mpd_context_t *ctx);
void mpd_pow(mpd_t *result, const mpd_t *base, const mpd_t *exp, mpd_context_t *ctx);
void mpd_powmod(mpd_t *result, const mpd_t *base, const mpd_t *exp, const mpd_t *mod, mpd_context_t *ctx);
void mpd_quantize(mpd_t *result, const mpd_t *a, const mpd_t *b, mpd_context_t *ctx);
void mpd_rescale(mpd_t *result, const mpd_t *a, mpd_ssize_t exp, mpd_context_t *ctx);
void mpd_reduce(mpd_t *result, const mpd_t *a, mpd_context_t *ctx);
void mpd_rem(mpd_t *r, const mpd_t *a, const mpd_t *b, mpd_context_t *ctx);
void mpd_rem_near(mpd_t *r, const mpd_t *a, const mpd_t *b, mpd_context_t *ctx);
void mpd_round_to_intx(mpd_t *result, const mpd_t *a, mpd_context_t *ctx);
void mpd_round_to_int(mpd_t *result, const mpd_t *a, mpd_context_t *ctx);
void mpd_trunc(mpd_t *result, const mpd_t *a, mpd_context_t *ctx);
void mpd_floor(mpd_t *result, const mpd_t *a, mpd_context_t *ctx);
void mpd_ceil(mpd_t *result, const mpd_t *a, mpd_context_t *ctx);
void mpd_sqrt(mpd_t *result, const mpd_t *a, mpd_context_t *ctx);
void mpd_invroot(mpd_t *result, const mpd_t *a, mpd_context_t *ctx);

void mpd_add_i64(mpd_t *result, const mpd_t *a, int64_t b, mpd_context_t *ctx);
void mpd_add_u64(mpd_t *result, const mpd_t *a, uint64_t b, mpd_context_t *ctx);
void mpd_sub_i64(mpd_t *result, const mpd_t *a, int64_t b, mpd_context_t *ctx);
void mpd_sub_u64(mpd_t *result, const mpd_t *a, uint64_t b, mpd_context_t *ctx);
void mpd_div_i64(mpd_t *result, const mpd_t *a, int64_t b, mpd_context_t *ctx);
void mpd_div_u64(mpd_t *result, const mpd_t *a, uint64_t b, mpd_context_t *ctx);
void mpd_mul_i64(mpd_t *result, const mpd_t *a, int64_t b, mpd_context_t *ctx);
void mpd_mul_u64(mpd_t *result, const mpd_t *a, uint64_t b, mpd_context_t *ctx);


/******************************************************************************/
/*                       Get attributes of a decimal                          */
/******************************************************************************/

mpd_ssize_t mpd_adjexp(const mpd_t *dec);
mpd_ssize_t mpd_etiny(const mpd_context_t *ctx);
mpd_ssize_t mpd_etop(const mpd_context_t *ctx);
mpd_uint_t mpd_msword(const mpd_t *dec);
int mpd_word_digits(mpd_uint_t word);
/* most significant digit of a word */
mpd_uint_t mpd_msd(mpd_uint_t word);
/* least significant digit of a word */
mpd_uint_t mpd_lsd(mpd_uint_t word);
/* coefficient size needed to store 'digits' */
mpd_ssize_t mpd_digits_to_size(mpd_ssize_t digits);
/* number of digits in the exponent, undefined for MPD_SSIZE_MIN */
int mpd_exp_digits(mpd_ssize_t exp);
int mpd_iscanonical(const mpd_t *dec);
int mpd_isfinite(const mpd_t *dec);
int mpd_isinfinite(const mpd_t *dec);
int mpd_isinteger(const mpd_t *dec);
int mpd_isnan(const mpd_t *dec);
int mpd_isnegative(const mpd_t *dec);
int mpd_ispositive(const mpd_t *dec);
int mpd_isqnan(const mpd_t *dec);
int mpd_issigned(const mpd_t *dec);
int mpd_issnan(const mpd_t *dec);
int mpd_isspecial(const mpd_t *dec);
int mpd_iszero(const mpd_t *dec);
/* undefined for special numbers */
int mpd_iszerocoeff(const mpd_t *dec);
int mpd_isnormal(const mpd_t *dec, const mpd_context_t *ctx);
int mpd_issubnormal(const mpd_t *dec, const mpd_context_t *ctx);
/* odd word */
int mpd_isoddword(mpd_uint_t word);
/* odd coefficient */
int mpd_isoddcoeff(const mpd_t *dec);
/* odd decimal, only defined for integers */
int mpd_isodd(const mpd_t *dec);
/* even decimal, only defined for integers */
int mpd_iseven(const mpd_t *dec);
/* 0 if dec is positive, 1 if dec is negative */
uint8_t mpd_sign(const mpd_t *dec);
/* 1 if dec is positive, -1 if dec is negative */
int mpd_arith_sign(const mpd_t *dec);
long mpd_radix();
int mpd_isdynamic(const mpd_t *dec);
int mpd_isstatic(const mpd_t *dec);
int mpd_isdynamic_data(const mpd_t *dec);
int mpd_isstatic_data(const mpd_t *dec);
int mpd_isshared_data(const mpd_t *dec);
int mpd_isconst_data(const mpd_t *dec);
mpd_ssize_t mpd_trail_zeros(const mpd_t *dec);


/******************************************************************************/
/*                       Set attributes of a decimal                          */
/******************************************************************************/

/* set number of decimal digits in the coefficient */
void mpd_setdigits(mpd_t *result);
void mpd_set_sign(mpd_t *result, uint8_t sign);
/* copy sign from another decimal */
void mpd_signcpy(mpd_t *result, const mpd_t *a);
void mpd_set_infinity(mpd_t *result);
void mpd_set_qnan(mpd_t *result);
void mpd_set_snan(mpd_t *result);
void mpd_set_negative(mpd_t *result);
void mpd_set_positive(mpd_t *result);
void mpd_set_dynamic(mpd_t *result);
void mpd_set_static(mpd_t *result);
void mpd_set_dynamic_data(mpd_t *result);
void mpd_set_static_data(mpd_t *result);
void mpd_set_shared_data(mpd_t *result);
void mpd_set_const_data(mpd_t *result);
void mpd_clear_flags(mpd_t *result);
void mpd_set_flags(mpd_t *result, uint8_t flags);
void mpd_copy_flags(mpd_t *result, const mpd_t *a);


/******************************************************************************/
/*                            Memory handling                                 */
/******************************************************************************/

extern (C) void* function(size_t size) mpd_mallocfunc;
extern (C) void* function(size_t nmemb, size_t size) mpd_callocfunc;
extern (C) void* function(void* ptr, size_t size) mpd_reallocfunc;
extern (C) void function(void* ptr) mpd_free;

void *mpd_callocfunc_em(size_t nmemb, size_t size);

void *mpd_alloc(mpd_size_t nmemb, mpd_size_t size);
void *mpd_calloc(mpd_size_t nmemb, mpd_size_t size);
void *mpd_realloc(void *ptr, mpd_size_t nmemb, mpd_size_t size, uint8_t *err);
void *mpd_sh_alloc(mpd_size_t struct_size, mpd_size_t nmemb, mpd_size_t size);

mpd_t *mpd_qnew();
mpd_t *mpd_new(mpd_context_t *ctx);
mpd_t *mpd_qnew_size(mpd_ssize_t size);
void mpd_del(mpd_t *dec);

void mpd_uint_zero(mpd_uint_t *dest, mpd_size_t len);
int mpd_qresize(mpd_t *result, mpd_ssize_t size, uint32_t *status);
int mpd_qresize_zero(mpd_t *result, mpd_ssize_t size, uint32_t *status);
void mpd_minalloc(mpd_t *result);

int mpd_resize(mpd_t *result, mpd_ssize_t size, mpd_context_t *ctx);
int mpd_resize_zero(mpd_t *result, mpd_ssize_t size, mpd_context_t *ctx);


}

