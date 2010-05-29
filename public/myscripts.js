
//
// (C) Copyright 2010 A.Fachat <afachat@gmx.de>
//
// This file is copyrighted. Other uses are prohibited without explicit permission by the copyright owner.
//

// ----------------------------------------------------------------------------------------------------------
// Utilities

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

// ----------------------------------------------------------------------------------------------------------
// ajax helper

// process the retrieved menu part
// as string, then append to target
function processMenu( target, data ) {

	// highly parallel - so use local vars
	var id = $(target).attr("id");
	var path = getPathFromId(id);
	var rpath = myUp + path + "/";

	if (typeof data == 'string') {
		// filesystem local tests
		var spl = data.split("%");
		l = spl.length;
		for (i = 0; i < l; i++) {
			t = spl[i];
			if (t == "xup") spl[i] = myUp;
			if (t == "up") spl[i] = rpath;
		}
		data = dumpArrayToString(spl, "", 0);

		// append data (as string) to target
		$(target).append(data);

		bindMenu(target);
		bindMinus(target);
	}
}

function loadMenu( r, process ) {

	var target = r;
	var id = $(target).attr("id");
	var path = getPathFromId(id);

	ul = $(r).children("ul");
	if ($(ul).size() == 0) {
		// load as html, i.e. text. jquery/javascript cannot insert an xml document (i.e. as 
		// XML DOM tree) directly into the html document
		$.get(myUp + path + '/.menu.xml', function(data) {
		  process(target, data);
		}, "html" );
	} else {
		$(r).children("ul").show();
		bindMinus(r);
	}
}

function setupAjax() {
	$("div#menu").ajaxError( function(ev, req, opts, error) {
		alert("req.url=" + opts.url + ": " + error.message);
	});
}

// ----------------------------------------------------------------------------------------------------------
// expand/hide single menu entries

// this is the IMG element tha has been clicked
function hideMenu() {
	r = $(this).parent();	// to the LI element
	$(r).children("ul").hide();  // and back down to the enclosed sub menu
	bindPlus(r);
	return false;
}

// this is the IMG element tha has been clicked
function showMenu( ) {
	r = $(this).parent();	// up to the LI element
	loadMenu(r, processMenu);
	return false;
}

// parameter is the LI element
function bindPlus( el ) {
   	$(el).removeClass();
   	$(el).addClass("dirp");
	img = $(el).children("img");
	$(img).attr("src", myUp + "imgs/dirp.png");
	$(img).unbind();
	$(img).click( showMenu );
}

// parameter is the LI element
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

// ----------------------------------------------------------------------------------------------------------
// expand/collapse and filter functionality

function processExpand( target, data ) {

	// include loaded menu
	processMenu( target, data );

	// trigger further expand
	triggerExpand( target );
}

function triggerExpand( parent ) {
	$(parent).find("li.dirp").each( function ( i, e ) {
		loadMenu( e, processExpand );
	});
}

function expandAll( ) {
	// we cannot simply let jquery loop over all ul, as they may not be loaded yet
	// but we can start with all the collapsed entries
	triggerExpand($("div#menu"));
}

function collapseAll( ) {
	$("div#menu li.dirm").each( function ( i, e ) {
		bindPlus( e );
		$(e).children("ul").hide();
	});
}

function setupFilter() {
	$("div#menu").prepend( "<img id=\"expand\" src=\"" + myUp + "imgs/expand.png\"/>"
			+ "<img id=\"collapse\" src=\"" + myUp + "imgs/collapse.png\"/>"
			+ "<br/>");
	$("div#menu img#expand").click( expandAll );
	$("div#menu img#collapse").click( collapseAll );
}

// ----------------------------------------------------------------------------------------------------------
// initialization

// do the actual init
function doInit() {
	bindMenu($("div#menu"));
	setupAjax();
	setupFilter();
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



