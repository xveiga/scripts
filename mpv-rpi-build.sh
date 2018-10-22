#!/bin/bash

# Script to install mpv from source on a Raspberry Pi
# running Raspbian, with hardware decoding support.
# x.veiga@udc.es, 2018-16-02

TEMPDIR=/tmp/mpv_install

SUDOCMD="sudo " # Comment if executed with root privileges
#USE_DISTCC=1 # Uncomment to set distcc as compiler (to use multiple rpi's)
#USE_DISTCC_HOSTS='127.0.0.1 192.168.1.1';
KEEP_FILES=1 # Uncomment to keep temporary files in $TEMPDIR
NTHREADS=3 # Leave commented for auto

DEPENDENCIES="gperf bison flex autoconf automake make texinfo help2man libtool libtool-bin ncurses-dev git yasm mercurial cmake cmake-curses-gui libfribidi-dev checkinstall libfontconfig1-dev libgl1-mesa-dev libgles2-mesa-dev gnutls-dev libsmbclient-dev libpulse-dev libbluray-dev libdvdread-dev libluajit-5.1-dev libjpeg-dev libv4l-dev libcdio-cdda-dev libcdio-paranoia-dev"


# Temp dir
function create_dir {
	if [ ! -d $TEMPDIR ]; then
		mkdir $TEMPDIR
	fi
	cd $TEMPDIR
}

function distcc_check {	
	if [ -z $USE_DISTCC ]; then
		export CC=distcc
		export DISTCC_HOSTS=$USE_DISTCC_HOSTS
	fi
}

# Thread calc
function thread_calc {
	if [ ! -z $NTHREADS ]; then
		NTHREADS=$(grep -c ^processor /proc/cpuinfo)
	fi
}

function dependency_install {
	$SUDOCMD apt-get install -y $DEPENDENCIES
}

function mpv_build {
	git clone https://github.com/mpv-player/mpv-build.git
	cd mpv-build
	echo --enable-mmal >> ffmpeg_options
	./clean
	./use-mpv-release
	./use-ffmpeg-release
	./update
	./rebuild -j$NTHREADS
}

function mpv_install {
	$SUDOCMD ./install
}

function cleanup {
	if [ -z $KEEP_FILES ]; then
		rm -r $TEMPDIR	
	fi
	if [ -z $KEEP_DEV ]; then
		rm -rf $LIBDIR/include
	fi
}

# Install steps
create_dir       # Create tmp dir
dependency_install
mpv_build
mpv_install
cleanup          # Delete temporary and/or unnecessary files.
