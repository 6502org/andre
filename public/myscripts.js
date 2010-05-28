
function hideMenu() {
	alert("hide");
	$(this).children("ul").hide();
	bindPlus(this);
}

function showMenu( e ) {
	ul = $(this).children("ul");
	if ($(ul).size() == 0) {
		// load
		alert("not ok");
	} else {
		alert("ok");
		$(this).children("ul").show();
		bindMinus(this);
	}
}

function bindPlus( el ) {
   	$(el).removeClass();
   	$(el).addClass("dirp");
	$(el).children("img").attr("src", "imgs/dirp.png");
	$(el).unbind();
	$(el).click( showMenu );
}

function bindMinus( el ) {
   	$(el).removeClass();
   	$(el).addClass("dirm");
	$(el).children("img").attr("src", "imgs/dirm.png");
	$(el).unbind();
	$(el).click( hideMenu );
}

function bindMenu( el ) {
   $(el).find("li.dir").each( function(index, el) {
	   if ( $(el).find("ul").size() != 0) {
	   	bindMinus(el);
	   } else {
	   	bindPlus(el);
	   }
   });

   // bind 
}

$(document).ready(function(){
	bindMenu($("div#menu"));
});

