
function dumpArrayToString( a, sep, start ) {
	rv = "";
	l = a.length;
	for (i = start; i < l; i++) {
		if (i > 1) rv = rv + sep;
		rv = rv + a[i];
	}
	return rv;
}

// transforms a menu id into a path to the item
function getPathFromId( p ) {
	var spl = p.split("_");
	return dumpArrayToString( spl, "/", 1);
}

function hideMenu() {
	r = $(this).parent();
	$(r).children("ul").hide();
	bindPlus(r);
	return false;
}

function processMenu( data, path, root ) {

	var spl = data.split("%");
	l = spl.length;
	for (i = 0; i < l; i++) {
		t = spl[i];
		if (t == "xup") spl[i] = root;
		if (t == "up") spl[i] = root + path + "/";
	}

	return dumpArrayToString(spl, "", 0);
}

function showMenu( ) {
	r = $(this).parent();
	id = $(r).attr("id");
	path = getPathFromId(id);
	root = myUp;

	ul = $(r).children("ul");
	if ($(ul).size() == 0) {
		// load
		target = r;
		$.get(root + path + '/.menu.xml', function(data, status) {
		    data = processMenu(data, path, root);
		    //alert("status=" + status + ", data=" + data);
		    $(target).append(data);
		    bindMenu(target);
		    bindMinus(target);
		});
	} else {
		$(r).children("ul").show();
		bindMinus(r);
	}
	return false;
}

function bindPlus( el ) {
   	$(el).removeClass();
   	$(el).addClass("dirp");
	img = $(el).children("img");
	$(img).attr("src", myUp + "imgs/dirp.png");
	$(img).unbind();
	$(img).click( showMenu );
}

function bindMinus( el ) {
   	$(el).removeClass();
   	$(el).addClass("dirm");
	img = $(el).children("img");
	$(img).attr("src", myUp + "imgs/dirm.png");
	$(img).unbind();
	$(img).click( hideMenu );
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
		alert("req.url=" + opts.url + ": " + error.message);
	});
}

// do the actual init
function doInit() {
	bindMenu($("div#menu"));
	setupAjax();
}

// done to check advanced stylesheet
function doTimer() {
	if ($("div#twitter:visible").size() > 0) {
		doInit();
	} else {
		setTimeout( doTimer, 1000);
	}
		
}

$(document).ready(function(){

	// only init for non-default stylesheets
	// replace with "doInit();" once it is public
	doTimer();
});


