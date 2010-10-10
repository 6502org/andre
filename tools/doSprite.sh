#!/bin/sh

bin=`dirname $0`
root=$bin/..
imgs=$root/imgsrc
sprite=$imgs/sprite2.png

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

cp $imgs/spritesbg_white.png $sprite

mycompose $sprite $imgs/file_desc.gif "+0+0" 
mycompose $sprite $imgs/file_driver.png "+32+0" 
mycompose $sprite $imgs/file_layout.png "+64+0" 
mycompose $sprite $imgs/file_logic.gif "+96+0" 
mycompose $sprite $imgs/file_memmap.gif "+128+0" 
mycompose $sprite $imgs/file_parts.gif "+160+0" 
mycompose $sprite $imgs/file_photo.gif "+192+0" 
mycompose $sprite $imgs/file_schem.png "+224+0" 
mycompose $sprite $imgs/file_src.gif "+256+0" 
mycompose $sprite $imgs/file_timing.gif "+288+0" 

mycompose $sprite $imgs/note_deprecated.gif "+0+32" 
mycompose $sprite $imgs/note_msg.gif "+32+32" 
mycompose $sprite $imgs/note_stop.gif "+64+32" 
mycompose $sprite $imgs/note_warn.gif "+96+32" 

mycompose $sprite $imgs/news.gif "+128+32" 
mycompose $sprite $imgs/oldnews.gif "+160+32" 
mycompose $sprite $imgs/hotnews.gif "+192+32" 

mycompose $sprite $imgs/twisties_right.png "+256+32" "41%"
mycompose $sprite $imgs/twisties_down.png "+288+32" "41%"

mycompose $sprite $imgs/dir.png "+0+64" "41%"
mycompose $sprite $imgs/dirp.png "+32+64" "41%"
mycompose $sprite $imgs/dirm.png "+64+64" "41%"
mycompose $sprite $imgs/direrr.png "+96+64" "41%"
mycompose $sprite $imgs/file.png "+128+64" "41%"
mycompose $sprite $imgs/link.png "+160+64" "41%"

mycompose $sprite $imgs/cancel.png "+224+64" 
mycompose $sprite $imgs/collapse.png "+256+64" "22x22"
mycompose $sprite $imgs/expand.png "+288+64" "22x22"

mycompose $sprite $imgs/icon_cbm.jpg "+0+110" 
mycompose $sprite $imgs/icon_hw.jpg "+75+110" 
mycompose $sprite $imgs/icon_sw.jpg "+150+110" 
mycompose $sprite $imgs/icon_icap.jpg "+225+110" 

cpmodified $sprite $root/public/imgs/sprite.png

