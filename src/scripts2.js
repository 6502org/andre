
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

function stopEvents(event)
{
   if (event.stopPropagation){
       event.stopPropagation();
   }
   else if(window.event){
      window.event.cancelBubble=true;
   }
}

function setupMenu() {
	
	$("div.twisty").each( function(i, e) {
		//$(e).show();
		$(e).parent().click( menutwisty ); // click on h2h(eader)
	});

	$("div#menu1, div#menu2, div#menu3").find("a").click( function(ev) {
			stopEvents(ev);
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

function loadMenu( topfind, process ) {

        var target = topfind;

        var ul = $(target).find("ul");

        if ($(ul).size() == 0) {

		progressShow(topfind);

                // TODO: $(r).children("img").attr("src", myUp + "imgs/dirload.gif");
                // load as html, i.e. text. jquery/javascript cannot insert an xml document (i.e. as 
                // XML DOM tree) directly into the html document
                $.get(myUp + 'sindex.xml', function(data) {
                  process(target, data, true);
                }, "html" );
        } else {
                process(target, "", false);
        }
}

// ----------------------------------------------------------------------------------------------------------
// ajax helper

var time = 0.0;
var progressbar;

function progressHide( topfind ) {
	var progress = $(topfind).children("#topprogress");

	clearInterval( progressbar );

	$(progress).hide();
}

function progressShow( topfind ) {
	var progress = $(topfind).children("#topprogress");

	$(progress).show();

	progressbar = setInterval( function() {
		var sin = Math.round(8 + (Math.sin(time) * 7)).toString(16);
		time = time + 0.1;
		var val = "#" + sin+sin+sin;
		progress.css( "background", val);
	}, 50);
}

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

		progressHide(target);

                if( $(target).children("ul").size() == 0) {
                        // it was not already loaded in the meantime
                        // append data (as string) to target
                        $(target).append(data);
                }
        }

        return (!loaded) || (typeof data == 'string' && data.length > 0);
}


var currentFilter = "";

function doFilter(topfind) {

	var lis = $(topfind).find("li");

	if (lis.size() > 0) {
	    progressHide(topfind);

       	    $(lis).each( function ( i, e ) {

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

	    $(topfind).children("ul").show();
	}
}

function hideFiltered() {
	$("div#topfind").children("ul").hide();
}

function changeFilter( val ) {

	var newval = val.trim().toLowerCase();

	if (newval == currentFilter) {
		return;
	}

        currentFilter = newval;

	var topfind = $("div#topfind");

	loadMenu(topfind, 
		function(proc, data, loaded) {
			processMenu(proc, data, loaded);

			doFilter(topfind);
		});
}

function checkValue() {
        var t = $("div#topsearch input");

        var val = $(t).attr("value");
        if (val.length > 1) {
                changeFilter(val);
        } else {
		currentFilter = "";
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

function socialshare() {
                  if($('#socialshareprivacy').length > 0){
                            $('#socialshareprivacy').socialSharePrivacy({
                                services : {
                                  facebook : {
					'status':'off'
                                  },
				  twitter : {
					'dummy_img':'/users/andre/socialshareprivacy/images/dummy_twitter.png',
					'txt_info':'Only by clicking the button is activated and you can send the recommendation. Activating sends data to third parties'
				  },
				  gplus : {
					'dummy_img':'/users/andre/socialshareprivacy/images/dummy_gplus.png',
					'txt_info':'Only by clicking the button is activated and you can send the recommendation. Activating sends data to third parties'
				  }
                                },
                                'txt_help' : 'By activating these fields through clicking, you accept that information will be sent to Facebook, Twitter or Google and stored there. More information by clicking on the \'i\' (in German)',
                                'settings_perma' : 'Accept data transfer and activate permanently',
				'css_path':'/users/andre/socialshareprivacy/socialshareprivacy.css'
                            });

			$('#share').css({'display':'block'});
                  }
}

// ----------------------------------------------------------------------------------------------------------
// initialization

// do the actual init
function doInit() {
	// initialize twisties
	setupTwisties();
	setupMenu();
	setupFilter();
	socialshare();
}

$(document).ready(function(){

	// only init for non-default stylesheets
	// replace with "doInit();" once it is public
	//doTimer();
	doInit();
});


