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

#echo "Run: " $0 $root $up $upn $parent

for i in $root/*.inx; do 
	#echo "d="`pwd`", i=" $i
	to=${i}_2;
	t2=`dirname $i`/`basename $i .inx`.html;
	if [ -f $i ]; then
		#echo "from " $i " to " $to
		cat $i \
			| awk -v m="@MENU@" '
				BEGIN { pp=1; } 
				{ if (index($0, m) > 0) { pp=0; } } 
				{ if ( pp>0 ) print $0; } 
			'\
			> $to
		echo "<DIV ID=\"menu\">" >> $to
		cat $root/.files.xml >> $to
		echo "</DIV>" >> $to
		cat $i \
			| awk -v m="@MENU@" '
				BEGIN { pp=0; } 
				{ if ( pp>0 ) print $0; } 
				{ if (index($0, m) > 0) { pp=1; } } 
			'\
			>> $to

		#echo "from " $to " to " ${t2}~
		cat $to \
			| awk '/@FOOTER@/ { print "<p>Return to <a href=\"%up%index.html\">Homepage</a></p>"; }
				{ print $0; }' \
			| sed -e "s/@EMAIL@/afachat@gmx.de/g" \
			| sed -e "s%@CBMARC@%http://www.zimmers.net/anonftp/pub/cbm%g" \
			| sed -e "s/@[a-zA-Z0-9]*@//g" \
			| sed -e "s@%up%@$up@g" \
			> ${t2}~

		if [ ! -f ${t2} ]; then
			cp ${t2}~ ${t2};
		else
			diff -q ${t2} ${t2}~
				if [ $? -eq 1 ]; then
				cp ${t2}~ ${t2};
			fi
		fi;
		rm $i $to ${t2}~
	fi;
done

if [ -f $root/.files ]; then
    for i in `cat $root/.files | grep "^d " | cut -d " " -f 2`; do
	"$0" $root/$i $up../ $(($upn+1)) $i
	rm -f $root/$i/.files.xml
    done;
fi

rm -f $root/.files.xml


