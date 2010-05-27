
function hideMenu( id ) {
	e = $("#" + id);
	$(e).next().hide();
	img = $(e).find("img");
	$(img).attr("src", "imgs/plus.png");
	$(img).attr("onClick", "showMenu('" + id + "')");
	$(img).removeClass("menuovlm");
	$(img).addClass("menuovlp");
}

function showMenu( e ) {
	e = $("#" + id);
	$(e).next().show();
	img = $(e).find("img");
	$(img).attr("src", "imgs/minus.png");
	$(img).attr("onClick", "hideMenu('" + id + "')");
	$(img).removeClass("menuovlp");
	$(img).addClass("menuovlm");
}

function bindMenu( el ) {
   $(el).find("li.dir").each( function(index, el) {
	   if ( $(el).next().not("li").size() == 0) {
	   	id = $(el).attr('id');
	   	$(el).prepend("<img onClick=\"showMenu('" + id + "');\" class=\"menuovlp\" src=\"imgs/plus.png\"/>");
	   }
   });
   $(el).find("li.dir + ul").each( function(index, el) {
	   li = $(el).prev();
	   id = $(li).attr('id');
	   $(li).prepend("<img onClick=\"hideMenu('" + id + "')\" class=\"menuovlm\" src=\"imgs/minus.png\"/>");
   });

   // bind 
}

$(document).ready(function(){
	bindMenu($("div#menu"));
});

