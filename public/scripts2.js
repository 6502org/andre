
//
// (C) Copyright 2013 A.Fachat <afachat@gmx.de>
// All rights reserved!
//
// This file is copyrighted. Other uses are prohibited without explicit permission by the copyright owner.
//


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
// initialization

// do the actual init
function doInit() {
	// initialize twisties
	setupTwisties();
	setupMenu();
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
	//doTimer();
	doInit();
});


