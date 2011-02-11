#!/bin/bash -x

set -e

vers=`grep AM_INIT_AUTOMAKE configure.ac | head -1 | cut '-d '  -f 2 | sed 's/)//'`
echo raw vers $vers

releasedir=$1
versionfile=$2
suffix=$3

[ -z "$releasedir" ] && echo specify releasedir && exit 1

if git diff --quiet ; then
    echo repository is clean
else
    echo
    echo "**** REPOSITORY IS DIRTY ****"
    echo
    if [ "$force" != "force" ]; then
	echo "add 'force' argument if you really want to continue."
	exit 1
    fi
    echo "forcing."
fi

if [ -z "$suffix" ]; then
    cephver="$vers"
else
    gitver=`git describe | cut -c 2-`
    cephver="$gitver"
fi

echo final vers $cephver

srcdir=`pwd`

if [ -d "$releasedir/$cephver" ]; then
    echo "$releasedir/$cephver already exists; reuse that release tarball"
else
    echo building tarball
    make dist

    echo extracting
    mkdir -p $releasedir/$cephver
    cd $releasedir/$cephver

    tar zxf $srcdir/ceph-$vers.tar.gz 
    [ "$vers" != "$cephver" ] && mv ceph-$vers ceph-$cephver
    tar zcf ceph_$cephver.orig.tar.gz ceph-$cephver
    cp -a ceph_$cephver.orig.tar.gz ceph-$cephver.tar.gz

    # copy debian dir, too
    cp -a $srcdir/debian debian
    cd $srcdir
fi

echo $cephver > $versionfile

echo "done. $cephver (written to $versionfile)"