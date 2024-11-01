#!/bin/sh

# parameter
# 1) web dir

force="false"
if [ $# -ge 1 ]; then
	if [ "x$1" = "x-f" ]; then
		force="true"
		shift
	fi
fi

dir="."
if [ $# -ge 1 ]; then
   dir=$1;
fi;

bin=`dirname $0`

echo "xslt: force=" $force

for i in `find $dir -name \*.bxml`; do 
	to=`dirname $i`/`basename $i .bxml`.inx
	echo $i " -> " $to;
	if [ $force = "true" -o $i -nt $to ]; then
		# last modified date
		DATE=`git log -1 --format=%cd --date=short $i`
                if [ -x "/usr/bin/xsltproc" ]; then
			xsltproc -stringparam date "$DATE" $bin/indexml2html2.xsl $i > $to;
		else
			# NOTE: last modified date not set!
			xsl-c -xsl $bin/indexml2html2.xsl -in $i -html -out $to;
		fi;
	else 
		echo "not newer!"
	fi
done

