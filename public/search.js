
//
// (C) Copyright 2010 A.Fachat <afachat@gmx.de>
// All rights reserved!
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
// returns true when correctly loaded
function processMenu( target, data, loaded ) {

	// highly parallel - so use local vars
	if (loaded && typeof data == 'string') {

		var id = $(target).attr("id");
		var path = getPathFromId(id);
		var rpath = myUp + path + "/";

		// filesystem local tests
		var spl = data.split("%");
		var l = spl.length;
		for (i = 0; i < l; i++) {
			t = spl[i];
			if (t == "xup") spl[i] = myUp;
			if (t == "up") spl[i] = rpath;
		}
		data = dumpArrayToString(spl, "", 0);

		if( $(target).children("ul").size() == 0) {
			// it was not already loaded in the meantime
			// append data (as string) to target
			$(target).append(data);
		}

		bindMenu(target);
		bindMinus(target);
	}

	return (!loaded) || (typeof data == 'string' && data.length > 0);
}

function loadMenu( r, process ) {

	var target = r;
	var id = $(target).attr("id");
	var path = getPathFromId(id);


	var ul = $(target).children("ul");
	if ($(ul).size() == 0) {
		// TODO: $(r).children("img").attr("src", myUp + "imgs/dirload.gif");
		// load as html, i.e. text. jquery/javascript cannot insert an xml document (i.e. as 
		// XML DOM tree) directly into the html document
		$.get(myUp + path + '/.menu.xml', function(data) {
		  process(target, data, true);
		}, "html" );
	} else {
		$(r).children("ul").show();
		process(target, "", false);
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
	var r = $(this).parent();	// to the LI element
	$(r).children("ul").hide();  // and back down to the enclosed sub menu
	bindPlus(r);
	return false;
}

// this is the IMG element that has been clicked
function showMenu( ) {
	var r = $(this).parent();	// up to the LI element
	loadMenu(r, function( target, data, loaded ) {
		var ok = processMenu(target, data, loaded)
		if (ok) {
			bindMinus(r);

			$(r).children("ul").children("li.dirm").each( function (i, e) {
	      			$(e).children("ul").hide();
		      		bindPlus(e);
			});
		}		
	  });
	//loadMenu(r, function () {} );
	return false;
}

// parameter is the LI element
function bindPlus( el ) {
   	$(el).removeClass();
   	$(el).addClass("dirp");
	var img = $(el).children("div.i_dir");
	$(img).css({'background-position': '-256px -32px'});
	$(img).unbind();
	$(img).click( showMenu );
}

// parameter is the LI element
function bindMinus( el ) {
   	$(el).removeClass();
   	$(el).addClass("dirm");
	var img = $(el).children("div.i_dir");
	$(img).css({'background-position': '-288px -32px'});
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
// filter

var currentFilter = "";

function triggerFilter( parent, filter ) {

	// do not search recursively with CSS, as visibility needs to be processed
	// in the correct order
	$(parent).children("li").each( function ( i, e ) {
		// hide each item
		$(e).hide();
		if ($(e).hasClass("dirp") || $(e).hasClass("dirm")) {
			// should have children in the DOM tree
			loadMenu( e, function(target, data, loaded) {

			      processMenu( target, data, loaded );

			      triggerFilter($(target).children("ul"), filter);
			});
		}

		// search and show results
		if ($(e).text().toLowerCase().indexOf(currentFilter) >= 0) {
			$(e).show(); 	// LI
			$(e).parents().each( function (i, x) {
				$(x).show();
				if ($(x).hasClass("dirp")) {
					bindMinus(x);
				}
			});
		}
	});
}

function changeFilter( val ) {

	currentFilter = val.toLowerCase();

	var filter = currentFilter;

	// hide both LI and UL
	var v = $("div#topfind").children("ul");
	$(v).hide();

	//printDOMTree( $(v).get(0), window.open());

	triggerFilter($(v), filter);
}

function checkValue() {
	var t = $("div#topsearch input");

	var val = $(t).attr("value");
	if (val.length == 0) {
		if (currentFilter != "") {
			//changeFilter(val);
			$("div#topfind").hide();
		}
	} else
	if (val.length > 1) {
		if (currentFilter != val) {
			$("div#topfind").show();
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

function setupFilter2() {

	$("div#topsearch input").focusin( function( ) {
			$(this).css({'background-color':'#fc6'});
			$(this).attr("value", "");
			$(this).unbind("focusin");
			$(this).focusin( function() {
				$(this).css({'background-color':'#fc6'});
				if (currentFilter.length > 1) {
					$("div#topfind").show();
					changeFilter(currentFilter);
				}
				isFilterActive = 1;
				setTimeout(monitorFilter, 40);
			});	
			isFilterActive = 1;
			setTimeout(monitorFilter, 40);
		});
		
	$("div#topsearch input").focusout( function( ) {
			$(this).css({'background-color':'#fff'});
			isFilterActive = 0;
			$("div#topfind").hide();
		});		
}

// ----------------------------------------------------------------------------------------------------------
// nav twisties

function setupTwisties2() {
	$("div.twisty").each( function(i, e) {
		$(e).click( twisty2 );
	});
}

function twisty2() {
	var content = $(this).parent().children("ul");
        if ( $(content).is(':visible') ) {
                $(content).hide();
		$(this).parent().css({'height':'1.5em'});
        } else {
                $(content).show();
		$(this).parent().css({'height':''});
        }
	
}

// ----------------------------------------------------------------------------------------------------------
// initialization

// do the actual init
function doInit2() {
	setupFilter2();
	setupTwisties2();
}

$(document).ready(doInit2);

