#!/bin/sh
#
# build the combined and compressed CSS and Javascript files
#

root=`dirname $0`/..

mvmodified () {
        from="$1"
        to="$2"
	cpmodified "$from" "$to"
	rm $from
}

cpmodified () {
        from="$1"
        to="$2"
	if [ ! -f $to ]; then
		cp $from $to;
	else
		diff -q $to $from
		if [ $? -eq 1 ]; then
			cp $from $to;
		fi	
	fi;
}

# takes input file, minimizes it and puts it to the function's stdout
minifyjs () {
	#slimit "$1" 
	yui-compressor --type js "$1" 
}

# takes input file, minimizes it and puts it to the function's stdout
minifycss () {
	yui-compressor --type css "$1" 
}

#################################################################################
# CSS

csstarget=$root/public/style

cat $root/src/style.css > ${csstarget}.css.in

minifycss ${csstarget}.css.in > ${csstarget}-min.css.in

mvmodified ${csstarget}.css.in ${csstarget}.css
mvmodified ${csstarget}-min.css.in ${csstarget}-min.css

# new style

cat $root/src/style2.css > ${csstarget}2.css.in

minifycss ${csstarget}2.css.in > ${csstarget}2-min.css.in

mvmodified ${csstarget}2.css.in ${csstarget}2.css
mvmodified ${csstarget}2-min.css.in ${csstarget}2-min.css

#################################################################################
# Javascript jquery lib(s)


libtarget=$root/public/jquery

cat $root/src/jquery-1.11.2.min.js > ${libtarget}-min.js.in

mvmodified ${libtarget}-min.js.in ${libtarget}-min.js

#################################################################################
# own javascript (base for advanced)

jstarget=$root/public/scripts

cat $root/src/scripts-copyright.txt > ${jstarget}.js.in

cat $root/src/scripts.js >> ${jstarget}.js.in
cat $root/src/scripts2.js >> ${jstarget}2.js.in

mvmodified ${jstarget}.js.in ${jstarget}.js
mvmodified ${jstarget}2.js.in ${jstarget}2.js

#################################################################################
# optimized, combined javascript

cat $root/src/scripts-copyright.txt > ${jstarget}-all.js.in

cat ${libtarget}-min.js >> ${jstarget}-all.js.in

cpmodified ${jstarget}-all.js.in ${jstarget}2-all.js.in

minifyjs ${jstarget}.js >> ${jstarget}-all.js.in
minifyjs ${jstarget}2.js >> ${jstarget}2-all.js.in

mvmodified ${jstarget}-all.js.in ${jstarget}-all.js
mvmodified ${jstarget}2-all.js.in ${jstarget}2-all.js


#################################################################################
#

cpmodified $root/imgsrc/pointr.png $root/public/imgs/pointr.png

