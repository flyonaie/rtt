dnl Autoconf macros use the AC_ prefix, Automake macros use
dnl the AM_ prefix. Our extensions use the ACX_ prefix when
dnl they are general enough to be used outside of the project.
dnl The OROCOS_ prefix is used for Orocos specific macros.
dnl
dnl 

m4_define([DETECT_BOOSTPKG],[
AC_LANG_CPLUSPLUS
# Check for boost
AC_CHECK_HEADERS([boost/call_traits.hpp],
[
ORO_BOOST_DETECT=1
PACKAGES="support/boost/current/boost.cdl $PACKAGES"
],
[
ORO_BOOST_DETECT=0
AC_MSG_WARN([

Could not find Boost headers. Please install Boost.

You can find Boost at http://www.boost.org/
or if you are a Debian GNU/Linux user, just do:

apt-get install libboost-dev

and rerun the configure script
])
])
# Check for boost Graph
AC_CHECK_HEADERS([boost/graph/adjacency_list.hpp],
[
   ORO_BOOST_GRAPH_DETECT=1
],
[
   ORO_BOOST_GRAPH_DETECT=0
AC_MSG_WARN([

Could not find the Boost Graph Library headers.
Please install Boost and Boost Graph.

You can find Boost at http://www.boost.org/
or if you are a Debian GNU/Linux user, just do:

apt-get install libboost-graph-dev

and rerun the configure script
])
])
# Check for boost Spirit
AC_CHECK_HEADERS([boost/spirit.hpp],
[
   ORO_BOOST_PARSER_DETECT=1
],
[
   ORO_BOOST_PARSER_DETECT=0
AC_MSG_WARN([

Could not find the Boost Spirit Library headers.
Please install Boost and Boost Spirit.

You can find Boost at http://www.boost.org/
or if you are a Debian GNU/Linux user, just do:

apt-get install libboost-dev

and rerun the configure script
])
])
AC_LANG_C

AC_SUBST(ORO_BOOST_DETECT)
AC_SUBST(ORO_BOOST_GRAPH_DETECT)
AC_SUBST(ORO_BOOST_PARSER_DETECT)
])




m4_define([DETECT_XERCESCPKG],
[
AC_LANG_CPLUSPLUS

AC_CHECK_HEADERS([ xercesc/sax2/SAX2XMLReader.hpp ],
[
PACKAGES="support/xercesc/current/xercesc.cdl $PACKAGES"
],
[
  AC_MSG_WARN([
No Xerces-C 2.X installation found.
XML parsing will be unavailable.

To install Xerces-C, Debian users can do :
apt-get install libxerces21-dev 

and rerun the bootstrap.sh script
])
  AC_LANG_C
])
])



m4_define([DETECT_COMEDIPKG],
[
AC_CHECK_HEADERS([ comedilib.h ],
[
PACKAGES="support/comedi/current/comedi.cdl $PACKAGES"
COMEDI_DIR="."
],
[

#
# THIS part only done if comedilib.h is not in default include path !

AC_MSG_CHECKING(for Comedi dir)
AC_ARG_WITH(comedi, [ AC_HELP_STRING([--with-comedi=/usr/src/comedi/include],[Specify location of comedilib.h ]) ],
	            [ if test x"$withval" != xyes; then COMEDI_DIR="$withval";fi],[ COMEDI_DIR="/usr/src/comedi/include" ])

if test -f $COMEDI_DIR/comedilib.h; then
  # gnu linux comedilib
  PACKAGES="support/comedi/current/comedi.cdl $PACKAGES"
  CPPFLAGS="-I$COMEDI_DIR"
  AC_MSG_RESULT(gnulinux header found in $COMEDI_DIR)
else
  if test -f $COMEDI_DIR/linux/comedilib.h; then
    # lxrt comedi package
    PACKAGES="support/comedi/current/comedi.cdl $PACKAGES"
    CPPFLAGS="-I$COMEDI_DIR"
    AC_MSG_RESULT(lxrt header found in $COMEDI_DIR/linux)
  else
    # no comedi found
    AC_MSG_RESULT(not found)
   #AC_MSG_WARN([No comedi installation found !
   #(tried : $COMEDI_DIR/comedilib.h and $COMEDI_DIR/linux/comedilib.h).
   #Comedi will be unavailable.])
  fi
fi
])
AC_SUBST(COMEDI_DIR)
])


m4_define([DETECT_CORBAPKG],
[
AC_MSG_CHECKING(for ace dir)
AC_ARG_WITH(ace, [ AC_HELP_STRING([--with-ace=/usr/include],[Specify location of ace/config-all.h ]) ],
	[ if test x"$withval" != xyes; then ACE_DIR="$withval";fi],[ ACE_DIR="/usr/include" ])
AC_MSG_CHECKING(for tao dir)
AC_ARG_WITH(tao, [ AC_HELP_STRING([--with-tao=/usr/include],[Specify location of tao/ORB.h ]) ],
	[ if test x"$withval" != xyes; then TAO_DIR="$withval";fi],[ TAO_DIR="/usr/include" ])

if [ test -f $ACE_DIR/ace/config-all.h && test -f $TAO_DIR/tao/ORB.h ] ; then
  # corbalib
  PACKAGES="support/corba/current/corba.cdl $PACKAGES"
  CPPFLAGS="-I$ACE_DIR -I$TAO_DIR"
  AC_MSG_RESULT(Ace/Tao headers found)
else
  # no corba found
  AC_MSG_RESULT(not found)
  AC_MSG_WARN([No ace/tao installation found !
   (tried : $ACE_DIR/ace/config-all.h and $TAO_DIR/tao/ORB.h).
   Corba will be unavailable.])
fi
AC_SUBST(ACE_DIR)
AC_SUBST(TAO_DIR)
])


m4_define([DETECT_READLINE],
[
AC_CHECK_HEADERS([ readline/readline.h ],
[
PACKAGES="support/readline/current/readline.cdl $PACKAGES"
],
[
  AC_MSG_WARN([
No readline installation found (readline/readline.h). 
Readline will be unavailable.

To install GNU Readline, Debian users can do :
apt-get install libreadline4-dev 

and rerun the bootstrap.sh script
])
])
])

m4_define([DETECT_GCC],
[
AC_MSG_CHECKING(for GCC version)
ORO_GCC_VERSION=gcc`$CC -dumpversion | sed "s/\./ /g" |awk '{ print $1 }' `
AC_SUBST(ORO_GCC_VERSION)

PACKAGES="support/gcc/current/gcc.cdl $PACKAGES"
AC_MSG_RESULT($ORO_GCC_VERSION)
])



m4_define([DETECT_RTAI],
[
AC_MSG_CHECKING(for RTAI/LXRT Installation)
AC_ARG_WITH(rtai, [ --with-rtai[=/usr/realtime] Specify location of RTAI/LXRT ],
	[ if test x"$withval" != xyes; then RTAI_DIR="$withval"; fi ])
AC_ARG_WITH(lxrt, [ --with-lxrt[=/usr/realtime] Equivalent to --with-rtai ],
	[ if test x"$withval" != xyes; then RTAI_DIR="$withval"; fi ])
AC_ARG_WITH(linux,
	 [AC_HELP_STRING([--with-linux],[Specify RTAI-patched Linux directory (without /include).])],
	 [ if test x"$withval" != xyes; then LINUX_KERNEL_DIR="$withval"; fi ])

if test x"$RTAI_DIR" = x; then
   RTAI_DIR="/usr/realtime"
fi
if test x"$LINUX_KERNEL_DIR" = x; then
   LINUX_KERNEL_DIR="/usr/src/linux"
fi
LINUX_KERNEL_HEADERS="$LINUX_KERNEL_DIR/include"
AC_MSG_RESULT($RTAI_DIR with kernel headers in $LINUX_KERNEL_HEADERS)

AC_SUBST(RTAI_DIR)
AC_SUBST(LINUX_KERNEL_HEADERS)
AC_SUBST(LINUX_KERNEL_DIR)

CPPFLAGS="-I$RTAI_DIR/include -I$LINUX_KERNEL_HEADERS"
AC_CHECK_HEADERS([rtai_config.h], [
  AC_CHECK_HEADERS([rtai_lxrt.h],
  [
    PACKAGES="support/rtai/current/rtai.cdl $PACKAGES"
    RTAI_VERSION=3
  ],
  [
    AC_MSG_WARN([No RTAI/LXRT installation found (rtai_config.h, rtai_lxrt.h). LXRT will be unavailable.])
  ])
],[
dnl try old rtai style
  AC_CHECK_HEADERS([rtai_lxrt_user.h], 
  [
    PACKAGES="support/rtai/current/rtai.cdl $PACKAGES"
    RTAI_VERSION=2
  ],
  [
    AC_MSG_WARN([No RTAI/LXRT installation found ( rtai_lxrt_user.h ). LXRT will be unavailable.])
  ])
])
if test x"$RTAI_VERSION" = x; then
   RTAI_VERSION=0
fi
AC_SUBST(RTAI_VERSION)
])

m4_define([DETECT_XENOMAI],
[
AC_MSG_CHECKING(for XENOMAI 2.0 Installation)
AC_ARG_WITH(xenomai, [ --with-xenomai[=/usr/realtime] Specify location of XENOMAI ],
	[ if test x"$withval" != xyes; then XENOMAI_DIR="$withval"; fi ])

if test x"$XENOMAI_DIR" = x; then
   XENOMAI_DIR="/usr/realtime"
fi

AC_MSG_RESULT($XENOMAI_DIR with kernel headers in $LINUX_KERNEL_HEADERS)

AC_SUBST(XENOMAI_DIR)

CPPFLAGS="-I$XENOMAI_DIR/include -I$LINUX_KERNEL_HEADERS"
AC_CHECK_HEADERS([xeno_config.h], [
    PACKAGES="support/xenomai/current/xenomai.cdl $PACKAGES"
    XENOMAI_VERSION=2
],[])
if test x"$XENOMAI_VERSION" = x; then
   XENOMAI_VERSION=0
fi
AC_SUBST(XENOMAI_VERSION)
])



dnl ACX_VERSION(MAJOR-VERSION,MINOR-VERSION,MICRO-VERSION,BUILD-NUMBER)
dnl Define the version number of the package
dnl Format: MAJOR.MINOR.MICRO-BUILD
dnl Written in M4 because AC_INIT arguments must be static but may
dnl use M4 processing.
m4_define([ACX_VERSION],[
 define([acx_major_version],[$1])
 define([acx_minor_version],[$2])
 define([acx_micro_version],[$3])
 define([acx_version],[acx_major_version.acx_minor_version.acx_micro_version])
]) # ACX_VERSION






dnl ACX_VERSION_POST()
dnl Post init of Autoconf version number stuff
m4_define([ACX_VERSION_POST],[
 MAJOR_VERSION=acx_major_version
 MINOR_VERSION=acx_minor_version
 MICRO_VERSION=acx_micro_version

 SVN=$(which svn)

 AC_MSG_CHECKING(for subversion)
 AC_ARG_ENABLE(subversion,
     [  --enable-subversion    Add a sub-version number (default=no) ],
     [ case "${enableval}" in
       yes) subvsn=yes ;;
       no)  subvsn=no ;;
       *) AC_MSG_ERROR(bad value ${subvsn} for --enable-subversion) ;;
     esac],[ subvsn=no ])

 if test x$subvsn = xyes -a x$SVN != x; then

 echo "{ print $""2  }" > print-svn.awk
 SVN_VERSION=$(svn info . 2>/dev/null \
	| grep "Revision" | awk -f print-svn.awk )
 fi;
 rm -f print-svn.awk

 if test x$SVN != x; then
    if test $subvsn = yes; then
	 BUILD=-$SVN_VERSION
	 AC_MSG_RESULT( yes -$SVN_VERSION )
    else
	 AC_MSG_RESULT( yes )
    fi;         
 else
	 AC_MSG_RESULT( no )
 fi;

 DATE=`date +"%Y%m%d_%k%M"`
 VERSION=acx_version
 VERSION="$VERSION$BUILD"
 PACKAGE_VERSION=$VERSION
 AC_SUBST(MAJOR_VERSION)
 AC_SUBST(MINOR_VERSION)
 AC_SUBST(MICRO_VERSION)
 AC_SUBST(VERSION)
 AC_SUBST(PACKAGE_VERSION)
 AC_SUBST(DATE)
 AC_SUBST(BUILD)
]) # ACX_VERSION_POST


dnl OROCOS_INIT(name,major,minor,micro)
m4_define([PACKAGES_INIT],[
# Define the version number of the package
# Format: major,minor,micro,build
ACX_VERSION($2,$3,$4)

# Check if Autoconf version is recent enough
AC_PREREQ(2.53)

# Include version control information
AC_REVISION($revision)

# Initialize Autoconf with package name and version
AC_INIT($1,acx_version)

ACX_VERSION_POST

# Tell Autoconf to dump files into the config subdir
#AC_CONFIG_AUX_DIR(config)
#AC_CONFIG_SRCDIR([config.h.in])
#AM_CONFIG_HEADER([config.h])

dnl Initialize Automake
#AM_INIT_AUTOMAKE(1.7.1)

dnl Default installation path
#AC_PREFIX_DEFAULT([/usr/local/orocos])
dnl Checks for programs.
#AC_PROG_AWK
#AC_PROG_INSTALL
#AC_PROG_RANLIB
#AC_PROG_XMLPROCESSOR
#AC_PROG_DOXYGEN

dnl Work around dirty Autoconf -g -02 bug
if test $CFLAGS; then
 ACX_CFLAGS="$CFLAGS"
fi
if test $CXXFLAGS; then
 ACX_CXXFLAGS="$CXXFLAGS"
fi

AC_PROG_CXX
AC_PROG_CC

CFLAGS=""
CXXFLAGS=""
dnl End work around

ORO_CFLAGS=$ACX_CFLAGS
ORO_CXXFLAGS=$ACX_CXXFLAGS

AC_SUBST(ORO_CFLAGS)
AC_SUBST(ORO_CXXFLAGS)
])

m4_define([PACKAGES_OUTPUT_INFO],[
echo "
************************************************************
 Configuration:
   Version:                             ${VERSION}
   Generated Packages:                  ${PACKAGES}
************************************************************
"
echo "
The configure script
made some pseudo packages which inform the ecos system what is 
installed on your system. You should only re-run the bootstrap.sh script if
you have installed new libraries.
"
])



m4_define([PACKAGES_OUTPUT],[
AC_OUTPUT
PACKAGES_OUTPUT_INFO
])

