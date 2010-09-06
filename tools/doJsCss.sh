#!/bin/sh
#
# build the combined and compressed CSS and Javascript files
#



yui-compressor ../src/advanced.css > ../public/advanced-min.css.in

to=../public/advanced-min.css
t1=../public/advanced-min.css.in
if [ ! -f $to ]; then
	cp $t1 $to;
else
	diff -q $to $t1
	if [ $? -eq 1 ]; then
		cp $t1 $to;
	fi
fi;
rm $t1
 
cat ../src/jquery-1.4.2.min.js > ../public/scripts.js.in

yui-compressor ../src/myscriptsadv.js >> ../public/scripts.js.in

to=../public/scripts.js
t1=../public/scripts.js.in
if [ ! -f $to ]; then
	cp $t1 $to;
else
	diff -q $to $t1
	if [ $? -eq 1 ]; then
		cp $t1 $to;
	fi
fi;
rm $t1
 


