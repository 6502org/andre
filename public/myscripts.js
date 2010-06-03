
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

		// append data (as string) to target
		$(target).append(data);

		bindMenu(target);
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
	loadMenu(r, processMenu);
	bindMinus(r);
	$(r).children("ul").children("li.dirm").each( function (i, e) {
	      $(e).children("ul").hide();
	      bindPlus(e);
	  });
	//loadMenu(r, function () {} );
	return false;
}

// parameter is the LI element
function bindPlus( el ) {
   	$(el).removeClass();
   	$(el).addClass("dirp");
	var img = $(el).children("img");
	$(img).attr("src", myUp + "imgs/dirp.png");
	$(img).unbind();
	$(img).click( showMenu );
}

// parameter is the LI element
function bindMinus( el ) {
   	$(el).removeClass();
   	$(el).addClass("dirm");
	var img = $(el).children("img");
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

function triggerExpand( parent ) {

	$(parent).find("li").show();

	// find recursively. We can do that as we only process loaded ones
	$(parent).find("li.dirp").each( function ( i, e ) {
		loadMenu( e, function (target, data, loaded) {

			// include loaded menu
			processMenu( target, data, loaded );
			bindMinus(target);

			if (loaded) {
				// trigger further expand
				triggerExpand( target );
			}
		});
	});
}

function expandAll( ) {
	// we cannot simply let jquery loop over all ul, as they may not be loaded yet
	// but we can start with all the collapsed entries
	// triggerExpand will do the rest for us in the ajax handler
	var v = $("div#menu ul");
	$(v).show();
	triggerExpand($(v));
}

function collapseAll( ) {
	var topul = $("div#menu").children().children("ul");

	$(topul).show();
	$(topul).children("li").each( function ( i, e ) {
		// toplevel
		$(e).show();
		$(e).children("ul").hide();
		if ($(e).hasClass("dirm")) {
			bindPlus( e );
		}
	});
}

// ----------------------------------------------------------------------------------------------------------
// filter

var currentFilter = "";

function triggerFilter( parent, filter ) {

	// do not search rescursively with CSS, as visibility needs to be processed
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
	var v = $("div#menu").children().children("ul");
	$(v).hide();

	//printDOMTree( $(v).get(0), window.open());

	triggerFilter($(v), filter);
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
	$("div#menu img#expand").click( expandAll );
	$("div#menu img#collapse").click( collapseAll );

	$("div#menu img#cancel").click( function() {
			isFilterActive = 0;
			currentFilter = "";
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

// ----------------------------------------------------------------------------------------------------------
// debug

//  From http://www.permadi.com/tutorial/domTree/index.html

// F. Permadi 2005.
// (C) F. Permadi
// Print DOM tree
////////////////////////////////////////////
// This function traverses the DOM tree of an element and prints the tree.  
// This function called recursively until the DOM tree is fully traversed.
// 
// Parameters:
// - targetDocument is where the tree will be printed into
// - currentElement is the element that we want to print
// - depth is the depth of the current element 
//   (it should be 1 for the initial element)
////////////////////////////////////////////
function traverseDOMTree(targetDocument, currentElement, depth)
{
  if (currentElement)
  {
    var j;
    var tagName=currentElement.tagName;
    // Prints the node tagName, such as <A>, <IMG>, etc
    if (tagName)
      targetDocument.writeln("&lt;"+currentElement.tagName+"&gt;");
    else
      targetDocument.writeln("[unknown tag]");

    // Traverse the tree
    var i=0;
    var currentElementChild=currentElement.childNodes[i];
    while (currentElementChild)
    {
      // Formatting code (indent the tree so it looks nice on the screen)
      targetDocument.write("<BR>\n");
      for (j=0; j<depth; j++)
      {
        // &#166 is just a vertical line
        targetDocument.write("&nbsp;&nbsp;&#166");
      }								
      targetDocument.writeln("<BR>");
      for (j=0; j<depth; j++)
      {
        targetDocument.write("&nbsp;&nbsp;&#166");
      }					
      if (tagName)
        targetDocument.write("--");

      // Recursively traverse the tree structure of the child node
      traverseDOMTree(targetDocument, currentElementChild, depth+1);
      i++;
      currentElementChild=currentElement.childNodes[i];
    }
    // The remaining code is mostly for formatting the tree
    targetDocument.writeln("<BR>");
    for (j=0; j<depth-1; j++)
    {
      targetDocument.write("&nbsp;&nbsp;&#166");
    }			
    targetDocument.writeln("&nbsp;&nbsp;");
    if (tagName)
      targetDocument.writeln("&lt;/"+tagName+"&gt;");
  }
}

////////////////////////////////////////////
// This function accepts a DOM element as parameter and prints
// out the DOM tree structure of the element.
////////////////////////////////////////////
function printDOMTree(domElement, destinationWindow)
{
  // Use destination window to print the tree.  If destinationWIndow is
  //   not specified, create a new window and print the tree into that window
  var outputWindow=destinationWindow;
  if (!outputWindow)
    outputWindow=window.open();

  // make a valid html page
  outputWindow.document.open("text/html", "replace");
  outputWindow.document.write("<HTML><HEAD><TITLE>DOM</TITLE></HEAD><BODY>\n");
  outputWindow.document.write("<CODE>\n");
  traverseDOMTree(outputWindow.document, domElement, 1);
  outputWindow.document.write("</CODE>\n");
  outputWindow.document.write("</BODY></HTML>\n");
  
  // Here we must close the document object, otherwise Mozilla browsers 
  //   might keep showing "loading in progress" state.
  outputWindow.document.close();
}
