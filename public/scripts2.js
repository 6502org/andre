
//
// (C) Copyright 2013 A.Fachat <afachat@gmx.de>
// All rights reserved!
//
// This file is copyrighted. Other uses are prohibited without explicit permission by the copyright owner.
//

// Utility

function dumpArrayToString( a, sep, start ) {
        rv = "";
        l = a.length;
        for (i = start; i < l; i++) {
                if (i > 1) rv = rv + sep;
                rv = rv + a[i];
        }
        return rv;
}


// ----------------------------------------------------------------------------------------------------------
// setup twisties

function setupTwisties() {
	
	$("div.h2t").each( function(i, e) {
		//$(e).show();
		$(e).css({'display': 'block'});
		$(e).parent().click( twisty ); // click on h2h(eader)
	});
}

function twisty() {
	var content = $(this).parent().children(".h2c");
	var twisty = $(this).children(".h2t");
	if ( $(content).is(':visible') ) {
		$(twisty).css({'background-position': '-256px -32px'});
		$(content).hide();
	} else {
		$(twisty).css({'background-position': '-288px -32px'});
		$(content).css({'display': 'block'});
	}
}

// ----------------------------------------------------------------------------------------------------------
// setup menu folding



function menuClose(menu) {
	var hdrtxt = $(menu).children( ".hdrtxt" );
	$(menu).children( "ul" ).hide();
	$(hdrtxt).show();
}

function menuOpen(menu) {
	var hdrtxt = $(menu).children( ".hdrtxt" );
	$(hdrtxt).hide();
	$(menu).children( "ul" ).show();
}

function menutwisty() {
	var menu = $(this); //.parent();
	var hdrtxt = $(menu).children( ".hdrtxt" );
	if ( $(hdrtxt).is(":visible") ) {
		menuOpen(menu);
	} else {
		menuClose(menu);
	}
}

function setupMenu() {
	
	$("div.twisty").each( function(i, e) {
		//$(e).show();
		$(e).parent().click( menutwisty ); // click on h2h(eader)
	});

	// close menu 1 when menu 2 exists
	$("div#menu2").each( function(i, e) {
		$("div#menu1").each( function (i, e) {
			menuClose(e);
		});
	});
	// close menu 2 when menu 3 exists
	$("div#menu3").each( function(i, e) {
		$("div#menu2").each( function (i, e) {
			menuClose($(e));
		});
	});
}

// ----------------------------------------------------------------------------------------------------------
// setup filter

function loadMenu( r, process ) {

        var target = r;

        var ul = $(target).find("ul");
        if ($(ul).size() == 0) {
                // TODO: $(r).children("img").attr("src", myUp + "imgs/dirload.gif");
                // load as html, i.e. text. jquery/javascript cannot insert an xml document (i.e. as 
                // XML DOM tree) directly into the html document
                $.get(myUp + '/sindex.html', function(data) {
                  process(target, data, true);
                }, "html" );
        } else {
                $(r).children("ul").show();
                process(target, "", false);
        }
}

// ----------------------------------------------------------------------------------------------------------
// ajax helper

// process the retrieved menu part
// as string, then append to target
// returns true when correctly loaded
function processMenu( target, data, loaded ) {

        // highly parallel - so use local vars
        if (loaded && typeof data == 'string') {

                // filesystem local tests
                var spl = data.split("%");
                var l = spl.length;
                for (i = 0; i < l; i++) {
                        t = spl[i];
                        if (t == "up") spl[i] = myUp;
                }
                data = dumpArrayToString(spl, "", 0);

                if( $(target).children("ul").size() == 0) {
                        // it was not already loaded in the meantime
                        // append data (as string) to target
                        $(target).append(data);
                }
        }

        return (!loaded) || (typeof data == 'string' && data.length > 0);
}


var currentFilter = "";

function triggerFilter( topfind, filter ) {

	loadMenu(topfind, processMenu);

        $(topfind).find("li").each( function ( i, e ) {

                // hide each item
                $(e).hide();

                // search and show results
                if ($(e).text().toLowerCase().indexOf(currentFilter) >= 0) {
                        $(e).show();    // LI
                        $(e).parents().each( function (i, x) {
                                $(x).show();
                        });
                }
        });
}

function hideFiltered() {
	$("div#topfind").hide();
}

function changeFilter( val ) {

        currentFilter = val.toLowerCase();

        var filter = currentFilter;

        // hide both LI and UL
        var v = $("div#topfind");
        $(v).hide();

        triggerFilter(v, filter);
}

function checkValue() {
        var t = $("div#topsearch input");

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
        } else {
		hideFiltered();
	}
}

var isFilterActive = 0;
function monitorFilter() {
        checkValue();
        if (isFilterActive == 1) {
                setTimeout(monitorFilter, 40);
        }
}

function setupFilter() {
        $("div#topsearch input").focusin( function( ) {
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

        $("div#topsearch input").focusout( function( ) {
                        $(this).css({'background-color':'#fff'});
                        setTimeout(hideFiltered, 1000);
                        isFilterActive = 0;
                });
}


// ----------------------------------------------------------------------------------------------------------
// initialization

// do the actual init
function doInit() {
	// initialize twisties
	setupTwisties();
	setupMenu();
	setupFilter();
}

$(document).ready(function(){

	// only init for non-default stylesheets
	// replace with "doInit();" once it is public
	//doTimer();
	doInit();
});


