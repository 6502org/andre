#!/bin/sh

bin=`dirname $0`
root=$bin/..
imgs=$root/imgsrc
sprite=$imgs/sprite3.png

mycompose () {
        src="$1"
        add="$2"
	geo="$3"
	scale="$4"
	to="$1-tmp.png"
        if [ ! -f $addimg ]; then
                cp $src $to;
        else
		if [ "x$scale" != "x" ]; then
			add2=$add-tmp.png
			convert -scale "$scale" "$add" "$add2"
			composite -geometry "$geo" "$add2" "$src" "$to"
			rm "$add2"
		else
			composite -geometry "$geo" "$add" "$src" "$to"
		fi;
	fi;
	mv "$to" "$src"
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
        rm $from
}

cp $imgs/spritesbg_white2.png $sprite

mycompose $sprite $imgs/t2ub.png "+0+0" "100%"
mycompose $sprite $imgs/t2db.png "+128+0"
mycompose $sprite $imgs/t2lb.png "+256+0"
mycompose $sprite $imgs/t2rb.png "+384+0"

