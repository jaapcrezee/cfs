# Makefile for CFS 1.5

#==========================================================================
# Edit the three "CONFIGURE:" sections below to customize for your platform.
# Note that I've tested only the SunOS and BSDI configurations.
# If you discover a problem and change configuration, ALWAYS run
# make clean after editing this file.
#==========================================================================

#==========================================================================
# (1/3) CONFIGURE: local customization
#==========================================================================
#
# configuration options for all platforms
#
# 1A, 1B: pathnames, compiler, etc:

#1A: compiler:
# for cc, use
#CC=cc
#COPT=-O -DNOT_ANSI_C -DPROTOTYPES=0
# for gcc, use
CC?=gcc
CFLAGS?=-O2
CFLAGS+=-DPROTOTYPES=1

#1B: paths:
#some peple like /usr/local/sbin instead of /usr/local/etc
BINDIR=/usr/local/bin
ETCDIR=/usr/local/etc
PRINTCMD=enscript -Gr2


# if you're a paranoid fascist, you might want to configure
# default timeouts on the attach command.  If you do,
# just add definitions for TMOUT and IDLE with the default number
# of minutes you want to the CFLAGS line.
# So the COPT line for the SUNOS CC configuration with a timeout
# of 12 hours and an idle timer of 2 hours would look like:
# COPT=-O -DTMOUT=720 -DIDLE=120
# If you leave them out the default timeouts are infinite.  You
# can override them, of course, on the cattach command line.


#=======================================================================
# (2/3) CONFIGURE: platform selection
#=======================================================================
# Uncomment the options for the your local platform.
# You'll need to figure out how to install man pages yourself.

## Use these for vanilla SUNOS 4.x .
#CFLAGS=$(COPT) -I$(RINCLUDES) -DSUN
#LIBS=
#COMPAT=
#RPCOPTS=

## Use these for recent versions of Linux with the new rpcgen
## and broken glibc2 header files:
## (Known to work on RedHat 4.x and 5.x and many other current
## Linux dists).
## See NOTE TO LINUX USERS above, and also README.linux,
## if you can't make things work.
#CFLAGS=$(COPT) -U__STDC__ -Dd_fileno=d_ino -I$(RINCLUDES)
#LIBS=
#COMPAT=
#RPCOPTS= -k -b

## A few Linux users have reported success with these
## options:
## See NOTE TO LINUX USERS above, and also README.linux,
## if you can't make things work.
#CFLAGS=$(COPT) -U__OPTIMIZE__ -traditional -Dd_fileno=d_ino -I$(RINCLUDES)
#LIBS=
#COMPAT=
#RPCOPTS= -k -b

## Users of older versions Linux (Slackware 1.1.2) may be able to
## use these options:
## See NOTE TO LINUX USERS above, and also README.linux,
## if you can't make things work.
#CFLAGS=$(COPT) -I$(RINCLUDES)
#LIBS=
#COMPAT=
#RPCOPTS=

## Irix 4.0 -- markh@wimsey.bc.ca
## Be sure to read README.irix
#CFLAGS=-cckr $(COPT) -Dirix -I$(RINCLUDES)
#LIBS=-lrpcsvc -lsun
#COMPAT=
#RPCOPTS=

## HPUX 8.0 -- markh@wimsey.bc.ca
## Also thanks to Charles Henrich (henrich@crh.cl.msu.edu)
## and Eric Ross (ericr@hpvclq.vcd.hp.com)
#CFLAGS=$(COPT) -Dhpux -DNORLIMITS -I$(RINCLUDES)
#COMPAT=
#RPCOPTS=
#LIBS=-lBSD
# On later hpux versions, use
#LIBS=

## AIX 3.2.0 -- markh@wimsey.bc.ca
#CFLAGS=$(COPT) -D_BSD -D_SUN -DAIX320EUIDBUG -I$(RINCLUDES)
#LIBS=
#COMPAT=
#RPCOPTS=

## Generic 4.4 systems with CFS on its own port
#CFLAGS=$(COPT) -DBSD44 -DANYPORT -I$(RINCLUDES)
#LIBS=-lrpc
#COMPAT=-lcompat
#RPCOPTS=

## Ultrix 4.2a
#CFLAGS=$(COPT) -DANYPORT -I$(RINCLUDES)
#LIBS=
#COMPAT=
#RPCOPTS=

## BSD386 systems with CFS on its own port 
## Use this for BSDI 2.1 or later
## BSDI support by mab
#CFLAGS=$(COPT) -DBSD44 -DANYPORT -DSHORTLINKS -I$(RINCLUDES)
#LIBS=-lrpc
#COMPAT=-lcompat
#RPCOPTS=

## Use these for 4.4/BSD386 systems with CFS on the NFS port because of no
## support for the port options in the mount syscall
## Use this for BSDI 2.0 or earlier.
## BSDI support by mab
## Also works under older freeBSD, though you may want to use -static on the
##  linker (dean@deanstoy.wa.com (Dean M. Phillips))
#CFLAGS=$(COPT) -DBSD44 -DANYPORT -DCFS_PORT=2049 -DSHORTLINKS -I$(RINCLUDES)
#LIBS=-lrpc
#COMPAT=-lcompat
#RPCOPTS=

## Use these for FreeBSD 2.2.x systems with CFS on it's own port (Dima Ruban)
#CFLAGS=$(COPT) -DBSD44 -DANYPORT -DSHORTLINKS -I$(RINCLUDES)
#LIBS=
#COMPAT=-lcompat
#RPCOPTS=
 
##Use these for NetBSD i386 1.0 (John Kohl)
## For mounting, you need to use a command like:
##	mount -o -P,-c localhost:/null /crypt
## Use -DSHORTLINKS to support the BSD 4.4 symbolic links (Dave Carrel)
#CFLAGS=$(COPT) -DBSD44 -DANYPORT -DCFS_PORT=2049 -DSHORTLINKS -I$(RINCLUDES)
#LIBS=
#COMPAT=-lcompat
#RPCOPTS=

#* Use these for NetBSD 1.5
## For mounting, use
##	mount -o intr,-2 127.0.0.1:/null /crypt
#CFLAGS=$(COPT) -DBSD44 -DANYPORT -DCFS_PORT=2049 -DSHORTLINKS -I$(RINCLUDES) -traditional
#COMPAT=-lcompat
#RPCOPTS=-b

## Solaris 2.3 / SUNOS 5.x
#CFLAGS=$(COPT) -DSOLARIS2X -DPORTMAP -I$(RINCLUDES) -DPTMX
#LIBS=-lsocket -lnsl
#COMPAT=
#RPCOPTS=

## not sure what to do for NeXT.  I think this works:
#CFLAGS=$(COPT) -posix -D_BSD -DANYPORT -I$(RINCLUDES)

## use these for FreeBSD
CFLAGS+=-DBSD44 -DANYPORT -DSHORTLINKS
LIBS=-lrpcsvc
COMPAT=-lcompat
RPCOPTS=


#==========================================================================
# (3/3) CONFIGURE: one last thing
#==========================================================================
# finally, comment out the next line:
#CC=you_forgot_to_edit_the_makefile

# now you're done with local configuration.


#==========================================================================
# CONFIGURE: you shouldn't touch anything below here
#==========================================================================

SRCS=Makefile admproto.x mount.x nfsproto.x cfs.c cfs_adm.c cfs_nfs.c cfs.h \
  cfs_fh.c cfs_cipher.c shs.c shs.h cattach.c \
  getpass.c cdetach.c cmkdir.c adm.c  cpasswd.c truerand.c \
  safer.c safer.h VERSION LEVELS i o cfssh make_with_bad_rpcgen cmkkey
MANS=cattach.1 cdetach.1 cmkdir.1 cfsd.8  cpasswd.1 cmkkey.1
OBJS= cfs.o nfsproto_xdr.o nfsproto_svr.o admproto_xdr.o admproto_svr.o \
  cfs_adm.o cfs_nfs.o cfs_fh.o cfs_cipher.o adm.o ver.o safer.o
EOBJS=dhparams.o truerand.o 
COBJS=admproto_clnt.o cfs_cipher.o cattach.o getpass.o cmkdir.o \
  cdetach.o ver.o cname.o ccat.o shs.o cpasswd.o truerand.o safer.o
OTHERS = nfsproto.h nfsproto_svr.c nfsproto_xdr.c admproto.h admproto_svr.c \
  admproto_xdr.c admproto_clnt.c ver.c

default:
	@echo make "cfs",  "install_cfs" 

cfs: cfsd cattach cmkdir cdetach cname ccat cpasswd
	@echo

cfsd: $(OBJS)
	$(CC) $(OBJS) $(LIBS) -o cfsd

cattach: cattach.o admproto_clnt.o admproto_xdr.o getpass.o \
  cfs_cipher.o adm.o ver.o shs.o safer.o
	$(CC) cattach.o admproto_clnt.o admproto_xdr.o \
	   cfs_cipher.o getpass.o adm.o ver.o \
	   shs.o safer.o $(COMPAT) $(LIBS) -o cattach

cdetach: cdetach.o admproto_clnt.o admproto_xdr.o adm.o ver.o
	$(CC) cdetach.o adm.o admproto_clnt.o admproto_xdr.o \
	   ver.o $(LIBS) -o cdetach

cmkdir: getpass.o adm.o cfs_cipher.o cmkdir.o ver.o \
   safer.o shs.o truerand.o
	$(CC) cmkdir.o  cfs_cipher.o getpass.o adm.o ver.o \
	   safer.o shs.o truerand.o \
	   $(COMPAT) -o cmkdir

cpasswd: getpass.o cfs_cipher.o cpasswd.o ver.o \
   safer.o shs.o truerand.o
	$(CC) cpasswd.o  cfs_cipher.o getpass.o ver.o safer.o shs.o \
	   truerand.o  $(COMPAT) -o cpasswd

cname: cname.o getpass.o cfs_cipher.o cfs_adm.o cfs_fh.o \
    cfs_nfs.o ver.o safer.o shs.o
	$(CC) cname.o getpass.o  cfs_cipher.o cfs_adm.o cfs_fh.o \
	   cfs_nfs.o ver.o safer.o \
	   shs.o $(LIBS) $(COMPAT) -o cname

ccat: ccat.o getpass.o cfs_cipher.o cfs_adm.o cfs_fh.o cfs_nfs.o \
   ver.o shs.o safer.o
	$(CC) ccat.o getpass.o cfs_cipher.o cfs_adm.o cfs_fh.o \
	   cfs_nfs.o ver.o  shs.o \
	   safer.o $(LIBS) $(COMPAT) -o ccat

$(OBJS): nfsproto.h admproto.h cfs.h safer.h shs.h 

$(COBJS): nfsproto.h admproto.h cfs.h safer.h shs.h

# truerand is a special case, no -O
truerand.o:
	$(CC) -c truerand.c

ver.c: VERSION LEVELS
	echo "static char version[]=" > ver.c
	echo "  \"CFS `cat VERSION` (`cat LEVELS`)\";" >> ver.c

nfsproto_xdr.c: nfsproto.x
	rpcgen $(RPCOPTS) -c -o nfsproto_xdr.c nfsproto.x 

nfsproto_svr.c: nfsproto.x
	rpcgen $(RPCOPTS) -m -o nfsproto_svr.c nfsproto.x 

nfsproto.h: nfsproto.x
	rpcgen $(RPCOPTS) -h -o nfsproto.h nfsproto.x

admproto_xdr.c: admproto.x
	rpcgen $(RPCOPTS) -c -o admproto_xdr.c admproto.x 

admproto_svr.c: admproto.x
	rpcgen $(RPCOPTS) -m -o admproto_svr.c admproto.x 

admproto.h: admproto.x
	rpcgen $(RPCOPTS) -h -o admproto.h admproto.x

admproto_clnt.c: admproto.x
	rpcgen $(RPCOPTS) -l -o admproto_clnt.c admproto.x 

clean:
	rm -f $(OBJS) $(COBJS) $(OTHERS)
	rm -f cfsd cmkdir cattach cpasswd cdetach cname ccat
	rm -f $(EOBJS) esm

tarfile: cfs.tar.gz

sharfile: cfs.shar

cfs.tar.gz: $(SRCS) $(ESRCS) $(MANS)
	rm -f cfs.tar.gz "cfs.`cat VERSION`.tar.gz"
	tar cf cfs.tar $(SRCS) $(ESRCS) $(MANS)
	gzip cfs.tar
	ln cfs.tar.gz "cfs.`cat VERSION`.tar.gz"

cfs.shar: $(SRCS) $(ESRCS) $(MANS)
	rm -f cfs.shar "cfs.`cat VERSION`.shar"
	shar $(SRCS) $(ESRCS) $(MANS)  > cfs.shar
	ln cfs.shar "cfs.`cat VERSION`.shar"

printout: $(SRCS) cfs.h safer.h admproto.h nfsproto.h
	$(PRINTCMD) $(SRCS) cfs.h safer.h admproto.h nfsproto.h

install_cfs: cfsd cattach cdetach cmkdir
	install -m 0755 -c -o root cfsd $(ETCDIR)
	install -m 0755 -c -o root cattach cdetach cmkdir cpasswd cfssh \
                cname ccat cmkkey $(BINDIR)
#	install -m 0755 i o $(BINDIR)
	@echo "Kill any running cfsd prior to restarting."
	@echo "See the README file for more information."
	@echo "Don't forget to install the man pages (*.[18])."


