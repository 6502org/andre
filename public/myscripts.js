
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
	if (typeof data == 'string') {

		var id = $(target).attr("id");
		var path = getPathFromId(id);
		var rpath = myUp + path + "/";

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
	}
	bindMinus(target);
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
		process(target);
	}
}

function setupAjax() {
	$("div#menu").ajaxError( function(ev, req, opts, error) {
		alert("req.url=" + opts.url + ": " + error.message);
	});
}

// ----------------------------------------------------------------------------------------------------------
// expand/hide single menu entries

// this is the IMG element that has been clicked
function hideMenu() {
	r = $(this).parent();	// to the LI element
	$(r).children("ul").hide();  // and back down to the enclosed sub menu
	bindPlus(r);
	return false;
}

// this is the IMG element that has been clicked
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

	$(parent).find("li").show();

	$(parent).find("li.dirp").each( function ( i, e ) {
		loadMenu( e, processExpand );
	});
}

function expandAll( ) {
	// we cannot simply let jquery loop over all ul, as they may not be loaded yet
	// but we can start with all the collapsed entries
	var v = $("div#menu ul");
	$(v).show();
	triggerExpand($(v));
}

function collapseAll( ) {
	$("div#menu ul").show();
	$("div#menu li").each( function ( i, e ) {
		$(e).show();
		if ($(e).hasClass("dirm")) {
			bindPlus( e );
			$(e).children("ul").hide();
		}
	});
}

// ----------------------------------------------------------------------------------------------------------
// filter

var currentFilter = "";

function triggerFilter( parent, filter ) {

	//alert("triggerFilter:" + $(parent).find(":text"));

	// first hide all
	$(parent).find("li").each( function ( i, e ) {
		// hide each item
		$(e).hide();
		if ( ($(e).hasClass("dirp")) || ($(e).hasClass("dirm")) ) {
			loadMenu( e, function(target, data) {
				processMenu( target, data );
				triggerFilter(target, data, filter);
			});
		}

		// search		
		if ($(e).text().toLowerCase().indexOf(currentFilter) >= 0) {
			$(e).show(); 	// LI
			$(e).parents().show();	// UL
		}
	});
}

function changeFilter( val ) {
	//isFilterActive = 0;

	currentFilter = val.toLowerCase();

	var filter = currentFilter;

	// hide both LI and UL
	var v = $("div#menu ul");
	$(v).hide();
	triggerFilter($(v), filter);

	//isFilterActive = 1;
}

function checkValue() {
	var t = $("div#menu input");

	var val = $(t).attr("value");
	if (val.length == 0) {
		if (currentFilter != "") {
			changeFilter(val);
		}
	} else
	if (val.length > 1) {
		if (currentFilter != val) {
			changeFilter(val);
		}
	}
}

var isFilterActive = 0;
function monitorFilter() {
	checkValue();
	if (isFilterActive == 1) {
		setTimeout(monitorFilter, 40);
	}
}

// ----------------------------------------------------------------------------------------------------------
// setup navigation

function setupFilter() {
	$("div#filter").prepend( "<form action=\"#\"><img id=\"expand\" src=\"" + myUp + "imgs/expand.png\"/>"
			+ "<img id=\"collapse\" src=\"" + myUp + "imgs/collapse.png\"/>"
			+ "<input size=\"10\" name=\"filter\" value=\"filter\" type=\"text\"> "
		        + "<img id=\"cancel\" src=\"" + myUp + "imgs/cancel.png\"></form>"
			+ "<br/>");
	$("div#menu img#expand").click( expandAll );
	$("div#menu img#collapse").click( collapseAll );

	$("div#menu img#cancel").click( function() {
			expandAll();
			$("div#menu input").attr("value", "");
		});

	$("div#menu input").focusin( function( ) {
			$(this).css({'background-color':'#fc6'});
			$(this).attr("value", "");
			$(this).unbind("focusin");
			$(this).focusin( function() {
				$(this).css({'background-color':'#fc6'});
				if (currentFilter.length > 1) {
					changeFilter(currentFilter);
				}
				isFilterActive = 1;
				setTimeout(monitorFilter, 40);
			});	
			isFilterActive = 1;
			setTimeout(monitorFilter, 40);
		});
		
	$("div#menu input").focusout( function( ) {
			$(this).css({'background-color':'#fff'});
			isFilterActive = 0;
		});		
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



