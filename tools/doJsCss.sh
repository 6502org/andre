#!/bin/sh
#
# build the combined and compressed CSS and Javascript files
#

root=`dirname $0`/..

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
	rm $from
}

#################################################################################
# CSS

csstarget=$root/public/style

cat $root/src/style.css > ${csstarget}.css.in

yui-compressor --type css ${csstarget}.css.in > ${csstarget}-min.css.in

cpmodified ${csstarget}.css.in ${csstarget}.css
cpmodified ${csstarget}-min.css.in ${csstarget}-min.css

#################################################################################
# Javascript jquery lib(s)


libtarget=$root/public/jquery

cat $root/src/jquery-1.4.2.min.js > ${libtarget}-min.js.in

cpmodified ${libtarget}-min.js.in ${libtarget}-min.js

#################################################################################
# own javascript (base for advanced)

jstarget=$root/public/scripts

cat $root/src/scripts-copyright.txt > ${jstarget}.js.in

cat $root/src/scripts.js >> ${jstarget}.js.in

cpmodified ${jstarget}.js.in ${jstarget}.js

#################################################################################
# optimized, combined javascript

cat $root/src/scripts-copyright.txt > ${jstarget}-all.js.in

cat ${libtarget}-min.js >> ${jstarget}-all.js.in

yui-compressor --type js ${jstarget}.js >> ${jstarget}-all.js.in

cpmodified ${jstarget}-all.js.in ${jstarget}-all.js

