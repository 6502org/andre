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

echo "Run: " $0 $root $up $upn $parent

if [ -f $root/.files ]; then
    cat $root/.files \
	| awk -v upn="$upn" ' \
		BEGIN { print "<ul div=\"menu" upn "\" >"; } \
		/^s / { print "<li>" substr($0, 3) "</li>"; }\
		/^f / { print "<li><img src=\"%up%imgs/file.gif\"/><a href=\"%up%" $2 "\">" substr($0, 4+length($2)) "</a></li>"; }\
		/^d / { print "<li><img src=\"%up%imgs/dir.gif\"/><a href=\"%up%" $2 "/index.html\">" substr($0, 4+length($2)) "</a></li>"; print "@" $2 "@"; }\
		END { print "</ul>"; } \
	' \
	> $root/.files.xml
else
    echo "<ul div=\"menu"$upn"\"><li><img src=\"%up%imgs/file.gif\"/><a href=\"index.html\">Start</a></li></ul>" > $root/.files.xml
fi

if [ "x$parent" != "x" ]; then
	cat $root/../.files.xml2 \
		| awk -v m="$parent" '
			BEGIN { pp=1; } 
			{ if ( pp>0 ) print $0; } 
			{ if (index($0, m) > 0) { pp=0; } } 
		'\
		| sed -e "s/@[a-zA-Z0-9]*@//g" \
		> $root/.files.xml2
	cat $root/.files.xml >> $root/.files.xml2
	cat $root/../.files.xml2 \
		| awk -v m="$parent" '
			BEGIN { pp=0; } 
			{ if ( pp>0 ) print $0; } 
			{ if (index($0, m) > 0) { pp=1; } } 
		'\
		| sed -e "s/@[a-zA-Z0-9]*@//g" \
		>> $root/.files.xml2
else
	cp $root/.files.xml $root/.files.xml2
fi

if [ -f $root/.files ]; then
    for i in `cat $root/.files | grep "^d " | cut -d " " -f 2`; do
	#  if [ "x$i" != "x" -a -f $root/$i/.files ]; then 
	"$0" $root/$i $up../ $(($upn+1)) $i
	#  fi
    done;
fi

cat $root/.files.xml2 \
	| sed -e "s/@[a-zA-Z0-9]*@//g" \
	| sed -e "s@%up%@$up@g" \
	> $root/.files.xml

# test 
#echo "<html><body>" > $root/.files.html
#cat $root/.files.xml >> $root/.files.html
#echo "</body></html>" >> $root/.files.html
rm -f $root/.files.html

rm $root/.files.xml2 



