/*
 * The author of this software is Matt Blaze.
 *              Copyright (c) 1994 by AT&T.
 * Permission to use, copy, and modify this software without fee
 * is hereby granted, provided that this entire notice is included in
 * all copies of any software which is or includes a copy or
 * modification of this software and in all copies of the supporting
 * documentation for such software.
 *
 * This software is subject to United States export controls.
 *
 * THIS SOFTWARE IS BEING PROVIDED "AS IS", WITHOUT ANY EXPRESS OR IMPLIED
 * WARRANTY.  IN PARTICULAR, NEITHER THE AUTHORS NOR AT&T MAKE ANY
 * REPRESENTATION OR WARRANTY OF ANY KIND CONCERNING THE MERCHANTABILITY
 * OF THIS SOFTWARE OR ITS FITNESS FOR ANY PARTICULAR PURPOSE.
 */


#include <stdio.h>
#include <rpc/rpc.h>
#include "nfsproto.h"
#include "admproto.h"
#include "cfs.h"

cipher(k,s,d)
     cfskey *k;
     unsigned char *s;
     int d; /* "decrypting" flag */
{
	d=d&1;
	switch (k->cipher) {
	    case SAFER_SK128:
		if (d)
			Safer_Decrypt_Block(s,k->var.safer.primary,s);
		else
			Safer_Encrypt_Block(s,k->var.safer.primary,s);
	    default:	/* just does nothing */
		break;
	}
}

mask_cipher(k,s,d)
     cfskey *k;
     unsigned char *s;
     int d;
{
	d=d&1;
	switch (k->cipher) {
	    case SAFER_SK128:
		if (d)
			Safer_Decrypt_Block(s,k->var.safer.secondary,s);
		else
			Safer_Encrypt_Block(s,k->var.safer.secondary,s);
	    default:	/* just does nothing */
		break;
	}
}



copykey(key,k)
     cfs_admkey *key;
     cfskey *k;
{
	switch (key->cipher) {
	    case CFS_SAFER_SK128:
		k->cipher=SAFER_SK128;
		Safer_Init_Module();
		Safer_Expand_Userkey(key->cfs_admkey_u.saferkey.primary,
				     &(key->cfs_admkey_u.saferkey.primary[8]),
				     SAFER_SK128_DEFAULT_NOF_ROUNDS,
				     1, /* for SK128 */
				     k->var.safer.primary);
		Safer_Expand_Userkey(key->cfs_admkey_u.saferkey.secondary,
				     &(key->cfs_admkey_u.saferkey.secondary[8]),
				     SAFER_SK128_DEFAULT_NOF_ROUNDS,
				     1, /* for SK128 */
				     k->var.safer.secondary);
	    default:
		break;
	}
}
