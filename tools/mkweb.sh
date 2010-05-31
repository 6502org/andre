#!/bin/sh

# create the web page
# 1) create the menu
# 2) create the *.in files from the .bxml files (if newer)
# 3) create the html files by merging the menu with the .in files
#
# parameters:
# 1) web directory (default:".")
#

dir="."
if [ $# -ge 1 ]; then 
   dir=$1;
fi;

bin=`dirname $0`

echo "making web: " $dir
echo "bindir= " $bin

############################################
# 1) create the menu and breadcrumb files

$bin/files2menu.sh $dir


############################################
# 2) create the *.inx files from the sources

# .in -> .inx
$bin/doinx.sh -f $dir

# .bxml -> .inx
$bin/doxsl.sh -f $dir

############################################
# 3) create the html files by merging the menu with the .in files

$bin/in2html.sh $dir

