#!/bin/sh

bin="$0"
root="$1" 
xup="$2"
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

function buildbread () {

	#echo "buildbread rroot=" $1 ", level="$2 ", <p/>"

	if [ -f $1/../.name.xml ]; then
		buildbread $1/.. ../$2
	else
		if [ -f $1/.name.xml ]; then 
			echo "<a href=\"../"$2"index.html\">Homepage</a>"
		else
			echo "Homepage"
		fi;
	fi;

#	if [ -f $1/.name.xml ]; then 
	    if [ "x$2" = "x" ]; then
		# bottom level
		echo -n '&gt;&gt; '
		cat $1/.name.xml
	    else
		# not bottom level
		echo -n '&gt;&gt;'" <a href=\""$2"index.html\">"
		cat $1/.name.xml
		echo -n "</a>"
	    fi;
#	fi;
}

id=`echo "$root" \
	| sed -e 's%^.%m%g' \
	| sed -e 's%/%_%g'`

#echo "ID=" $id;

if [ -f $root/.files ]; then
    cat $root/.files \
	| awk -v upn="$upn" -v xup="$xup" ' \
		BEGIN { print "<ul class=\"menu" upn "\" >"; } \
		/^s / { print "<li class=\"separator\">" substr($0, 3) "</li>"; }\
		/^f / { print "<li class=\"file\"><img src=\"%xup%imgs/file.png\"/><a href=\"%up%" $2 "\">" substr($0, 4+length($2)) "</a></li>"; }\
		/^l / { print "<li class=\"link\"><img src=\"%xup%imgs/link.png\"/><a href=\"%up%" $2 "\">" substr($0, 4+length($2)) "</a></li>"; }\
		/^d / { print "<li class=\"dir\" id=\"%id%_"$2"\"><img src=\"%xup%imgs/dir.png\"/><a href=\"%up%" $2 "/index.html\">" substr($0, 4+length($2)) "</a>";\
			print "@" $2 "@</li>"; }\
		/^p / { print "<li class=\"file\"><img src=\"%xup%imgs/file.png\"/><a href=\"%up%" $2 "/index.html\">" substr($0, 4+length($2)) "</a>";\
			print "</li>"; }\
		END { print "</ul>"; } \
	' \
	> $root/.files.xml
    
else
    echo "" > $root/.files.xml
#    echo "<li class=\"openfile\">index.html</li>" > $root/.files.xml
fi

# .menu.xml only needed when there actually is a menu. current directory must not have "d" but "p" in .files entry!
if [ -f $root/.files ]; then
   cat $root/.files.xml \
	| sed -e "s@%id%@$id@g" \
	| sed -e "s/@[a-zA-Z0-9]*@//g" \
	> $root/.menu.xml
fi;

if [ -f $root/../.files.xml2 ]; then
	cat $root/../.files.xml2 \
		| awk -v m="$parent" '
			BEGIN { pp=1; } 
			{ if ( pp>0 ) print $0; } 
			{ if (index($0, m) > 0) { pp=0; } } 
		'\
		| sed -e "s/@[a-zA-Z0-9]*@//g" \
		| sed -e "s@%up%@../%up%@g" \
		> $root/.files.xml2
	cat $root/.files.xml \
		| sed -e "s@%id%@$id@g" \
		>> $root/.files.xml2
	cat $root/../.files.xml2 \
		| awk -v m="$parent" '
			BEGIN { pp=0; } 
			{ if ( pp>0 ) print $0; } 
			{ if (index($0, m) > 0) { pp=1; } } 
		'\
		| sed -e "s/@[a-zA-Z0-9]*@//g" \
		| sed -e "s@%up%@../%up%@g" \
		>> $root/.files.xml2

else
	echo "<a class=\"m_homepage\" href=\"%up%index.html\">Homepage</a>" > $root/.files.xml2
	cat $root/.files.xml \
		| sed -e "s@%id%@$id@g" \
		>> $root/.files.xml2
		#| sed -e "s@%up%@../%up%@g" \
	echo "" >> $root/.files.xml2
fi

if [ -f $root/.files ]; then
    for i in `cat $root/.files | grep "^[pd] " | cut -d " " -f 2`; do

	# extract name
	name=`cat $root/.files | grep "^[pd] $i " | cut -d " " -f 3-`;
	#echo "i=" $i ", name="$name;
	echo $name > $root/$i/.name.xml;
	
	# build breadcrumbs from name
	buildbread $root/$i > $root/$i/.bread.xml

	# recursively continue
	#  if [ "x$i" != "x" -a -f $root/$i/.files ]; then 
	"$0" $root/$i $up../ $(($upn+1)) $i
	#  fi

	# cleanup name.xml
	rm -f $root/$i/.name.xml
    done;
fi

cat $root/.files.xml2 \
	| sed -e "s/@[a-zA-Z0-9]*@//g" \
	| sed -e "s@%up%@@g" \
	| sed -e "s@%xup%@$xup@g" \
	> $root/.files.xml

# test 
#echo "<html><body>" > $root/.files.html
#cat $root/.files.xml >> $root/.files.html
#echo "</body></html>" >> $root/.files.html
rm -f $root/.files.html

rm $root/.files.xml2 



