
#include "safer.h"

#define H_REG 0
#define H_ATTACH 0	/* same as regular */
#define H_ROOT 1
#define H_INVALID 9
#ifdef SHORTLINKS
#define H_SLNK 5
#endif

#ifndef CFS_PORT
#define CFS_PORT 3049
#endif

#ifndef NINSTANCES
#define NINSTANCES 64
#endif

#define CFSBLOCK 8	/* granularity of DES encryption */
/* writing is a bit tricky - if not 8 byte boundry, read in prev & next
   8 byte boundry first, make the change in place, and write back the whole
   thing */

#define SAFER_SK128 0	/* 1 key hybrid SAFER-SK128 */


typedef struct fhdata {
	u_char magic[8];/* 0x0123456789abcdef */
	u_short htype;	/* 0=reg, 1=attachpt, 2=root(but notused) */
	u_short instance;	/* which attach */
	u_long fileid;	/* inode # */
	u_char check[8];/* we just encrypt the date and copy it here */
#ifdef SHORTLINKS
	u_long linkid;	/* To uniquify short links */
	u_char pad[4];	/* empty */
#else
	u_char pad[8];	/* empty */
#endif
} fhdata;

typedef union fh_u {
	u_char opaque[NFS_FHSIZE];
	struct fhdata fh;
} fh_u;

typedef struct cfs_fileid {	/* hash table entry */
	int fileid;	/* inode */
	int key;	/* key id, for future use */
	char vect[9];	/* pertubation vector */
	char vectname[1024];	/* name of symlink w/ pert vect */
	char *name; /* encrypted path, w/r/t cfs root */
	/* the name should be changed to a list of names, and we should make
	   sure we have the right one open.  Lookup (not link) adds names,
	   remove and rmdir delete names. */
	struct fdcache *fd; /* fd, if already open, or NULL (reg files only)*/
	int parent;	/* dir only; -1 for instance root (send back self)*/
#ifdef SHORTLINKS
	int link_count;	/* dir only; for shortlinks. */
	int linkid;	/* short links only */
#endif
	struct cfs_fileid *next;
	struct instance *ins;	/* this is redundnat, but helps */
} cfs_fileid;

typedef struct fdcache {
	cfs_fileid *file;	/* fh with the file open */
	int fd;		/* currently open fd */
	int mode;	/* 0=RO, else RDWR */
	struct filecache *next;	/* fwd and back ptrs */
	struct filecache *prev; /* frontmost is mru */
} fdcache;

#define HSIZE 1024
#define HMASK 0x3ff	/* change these together, please */

#define LARGESMSIZE (32768*CFSBLOCK)
#define SMALLSMSIZE (512*CFSBLOCK)

typedef struct cfskey {  /* now holds expanded keys for DES also */
	int cipher;
	union {	
		struct { /* SAFER */
			safer_key_t primary;
			safer_key_t secondary;
		} safer;
	} var;
	int smsize; /* right now either LARGESMSIZE or SMALLSMSIZE */
	char *primask;
	char *secmask;
} cfskey;

typedef struct instance {
	cfs_fileid *file[HMASK+1];
	char path[NFS_MAXPATHLEN+1]; /* path to get to files w/r/t root */
	char name[NFS_MAXNAMLEN+1];  /* name of the attach point */
	cfskey key;
	u_char check[8];/* we just encrypt the date and copy it here */
	int uid;	/* authorized uid */
			/* we need a better credential mechanism */
	int id;		/* same as its position in instances[] */
	int highsec;	/* use perturbation vectors */
	int anon;	/* invisability */
	int timeout;	/* absolute timeout (0 is infinite) */
	int idle;	/* idle timer (0 is infinite) */
	int access;	/* last access time (for use by idle timer) */
	int dead;	/* to be killed */
} instance;

extern int cfserrno;
extern int errno;
extern int cursecs;

extern char zerovect[];

#define CFS_READ O_RDONLY
#define CFS_WRITE (O_RDWR)

extern char *admerrs[];
char *admmsg();

/* char *keyof(); */
char *encryptname();
char *decryptname();

cfs_fileid *geth();

extern instance *instances[];
extern nfstime roottime;
extern cfs_fileid rootnode;

#ifdef hpux
#define seteuid(x) setresuid(-1,x,-1)
#define setegid(x) setresgid(-1,x,-1)
#endif


#define become(x) ((x)==NULL?(seteuid(0)||setegid(0)) :\
		   (setegid(rgid(x)) || seteuid(ruid(x))))
#define keyof(f) (&((f)->ins->key))
#define vectof(f) ((f)->vect)


#ifdef BSD44
/*
#define d_off d_reclen
#define d_fileno d_ino
*/
#endif
#include<stdlib.h>
