#!/bin/sh
#
# copy over the github based af65002 documentation (as .htmlsrc) to
# the web site as .bxml
# 

SRC="/home/fachat/Documents/8bit/65k02/af65/doc"
TRG="/home/fachat/Documents/8bit/8bitweb/public/65k"

EXTRAS="archcore.svg archcore.png archtop.svg archtop.png optable.css"

for base in 65002; do
	
	for i in $SRC/src/af$base-*.htmlsrc; do
		echo "i=" $i
		j=`basename $i .htmlsrc | tr -d '-'`
		k=$TRG/af$base/$j.bxml
		echo "k=" $k
		cat "$i" \
			| sed -e "s/<docpage/<webpage/" \
			| sed -e "s%</docpage%</webpage%g" \
			> "$k.tmp";
		(cd $SRC; ./scripts/inserts.sh "$k.tmp" af$base "$k" "$SRC"/../generator/de.fachat.65k )
		rm "$k.tmp"
	done;
	for i in $EXTRAS; do 
		cp $SRC/src/$i $TRG/af$base/
	done;
done;

