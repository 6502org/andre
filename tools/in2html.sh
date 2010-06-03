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

function buildbread () {

        #echo "buildbread myname = $1, rroot=" $2 ", level="$3 ", <p/>"

        if [ -f $2/../.name.xml ]; then
                buildbread $1 $2/.. ../$3
        else
                if [ -f $2/.name.xml ]; then
                        echo "<a href=\""$3"index.html\">Homepage</a>"
                else
                        echo "Homepage"
                fi;
        fi;

        if [ "x$3" = "x" ]; then
                # bottom level
		if [ "$myname" != "index.html" ]; then
        	        x=`cat $2/.name.xml \
				| grep "^index.html" \
				| cut -d " " -f 2-`
			if [ "x$x" != "x" ]; then
                		echo -n '&gt;&gt; '
	                	echo -n " <a href=\""$3"index.html\">"
				echo $x;
	                	echo -n "</a>"
			fi;
		fi;
		x=`cat $2/.name.xml \
			| grep "^$myname" \
			| cut -d " " -f 2-`
		if [ "x$x" != "x" ]; then
                	echo -n '&gt;&gt;  '
			echo -n $x;
		fi;
        else
                # not bottom level
	        x=`cat $2/.name.xml \
			| grep "^index.html" \
			| cut -d " " -f 2-`
		if [ "x$x" != "x" ]; then
                	echo -n '&gt;&gt;'" <a href=\""$3"index.html\">"
			echo -n $x;
                	echo -n "</a>";
		fi;
        fi;
}

#echo "Run: " $0 $root $up $upn $parent

for i in $root/*.inx; do 
	#echo "d="`pwd`", i=" $i
	t2=${i}_2;
	t3=${i}_3;
	t4=${i}_4;
	t5=${i}_5;
	myname=`basename $i .inx`.html;
	to=`dirname $i`/$myname;
	if [ -f $i ]; then
		#echo "from " $i " to " $t2

		# insert menu
		doinsert1 $i $t2 "@MENU@"
		v=$?
		if [ $v -eq 1 ]; then
			echo "<div class=\"top\" ID=\"menu\">" >> $t2
			echo "<div class=\"tophead\">navigate</div>" >> $t2
			echo "<div id=\"filter\"></div>" >> $t2
			echo "<div>" >> $t2
			cat $root/.files.xml >> $t2
			echo "</div></div>" >> $t2
			doinsert2 $i $t2 "@MENU@"
		fi

		# insert disclaimer
		doinsert1 $t2 $t3 "@DISCLAIMER@"
		v=$?
		if [ $v -eq 1 ]; then
			print_disclaimer >> $t3
			doinsert2 $t2 $t3 "@DISCLAIMER@" 
		fi

		# insert breadcrumb
		doinsert1 $t3 $t4 "@BREAD@"
		v=$?
		if [ $v -eq 1 ]; then
#			if [ -f $root/.bread.xml ]; then
#				echo "<DIV class=\"top\" ID=\"breadcrumbs\">" >> $t4
#				cat $root/.bread.xml \
#					| sed -e "s@%up%@.@g" \
#					>> $t4
#				echo "</DIV>" >> $t4
#			else
#				echo "Breadcrumbs not found @ " `pwd` ", root=" $root
#			fi;
			if [ -f $root/.name.xml ]; then
				echo "<DIV class=\"top\" ID=\"breadcrumbs\">" >> $t4
				#cat $root/.name.xml \
				buildbread $myname $root \
					| sed -e "s@%up%@.@g" \
					>> $t4
				echo "</DIV>" >> $t4
			else
				echo "Breadcrumbs not found @ " `pwd` ", root=" $root
			fi;
			doinsert2 $t3 $t4 "@BREAD@"
		fi

		#echo "from " $t4 " to " $t5
		cat $t4 \
			| awk '/@FOOTER@/ { print "<p>Return to <a href=\"%up%index.html\">Homepage</a></p>"; }
				{ print $0; }' \
			| sed -e "s/@EMAIL@/afachat@gmx.de/g" \
			| sed -e "s%@XA@%http://www.floodgap.com/retrotech/xa/%g" \
			| sed -e "s%@CBMARC@%http://www.zimmers.net/anonftp/pub/cbm%g" \
			| sed -e "s/@[a-zA-Z0-9]*@//g" \
			| sed -e "s@%up%@$up@g" \
			> $t5

		#echo "from " $t5 " to " $to
		if [ ! -f $to ]; then
			cp $t5 $to;
		else
			diff -q $to $t5
			if [ $? -eq 1 ]; then
				cp $t5 $to;
			fi
		fi;
		rm $i $t2 $t3 $t4 $t5
	fi;
done

if [ -f $root/.files ]; then
    for i in `cat $root/.files | grep "^[pd] " | cut -d " " -f 2`; do
	"$0" $root/$i $up../ $(($upn+1)) $i
	rm -f $root/$i/.files.xml
	rm -f $root/$i/.bread.xml
	rm -f $root/$i/.name.xml
    done;
fi

rm -f $root/.files.xml
rm -f $root/.name.xml


