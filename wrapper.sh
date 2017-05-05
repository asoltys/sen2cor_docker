#!/bin/bash

if [ $# -eq 0 ]
  then
	echo "Error: No arguments supplied - you need to specify the folder name under /data/LEVEL1_DATA/SENTINEL2 to process"
	echo "eg: ./run.sh L1C_OPER_a4811fc1-8e23-4a35-b5a4-42d7edd111ef"
	exit 1
fi

if [[ -z "$1" ]]
then
	echo "Error: you need to specify the folder name under /data/LEVEL1_DATA/SENTINEL2  to process!"
	echo "eg: ./run.sh L1C_OPER_a4811fc1-8e23-4a35-b5a4-42d7edd111ef"
	exit 1
fi

# remove trailing slash from the directory. ref: http://stackoverflow.com/a/1848456
incln=${1%/}
srcdir="/_host/data/LEVEL1_DATA/SENTINEL2/$incln"

if [[ ! -d "$srcdir"  ]]
then
	echo "Error: source directory in docker container not found - {$srcdir}"
	exit 1
fi

if [[ ! -f "$srcdir/INSPIRE.xml" ]]
then
	echo "Error: INSPIRE.xml file not found in docker container directory $srcdir/INSPIRE.xml"
	exit 1
fi

# make required directories for Sen2Cor to run
mkdir -p  "$srcdir/AUX_DATA"
mkdir -p "$srcdir/HTML"
mkdir -p "$srcdir/rep_info"

# make sure each granule directory has an AUX_DATA dir
find "$srcdir"  -maxdepth 2 -type d -wholename '*GRANULE*_T*' -exec mkdir {}/AUX_DATA \;


safefn="$(grep .SAFE $srcdir/INSPIRE.xml | sed -e 's/<[^>]*>//g' | sed -e 's/^[ \t]*//')"

# fix the "KeyError: 'gfs'" error by deleting all gfs files. ref: http://forum.step.esa.int/t/sen2cor-keyerror-gfs/2801/10
find "$srcdir"  -type f -name '*.gfs' -delete


# echo "=${safefn}="
l1dir="/_host/data/temp/$safefn"
if [[ ! -L "$l1dir"  ]]
then
	ln -s $srcdir $l1dir
	echo "soft linked $srcdir to $l1dir"
fi
echo "Ready to run L2A_Process on $l1dir"

source /root/sen2cor/L2A_Bashrc

L2A_Process $l1dir --resolution=10


echo "Done wrapper.sh for now."


