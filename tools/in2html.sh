#!/bin/sh

bin="$0"
root="$1" 
up=""
upn=0
parent=""

if [ $# -ge 2 ]; then
   up="$2";
fi
if [ $# -ge 3 ]; then
   upn="$3";
fi
if [ $# -ge 4 ]; then
   parent="$4";
fi

function print_disclaimer () {
	echo "All Copyrights are acknowledged."
	echo "The information here is provided under the terms of the"
	echo "GNU Public License version 2 unless noted otherwise."
}

# insert a text in the middle at the position of a keyword
# using two methods:
#
# doinsert1() - split out the first part of the file
# doinsert2() - split out the second part of the file
#
# params:
#   from	- where to read the orig file from
#   to		- where to write the new file to
#   key		- keyword
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

#echo "Run: " $0 $root $up $upn $parent

for i in $root/*.inx; do 
	#echo "d="`pwd`", i=" $i
	t2=${i}_2;
	t3=${i}_3;
	t4=${i}_4;
	to=`dirname $i`/`basename $i .inx`.html;
	if [ -f $i ]; then
		#echo "from " $i " to " $t2

		# insert menu
		doinsert1 $i $t2 "@MENU@"
		v=$?
		if [ $v -eq 1 ]; then
			echo "<DIV ID=\"menu\">" >> $t2
			cat $root/.files.xml >> $t2
			echo "</DIV>" >> $t2
			doinsert2 $i $t2 "@MENU@"
		fi

		# insert disclaimer
		doinsert1 $t2 $t3 "@DISCLAIMER@"
		v=$?
		if [ $v -eq 1 ]; then
			print_disclaimer >> $t3
			doinsert2 $t2 $t3 "@DISCLAIMER@" 
		fi

		#echo "from " $t3 " to " $t4
		cat $t3 \
			| awk '/@FOOTER@/ { print "<p>Return to <a href=\"%up%index.html\">Homepage</a></p>"; }
				{ print $0; }' \
			| sed -e "s/@EMAIL@/afachat@gmx.de/g" \
			| sed -e "s%@CBMARC@%http://www.zimmers.net/anonftp/pub/cbm%g" \
			| sed -e "s/@[a-zA-Z0-9]*@//g" \
			| sed -e "s@%up%@$up@g" \
			> $t4

		#echo "from " $t4 " to " $to
		if [ ! -f $to ]; then
			cp $t4 $to;
		else
			diff -q $to $t4
			if [ $? -eq 1 ]; then
				cp $t4 $to;
			fi
		fi;
		rm $i $t2 $t3 $t4
	fi;
done

if [ -f $root/.files ]; then
    for i in `cat $root/.files | grep "^d " | cut -d " " -f 2`; do
	"$0" $root/$i $up../ $(($upn+1)) $i
	rm -f $root/$i/.files.xml
    done;
fi

rm -f $root/.files.xml


