
function hideMenu() {
	$(this).children("ul").hide();
	bindPlus(this);
	return false;
}

function showMenu( e ) {
	ul = $(this).children("ul");
	if ($(ul).size() == 0) {
		// load
		alert("load file; " + "menu.xml");
		target = this;
		$.get('menu.xml', function(data, status) {
		    alert("status=" + status + ", data=" + data);
		    $(target).append(data);
		    alert('Load was performed.');
		    bindMenu(target);
		    bindMinus(target);
		});
	} else {
		$(this).children("ul").show();
		bindMinus(this);
	}
	return false;
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
	   if ( $(el).children("ul").size() != 0) {
	   	bindMinus(el);
	   } else {
	   	bindPlus(el);
	   }
   	});
}

function setupAjax() {
	$("div#menu").ajaxError( function(ev, req, opts, error) {
		alert("req.url=" + opts.url + ", ajaxError:" + error);
	});
}

$(document).ready(function(){
	bindMenu($("div#menu"));
	setupAjax();
});

