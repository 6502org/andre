#!/bin/sh
#
# build the combined and compressed CSS and Javascript files
#



yui-compressor ../src/style.css > ../public/style-min.css.in

to=../public/style-min.css
t1=../public/style-min.css.in
if [ ! -f $to ]; then
	cp $t1 $to;
else
	diff -q $to $t1
	if [ $? -eq 1 ]; then
		cp $t1 $to;
	fi
fi;
rm $t1

 
cat ../src/jquery-1.4.2.min.js > ../public/scripts-min.js.in

cat ../src/scripts-copyright.txt >> ../public/scripts-min.js.in

yui-compressor ../src/myscriptsadv.js >> ../public/scripts-min.js.in

to=../public/scripts-min.js
t1=../public/scripts-min.js.in
if [ ! -f $to ]; then
	cp $t1 $to;
else
	diff -q $to $t1
	if [ $? -eq 1 ]; then
		cp $t1 $to;
	fi
fi;
rm $t1
 


