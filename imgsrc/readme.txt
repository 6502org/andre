

create sprite:

- menu items are scaled to 41% to be included in sprite

- collapse/expand scaled to 22px

- cbm/hw/sw/icap icons are not scaled 

- news, file icons are not scaled 


minify javascript:

- yui-compressor --nomunge myscripts.js > myscripts-min.js

compose sprite:

- composite -geometry +224+64 ../../imgsrc/cancel.png sprite.png sprite+.png

