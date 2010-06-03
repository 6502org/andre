#!/bin/sh

# parameter
# 1) web dir


# insert a text in the middle at the position of a keyword
# using two methods:
#
# doinsert1() - split out the first part of the file
# doinsert2() - split out the second part of the file
#
# params:
#   from        - where to read the orig file from
#   to          - where to write the new file to
#   key         - keyword
#
function doinsert1 () {
        from="$1"
        tox="$2"
        key="$3"
                cat $from \
                        | awk -v m="$key" '
                                BEGIN { pp=1; }
                                { if (index($0, m) > 0) { pp=0; } }
                                { if ( pp>0 ) print $0; }
                        '\
                > $tox
        diff -q $from $tox > /dev/null
        rv=$?
        return $rv
}
function doinsert2 () {
        from="$1"
        tox="$2"
        key="$3"
                cat $from \
                        | awk -v m="$key" '
                                BEGIN { pp=0; }
                                { if ( pp>0 ) print $0; }
                                { if (index($0, m) > 0) { pp=1; } }
                        '\
                >> $tox
}


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

for i in `find $dir -name \*.in`; do 
	to=`dirname $i`/`basename $i .in`.inx
	echo $i " -> " $to;
	if [ $force = "true" -o $i -nt $to ]; then
		doinsert1 $i $to "@MENU@"
		echo "<div id=\"menu\">" >> $to
		echo "@MENU@" >> $to
		echo "</div>" >> $to
		doinsert2 $i $to "@MENU@"
		#cat $i > $to
	#else 
		#echo "not newer!"
	fi
done

