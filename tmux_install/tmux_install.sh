#!/bin/bash

# Script to install tmux from source, without root access.
# x.veiga@udc.es

LIBDIR=$HOME/.local
TEMPDIR=$HOME/tmp
#KEEP_FILES=1 # Uncomment to keep temporary files in $TEMPDIR
#KEEP_DEV=1 # Uncomment to keep library development files in $LIBDIR/include.
#NTHREADS=2 # Leave commented for auto
# Temp dir
function create_dir {
	if [ ! -d $TEMPDIR ]; then
		mkdir $TEMPDIR
	fi
	cd $TEMPDIR
}

# Export vars, missing lib fix
function export_vars {
	export LD_LIBRARYPATH=$LD_LIBRARY_PATH:$LIBDIR/lib
	export LD_LIBRARY_PRELOAD=$LD_LIBRARY_PRELOAD:$LIBDIR/lib
}

# Thread calc
function thread_calc {
	if [ -z $NTHREADS ]; then
		NTHREADS=$(grep -c ^processor /proc/cpuinfo)
	fi
}
thread_calc

# Libevent
function libevent_install {
	if [ ! -f libevent-2.1.8-stable.tar.gz ]; then
		wget "https://github.com/libevent/libevent/releases/download/release-2.1.8-stable/libevent-2.1.8-stable.tar.gz"
	fi
	tar xvf "libevent-2.1.8-stable.tar.gz"
	cd libevent-2.1.8-stable
	./configure --prefix=$LIBDIR
	make -j $NTHREADS
	make install
	cd ..
}

# Ncurses
function ncurses_install {
	if [ ! -f ncurses-6.1.tar.gz ]; then
		wget "https://ftp.gnu.org/pub/gnu/ncurses/ncurses-6.1.tar.gz"
	fi
	tar xvf "ncurses-6.1.tar.gz"
	cd ncurses-6.1
	./configure --prefix=$LIBDIR
	make -j $NTHREADS
	make install
	cd ..
}

# Tmux
function tmux_install {
	if [ ! -f tmux-2.6.tar.gz ]; then
		wget "https://github.com/tmux/tmux/releases/download/2.6/tmux-2.6.tar.gz"
	fi
	tar xvf "tmux-2.6.tar.gz"
	cd tmux-2.6
	./configure --prefix=$LIBDIR CFLAGS="-I$LIBDIR/include -I$LIBDIR/include/ncurses" LDFLAGS="-L$LIBDIR/lib"
	make -j $NTHREADS
	make install
	cd ..
}

# Append to .profile or .bashrc
#export PATH=$LIBDIR/bin:$PATH
#export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$LIBDIR/lib
function append_vars {
	if [ -f $HOME/.bashrc ]; then
		if [ -z "$(cat $HOME/.bashrc | grep "export PATH=$LIBDIR/bin:\$PATH")" ]; then
			echo "export PATH=$LIBDIR/bin:\$PATH" >> $HOME/.bashrc
		fi
		if [ -z "$(cat $HOME/.bashrc | grep "LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:$LIBDIR/lib")" ]; then
			echo "export LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:$LIBDIR/lib" >> $HOME/.bashrc
		fi

	elif [ -f $HOME/.profile ]; then
		if [ -z "$(cat $HOME/.profile | grep "export PATH=$LIBDIR/bin:\$PATH")" ]; then
			echo "export PATH=$LIBDIR/bin:\$PATH" >> $HOME/.profile
		fi
		if [ -z "$(cat $HOME/.profile | grep "LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:$LIBDIR/lib")" ]; then
			echo "export LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:$LIBDIR/lib" >> $HOME/.profile
		fi
	else
		touch "$HOME/.profile"
		echo "export PATH=$LIBDIR/bin:\$PATH" >> $HOME/.profile
		echo "export LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:$LIBDIR/lib" >> $HOME/.profile
	fi
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
export_vars      # Export environment vars
libevent_install # Install libevent
ncurses_install  # Install ncurses
tmux_install     # Install tmux
append_vars      # Save new environment vars in .bashrc or .profile
cleanup          # Delete temporary and/or unnecessary files.
