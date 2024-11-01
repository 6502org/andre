#!/bin/sh

# create the web page
# 1) create the menu
# 2) create the *.in files from the .bxml files (if newer)
# 3) create the html files by merging the menu with the .in files
#
# parameters:
# 1) web directory (default:".")
#

dir="."; #"`dirname $0`/../public"
if [ $# -ge 1 ]; then 
   dir=$1;
fi;

bin=`dirname $0`

echo "making web: " $dir
echo "bindir= " $bin

############################################
# 1) create the menu and breadcrumb files

$bin/files2menu2.sh $dir


############################################
# 2) create the *.inx files from the sources

# .in -> .inx
#$bin/doinx.sh -f $dir

# .bxml -> .inx
$bin/doxsl2.sh -f $dir

############################################
# 3) create the html files by merging the menu with the .in files

$bin/in2html2.sh $dir

############################################
# 4) create the compressed js and css files
(cd $bin; ./doJsCss.sh)

############################################
# 5) create sprite image
# Not done automatically - always modifies sprite image even if not changed!
#(cd $bin; ./doSprite.sh)


