
#include <stdio.h>
#include <signal.h>
#ifndef linux
#include <sgtty.h>
#endif
#include <sys/types.h>
#include <rpc/rpc.h>
#include "nfsproto.h"
#include "admproto.h"
#include "cfs.h"
#include "shs.h"

#if defined(irix) || defined(linux)
/* hacks to use POSIX style termios instead of old BSD style sgttyb */
#include <termios.h>
#define sgttyb termios
#define gtty(a,b) tcgetattr((a), (b))
#define stty(a,b) tcsetattr((a), TCSAFLUSH, (b))
#define sg_flags c_lflag
#endif

	
char *
getpassword(prompt)
char *prompt;
{
	struct sgttyb ttyb;
	int flags;
	register char *p;
	register c;
	FILE *fi;
	static char pbuf[128];
#ifdef MACH
	int (*signal())();
	int (*sig)();
#else
	void (*sig)();
#endif

	if ((fi = fdopen(open("/dev/tty", 2), "r")) == NULL)
		fi = stdin;
	else
		setbuf(fi, (char *)NULL);
	sig = signal(SIGINT, SIG_IGN);
	gtty(fileno(fi), &ttyb);
	flags = ttyb.sg_flags;
	ttyb.sg_flags &= ~ECHO;
	stty(fileno(fi), &ttyb);
	fprintf(stderr, "%s", prompt); fflush(stderr);
	for (p=pbuf; (c = getc(fi))!='\n' && c!=EOF;) {
		if (p < &pbuf[127])
			*p++ = c;
	}
	*p = '\0';
	fprintf(stderr, "\n"); fflush(stderr);
	ttyb.sg_flags = flags;
	stty(fileno(fi), &ttyb);
	signal(SIGINT, sig);
	if (fi != stdin)
		fclose(fi);
	return(pbuf);
}

//*  Removed the old version based on DES.
old_pwcrunch(b,k)
   char *b;
   cfs_admkey *k;
{
   new_pwcrunch(b,k);
}


new_pwcrunch(b,k)
     char *b;
     cfs_admkey *k;
{
	int l;
	u_char *k1;
	u_char *k2;
	u_char *k3;
	u_char *hash;
	u_char h1[20];
	u_char h2[20];
	
	if ((l=strlen(b))<3)
		return -1;
		
	hash = qshs(b,l);
	bcopy(hash,h1,20);
	k1 = h1;
	k2 = &(h1[8]);
	/* for true threedes, we do one more hash to get the third key */
	hash = qshs(h1,20);
	bcopy(hash,h2,20);
	k3 = h2;

		bcopy(k1,k->cfs_admkey_u.saferkey.primary,16);
		bcopy(k1,k->cfs_admkey_u.saferkey.secondary,16);

	return 0;
}


decrypt_key(k,ek)
     cfs_admkey *k;
     u_char *ek;
{
	safer_key_t sk;
	
		Safer_Init_Module();
		Safer_Expand_Userkey(k->cfs_admkey_u.saferkey.primary,
				     &(k->cfs_admkey_u.saferkey.primary[8]),
				     SAFER_SK128_DEFAULT_NOF_ROUNDS, 1, sk);
				     
		Safer_Decrypt_Block(&(ek[0]),sk,&(ek[0]));
		Safer_Decrypt_Block(&(ek[8]),sk,&(ek[8]));
		bcopy(ek,k->cfs_admkey_u.saferkey.primary,16);
		bcopy(ek,k->cfs_admkey_u.saferkey.secondary,16);
}



encrypt_key(k,ek)
     cfs_admkey *k;
     u_char *ek;
{
	safer_key_t sk;

		Safer_Init_Module();
		Safer_Expand_Userkey(k->cfs_admkey_u.saferkey.primary,
				     &(k->cfs_admkey_u.saferkey.primary[8]),
				     SAFER_SK128_DEFAULT_NOF_ROUNDS, 1,
				     sk);
		Safer_Encrypt_Block(&(ek[0]),sk,&(ek[0]));
		Safer_Encrypt_Block(&(ek[8]),sk,&(ek[8]));
}
