#!/bin/sh

bin="$0"
root="$1" 
xup="$2"
up=""
upn=1
parent=""

echo "Run: " $0 $root 


do_convert () {
	upn="$1"
	file="$2"

	echo "Convert $file"

    	cat $file \
	  | awk -v upn="$upn" -v open="0" ' \
		BEGIN { \
			print "<div id=\"menu" upn "\">"; \
			print "<div id=\"twist" upn "\" class=\"twisty\"></div>"; \
			open=0; \
		} \
		/^s / { \
			if (open >= 2) { \
				print "</ul>";\
				print "<div class=\"nend2\"></div>";\
				print "</li>";\
			} \
			if (open >= 1) { \
				print "<div class=\"nend1\"></div>";\
				print "</ul>";\
			} \
			print "<ul class=\"nav1\" >"; \
			print "<li><span>" substr($0, 3) "</span></li>"; \
			print "<li><ul class=\"nav2\" >"; \
			open = 2; \
		}\
		/^[fhl] / { \
			if (open < 1) { \
				print "<ul class=\"nav1\">";
				open = 1;
			} \
			print "<li><a href=\"%up%" $2 "\">" substr($0, 4+length($2)) "</a></li>"; \
		}\
		/^[dp] / { \
			print "<li><a href=\"%up%" $2 "/index.html\">" substr($0, 4+length($2)) "</a>";\
			print "</li>"; \
		}\
		END { \
			print "</ul>"; 
			print "</div>"; 
		} \
	' \
	> $file.xml;
}

for upn in 1 2 3 4; do 
	echo find "$root" -name .files$upn
	for file in `find "$root" -name .files$upn`; do 
		do_convert $upn $file;
	done;
done;

do_2menu () {
	dir="$1"
	level="$2"
	# relative "up" path
	uppath="$3"	
	topmenu="$4"

	file=$dir/.files$level

	echo "2menu $file on level $level with $topmenu and $uppath"

	if [ ! -e $file ]; then
		echo "File $file not found!";
		return;
	fi;

	echo "" > $file.xml2
	if [ -n "$topmenu" -a -e ./$topmenu ]; then
		echo "merge $topmenu"
		cat $topmenu \
			| sed -e "s@%up%@$uppath%up%@g" \
			>> $file.xml2;
	fi;
	cat $file.xml \
		>> $file.xml2;

	cat $file | while read type name desc; do 
	case $type in
	f|h)
		# process files
		echo "process file: " $name
		cat $file.xml2 \
			| sed -e "s@%up%@@g" \
			> $dir/$name.menu
		;;
	p)	
		# process pointed-to files
		echo "process pointer: " $name
		;;
	d)	
		# process directories
		echo "process directory: " $name
		(do_2menu $dir/$name $((level+1)) ../ $file.xml2)
		;;
	*)
		# ignore
		;;
	esac;
	done;
}

do_2menu . 1 ./

