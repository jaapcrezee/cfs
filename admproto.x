
/* error conditions */
enum cfsstat {
	CFS_OK=0,		/* ok */
	CFSERR_PERM=1,		/* permission denied */
	CFSERR_IFULL=2,		/* instance table full; */
	CFSERR_NOINS=3,		/* no such instance */
	CFSERR_EXIST=4,		/* name already in use */
	CFSERR_NODIR=5,		/* no such directory */
	CFSERR_BADKEY=6,	/* invalid key */
	CFSERR_BADNAME=7	/* badly formed name */
};

enum ciphers {
	CFS_SAFER_SK128=0	/* 1 key hybrid SAFER-SK128 */
};

const CFS_MAXCOMP=255;
const CFS_MAXNAME=1024;



struct cfs_adm_saferkey {
	long pl;		/* for 32 bit align police */
	u_char primary[16];
	u_char secondary[16];	/* same as primary */
};

union cfs_admkey switch (ciphers cipher) {
    case CFS_SAFER_SK128:
	cfs_adm_saferkey saferkey;
    default:
	void;
};

struct cfs_attachargs {
	string dirname<CFS_MAXNAME>;	/* directory to attach to */
	string name<CFS_MAXCOMP>;	/* instance name */
	cfs_admkey key;			/* key to use */
	int uid;			/* uid to apply - need not be
					   same as in rpc */
	int highsec;			/* nonzero for highsec mode */
	bool anon;			/* anonymousness */
	/* for timeouts, zero indicates infinite */
	int expire;			/* number of minutes to live */
	int idle;			/* idle timeout */
	int smsize;			/* use small memeory option */
};

struct cfs_detachargs {
	string name<CFS_MAXCOMP>;	/* instance name */
	int uid;			/* just has to match */
};


program ADM_PROGRAM {
	version ADM_VERSION {
		void ADMPROC_NULL(void) = 0;
		cfsstat ADMPROC_ATTACH(cfs_attachargs) = 1;
		cfsstat ADMPROC_DETACH(cfs_detachargs) = 2;
	} = 2;
} = 0x41234567;



