<?xml version="1.0"?>
<!DOCTYPE xsl:stylesheet [ <!ENTITY eac "&#233;"> <!ENTITY nbsp "&#160;"> ] >
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
   <xsl:param name="date" select="'unknown'"/>

<xsl:output method="xml" encoding="utf-8" omit-xml-declaration="yes" 
	doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd" />
<!--
	doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN" 
-->

<!-- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx -->

<xsl:template name="h2toc">
	<xsl:param name="hdr"/>
	<xsl:param name="a"/>
  <div class="h2h">
    <div class="h2t">&nbsp;</div>
    <xsl:choose>
      <xsl:when test="$a != ''">
      	<h2>
          <a name="{$a}"><xsl:value-of select="$hdr"/></a>
        </h2>
      </xsl:when>
      <xsl:otherwise>
        <h2>
          <xsl:value-of select="$hdr"/>
        </h2>
      </xsl:otherwise>
    </xsl:choose>
    <!--div class="toplink"><a href="#top">Top</a></div-->
  </div>
</xsl:template>

<!--xsl:template name="h2">
	<xsl:param name="hdr"/>
<h2><xsl:value-of select="$hdr"/></h2>
<div class="toplink"><a href="#topanchor">Top</a></div>
</xsl:template-->

<!-- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx -->

<xsl:template name="toc">
<div id="toc" class="h2">
<xsl:call-template name="h2toc">
	<xsl:with-param name="hdr">Table of content</xsl:with-param>
</xsl:call-template>
<div class="h2c">
<ul>
<xsl:for-each select="section|itemlist">
<li><a href="#{@toc}"><xsl:value-of select="@name"/></a></li>
<xsl:if test="subsection|items/item">
<li style="list-style-type:none;"><ul>
<xsl:for-each select="subsection|items/item">
<li><a href="#{@toc}"><xsl:value-of select="@name"/></a></li>
</xsl:for-each>
</ul></li>
</xsl:if>
</xsl:for-each>
<xsl:if test="driver">
<li><a href="#driver">Driver</a></li>
<li style="list-style-type:none;"><ul>
<xsl:for-each select="driver">
<li><a href="#driver{position()}"><xsl:value-of select="name"/></a></li>
</xsl:for-each>
</ul></li>
</xsl:if>
<xsl:if test="rev">
<li><a href="#boards">Board Revisions</a></li>
<li style="list-style-type:none;"><ul>
<xsl:for-each select="rev">
<li><a href="#board{position()}"><xsl:value-of select="version"/></a> (<xsl:value-of select="status"/>)</li>
</xsl:for-each>
</ul></li>
</xsl:if>
<xsl:if test="diagram">
<li><a href="#blkdiag">Block diagram</a></li>
</xsl:if>
<!--xsl:if test="oldnews">
<li><a href="#oldnews">Old News</a></li>
</xsl:if -->
</ul>
</div><!-- h2c -->
</div><!-- toc h2 -->
</xsl:template>

<!-- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx -->

<xsl:template match="board">
<!--xsl:text disable-output-escaping="yes">&lt;!doctype html&gt;-->
<!--xsl:text disable-output-escaping="yes">&lt;!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN"&gt;-->
<!--xsl:text disable-output-escaping="yes">&lt;!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/1999/REC-html401-19991224/loose.dtd"&gt;-->
<!--xsl:text disable-output-escaping="yes">&lt;!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 3.2 Final//EN"&gt;-->
<!--xsl:text disable-output-escaping="yes">&lt;!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML 2.0//EN"&gt;-->
<!--/xsl:text-->
<html><head>
	<xsl:call-template name="head"/>
	<title><xsl:value-of select="name"/></title>
</head><xsl:text>
</xsl:text><body>
<div id="mainbox">
<a name="top"/>
<xsl:call-template name="commoncol"/>
<div id="midcol">
<div class="top" id="content">
<div id="minmax"/>
<xsl:text>

</xsl:text>
<h1><xsl:value-of select="name"/></h1>
<xsl:text>
</xsl:text><xsl:apply-templates select="copyright"/><xsl:text>
</xsl:text><div class="overview"><xsl:apply-templates select="desc"/><xsl:text>
</xsl:text></div>
<xsl:apply-templates select="news"/>
<xsl:call-template name="toc"/>
<xsl:apply-templates select="section"/>
<xsl:call-template name="alldriver"/>
<xsl:call-template name="allrev"/>
<xsl:if test="diagram">
  <div class="h2">
    <xsl:call-template name="h2toc">
      <xsl:with-param name="hdr">Block diagram</xsl:with-param>
      <xsl:with-param name="a">blkdiag</xsl:with-param>
    </xsl:call-template>
    <div class="h2c">
      <img width="100%" src="{diagram/file}" alt="block diagram"/>
      <div class="diagcaption">
        <xsl:apply-templates select="diagram/desc"/>
      </div>
    </div><!-- h2c -->
  </div><!-- h2 -->
</xsl:if>
<!--xsl:apply-templates select="oldnews"/-->
<xsl:apply-templates select="disclaimer"/>
<div id="contentfooter">
<xsl:choose>
	<xsl:when test="lastmodified">
<p><xsl:text>Last modified: </xsl:text><xsl:value-of select="lastmodified"/>.</p>
	</xsl:when>
	<xsl:otherwise>
<xsl:call-template name="moddate"/>
	</xsl:otherwise>
</xsl:choose>
@FOOTER@
</div> <!-- footer -->
</div> <!-- content -->
</div> <!-- midcol -->
<xsl:call-template name="bottomtxt"/>
<div id="footer">&nbsp;</div>
</div> <!-- mainbox -->
<xsl:call-template name="bottom"/>
</body></html>
</xsl:template>

<!-- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx -->

<xsl:template name="commoncol">
	<!-- topsearch is an input field to filter the content of the menu, plus
		if return is pressed, search via google -->
	<div class="pagetitle">Andr&eac;&#39;s 8-bit pages</div>
	<div id="thanks">
		Thankfully hosted by <a href="http://www.6502.org">6502.org</a>.
	</div> <!-- thanks -->
	<div id="topsearch">
		<form method="get" action="http://www.google.com/search" target="_blank" autocomplete="off">
			<input id="searchinput" alt="search" name="q" size="10" maxlength="255" type="text" value=""/>
			<input class="advbutton" value="Search site" type="submit"/><div id="srchprov">(by Google)</div>
			<input name="sitesearch" value="www.6502.org/users/andre" type="hidden"/>
		</form>
		<div id="topfind">
			<div id="topprogress" />
		</div>
	</div> <!-- topsearch -->

	<!-- up to three levels of menu -->
	<div id="menubox">
		@MENU@
	</div>
</xsl:template>

<xsl:template name="bottomtxt">
	<div id="rightcol">
<!--
		<div class="top" id="share"><div class="tophead">share</div><div>
    			<div class="shariff" data-backend-url="https://fachat-shariff-backend.eu-gb.mybluemix.net/" data-theme="grey" data-orientation="vertical"></div>
		</div></div>
-->
		<div class="top" id="twitter"><div class="tophead">follow</div><div>
		            <!--p>Follow my 8-bit tweets on
		            <a class="extlink" target="_blank" href="https://twitter.com/#!/search/realtime/afachat%20%238bit">Twitter</a> (In new window)</p-->
		            <p>Follow my 8-bit tweets on
		            <a class="extlink" target="_blank" href="https://mastodon.online/@afachat">Mastodon</a> (In new window)
				or <a class="extlink" target="_blank" href="https://bsky.app/profile/afachat.bsky.social">Bluesky</a></p>
		</div></div>
		<div class="top" id="forum"><div class="tophead">discuss</div><div>
			<p>Discuss my site on <a class="extlink" target="_blank" href="http://forum.6502.org/viewtopic.php?t=956">this 6502.org forum thread</a></p>
			<xsl:for-each select="//forum[@type='6502.org']">
				<p>Discuss this page's content on <a class="extlink" target="_blank"><xsl:attribute name="href"><xsl:value-of select="."/></xsl:attribute> this 6502.org forum thread</a></p>
			</xsl:for-each>
			<p>(Forum registration required to post)</p>
		</div></div>
		<div class="top" id="hot"><div class="tophead">hot!</div><div>
			@HOT@
		</div></div>
		<xsl:if test="oldnews">
			<div class="top" id="oldnews"><div class="tophead">history</div>
			<div id="oldnewscontent">
				<xsl:apply-templates select="oldnews"/>
			</div></div>
		</xsl:if>
	</div>
</xsl:template>

<xsl:template name="moddate">
	<xsl:text>Last modified: 
</xsl:text>
<xsl:value-of select="$date"/><xsl:text>
	</xsl:text>
</xsl:template>

<!-- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx -->

<xsl:template match="desc">
	<xsl:copy-of select="*|text()"/>
</xsl:template>

<xsl:template match="gallery">
	<div class="gallery">
	<xsl:for-each select="image">
		<div class="galleryimg">
			<xsl:choose>
				<xsl:when test="full">
					<a href="{full}">
					<img class="full" src="{full}" alt="{alt}" />
					<img class="thumb" src="{thumb}" alt="{alt}" />
					</a>
				</xsl:when>
				<xsl:otherwise>
					<a href="{thumb}">
					<img class="full" src="{thumb}" alt="{alt}" />
					<img class="thumb" src="{thumb}" alt="{alt}"/>
					</a>
				</xsl:otherwise>
			</xsl:choose>
			<div class="desc"><xsl:apply-templates select="desc"/></div>
		</div>
	</xsl:for-each>
	<div class="gallend"/>
	</div>
</xsl:template>

<xsl:template match="section">
  <div class="h2">
    <xsl:call-template name="h2toc">
      <xsl:with-param name="hdr"><xsl:value-of select="@name"/></xsl:with-param>
      <xsl:with-param name="a"><xsl:value-of select="@toc"/></xsl:with-param>
    </xsl:call-template>
    <div class="h2c">
      <xsl:apply-templates select="desc"/>
      <xsl:apply-templates select="gallery"/>
      <xsl:apply-templates select="subsection"/>
      <xsl:if test="subitem|extlink|file">
        <ul>
          <xsl:apply-templates select="subitem"/>
          <xsl:apply-templates select="extlink"/>
	  <xsl:apply-templates select="file"/>
        </ul>
      </xsl:if>
    </div><!-- h2c -->
  </div><!-- h2 -->
</xsl:template>

<xsl:template match="subsection">
<h3><a name="{@toc}"><xsl:value-of select="@name"/></a></h3>
<xsl:apply-templates select="desc"/>
<xsl:if test="subitem|extlink">
<ul>
<xsl:apply-templates select="subitem"/>
<xsl:apply-templates select="extlink"/>
</ul>
</xsl:if>
<xsl:if test="file">
<table>
<xsl:apply-templates select="file"/>
</table>
</xsl:if>
</xsl:template>

<xsl:template match="teasers">
<div class="teasers">
<xsl:for-each select="item">
  <div class="teaser">
    <div class="teaserimg"><img src="imgs/{@headerimg}" alt="{@headeralt}"/></div>
    <div class="teaserlst">
	<xsl:apply-templates select="tsubitem"/>
    </div>
  </div>
</xsl:for-each>
<div class="teaserend"/>
</div>
</xsl:template>

<xsl:template name="allrev">
  <xsl:if test="rev">
    <div class="h2">
      <xsl:call-template name="h2toc">
        <xsl:with-param name="hdr">Board revisions</xsl:with-param>
        <xsl:with-param name="a">boards</xsl:with-param>
      </xsl:call-template>
      <div class="h2c">
        <xsl:apply-templates select="rev"/>
      </div><!-- h2c -->
    </div><!-- h2 -->
  </xsl:if>
</xsl:template>

<xsl:template match="rev">
<div class="rev">
<h3><a name="board{position()}">Version: <xsl:value-of select="version"/></a></h3><xsl:text>
</xsl:text>
	<div class="revdesc">
		<p>Status: <xsl:value-of select="status"/></p><xsl:text>
</xsl:text>
	</div><!-- revdesc -->
	<div class="revnotes">
		<xsl:if test="note">
			<h4>Notes</h4>
			<table class="notes">
				<xsl:for-each select="note">
					<tr><td class="noteicon"><div class="i_{@type}">&nbsp;</div></td><xsl:text>
</xsl:text>
					<td><xsl:copy-of select="text()|*"/></td></tr><xsl:text>
</xsl:text>
				</xsl:for-each><!-- note -->
			</table>
		</xsl:if>
	</div><!-- revnotes -->
	<div class="revfiles">
		<xsl:if test="file">
			<h4>Files</h4>
			<table class="files">
				<xsl:apply-templates select="file"/>
			</table>
		</xsl:if><xsl:text>
</xsl:text>
	</div><!-- revfiles -->
	<div class="revend" />
</div><!-- class=rev -->
</xsl:template>

<xsl:template name="alldriver">
  <xsl:if test="driver">
    <div class="h2">
      <xsl:call-template name="h2toc">
        <xsl:with-param name="hdr">Driver</xsl:with-param>
        <xsl:with-param name="a">driver</xsl:with-param>
      </xsl:call-template>
      <div class="h2c">
        <xsl:apply-templates select="driver"/>
      </div><!-- h2c -->
    </div><!-- h2 -->
  </xsl:if>
</xsl:template>

<xsl:template match="driver">
<div class="driver">
	<h3><a name="driver{position()}"><xsl:value-of select="name"/></a></h3>
	<div class="driverdesc">
		<xsl:apply-templates select="desc"/>
	</div>
	<div class="driverfiles">
		<table class="files"><xsl:apply-templates select="file"/></table>
	</div>
	<div class="driverend" />
</div>
</xsl:template>

<xsl:template match="file">
<xsl:variable name="note"><xsl:if test="@note">(<xsl:value-of select="@note"/>)</xsl:if></xsl:variable>
<xsl:text>
</xsl:text><tr class="R{position() mod 2}"><td><div class="i_{@ltype}">&nbsp;</div></td><xsl:text>
</xsl:text><!-- <td><xsl:value-of select="@ptype"/></td><xsl:text>
</xsl:text>--><td><a href="{.}"><xsl:value-of select="."/></a><xsl:value-of select="$note"/></td><xsl:text>
</xsl:text></tr>
</xsl:template>

<!-- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx -->

<xsl:template name="aname">
    <xsl:choose>
	<xsl:when test="@toc">
		<a name="{@toc}"><xsl:value-of select="@name"/></a>
	</xsl:when>
	<xsl:otherwise>
		<xsl:value-of select="@name"/>
	</xsl:otherwise>
    </xsl:choose>
</xsl:template>

<!-- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx -->

<xsl:template match="copyright">
<h3>(C) <xsl:value-of select="start"/><xsl:text> - </xsl:text><xsl:value-of select="end"/><xsl:text> </xsl:text><xsl:value-of select="author"/></h3>
</xsl:template>

<!-- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx -->

<xsl:template match="webpage">
<!--xsl:text disable-output-escaping="yes">&lt;!doctype html&gt;-->
<!--xsl:text disable-output-escaping="yes">&lt;!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/1999/REC-html401-19991224/loose.dtd"&gt;-->
<!--xsl:text disable-output-escaping="yes">&lt;!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN"&gt;-->
<!--xsl:text disable-output-escaping="yes">&lt;!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 3.2 Final//EN"&gt;-->
<!--xsl:text disable-output-escaping="yes">&lt;!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML 2.0//EN"&gt;-->
<!--/xsl:text-->
<html><head> 
	<xsl:call-template name="head"/>
	<title><xsl:value-of select="@name"/></title>
</head><xsl:text>
</xsl:text><body>
<div id="mainbox">
<a name="top"/>
<xsl:call-template name="commoncol"/>
<div id="midcol">
<div class="top" id="content">
<div id="minmax"/>
<xsl:text>

</xsl:text>
<h1><xsl:value-of select="@name"/></h1>

<xsl:for-each select="author">
<p class="copyright">(C)
<xsl:value-of select="yearstart"/>-<xsl:value-of select="yearend"/>
<xsl:text> </xsl:text>
<xsl:value-of select="name"/> 
</p>
<xsl:text> 
</xsl:text>
</xsl:for-each>
<div class="overview">
<xsl:copy-of select="overview/*|overview/text()"/>
</div> <!-- overview -->
<xsl:if test="extlink">
<ul>
<xsl:apply-templates select="extlink"/>
</ul>
</xsl:if>
<xsl:apply-templates select="news"/>
<xsl:apply-templates select="gallery"/>
<xsl:if test="toc"><xsl:call-template name="toc"/></xsl:if>
<xsl:for-each select="itemlist|section">
  <div class="h2">
    <xsl:call-template name="h2toc">
      <xsl:with-param name="hdr"><xsl:value-of select="@name"/></xsl:with-param>
      <xsl:with-param name="a"><xsl:value-of select="@toc"/></xsl:with-param>
    </xsl:call-template>
    <div class="h2c">
      <xsl:apply-templates select="desc"/>
      <xsl:apply-templates select="gallery"/>
      <xsl:apply-templates select="rev"/>
      <xsl:apply-templates select="subsection"/>
      <xsl:apply-templates select="teasers"/>
      <!-- (very) old style pages may still use this -->
      <xsl:for-each select="items[item|subitem|file]">
        <xsl:if test="file">
	  <h3>Files</h3>
	  <table><xsl:apply-templates select="file"/></table>
        </xsl:if>
        <ul>
          <xsl:if test="@class"><xsl:attribute name="class"><xsl:value-of select="@class"/></xsl:attribute></xsl:if>
          <xsl:for-each select="item">
            <li>
	      <xsl:if test="@class"><xsl:attribute name="class"><xsl:value-of select="@class"/></xsl:attribute></xsl:if>
	      <xsl:if test="@icon"><div><xsl:attribute name="class"><xsl:value-of select="@icon"/></xsl:attribute>&nbsp;</div></xsl:if>
	      <strong><xsl:call-template name="aname"/></strong>
              <xsl:apply-templates select="desc"/>
	      <xsl:if test="subitem|extlink">
	        <ul>
                  <xsl:apply-templates select="subitem"/>
                  <xsl:apply-templates select="extlink"/>
	        </ul>
	      </xsl:if>
            </li>
          </xsl:for-each>
          <xsl:apply-templates select="subitem"/>
        </ul>
      </xsl:for-each>
      <xsl:if test="extlink">
        <ul>
          <xsl:apply-templates select="extlink"/>
        </ul>
      </xsl:if>
      <xsl:apply-templates select="disclaimer"/>
    </div><!-- h2c -->
  </div><!-- h2 -->
</xsl:for-each>
<!-- board drivers and revisions -->
<xsl:call-template name="alldriver"/>
<xsl:call-template name="allrev"/>
<!--xsl:apply-templates select="oldnews"/-->
<xsl:apply-templates select="disclaimer"/>
<xsl:apply-templates select="closing"/>
<xsl:call-template name="moddate"/>
</div> <!-- content -->
</div> <!-- midcol -->
<xsl:call-template name="bottomtxt"/>
<div id="footer">&nbsp;</div>
</div> <!-- mainbox -->
<xsl:call-template name="bottom"/>
</body></html>
<xsl:text> 
</xsl:text>
</xsl:template>

<!-- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx -->

<xsl:template match="news">
 <div class="h2">
   <xsl:call-template name="h2toc">
     <xsl:with-param name="hdr">News:</xsl:with-param>
     <xsl:with-param name="a">news</xsl:with-param>
   </xsl:call-template>
   <div class="h2c">
     <ul class="news">
     <xsl:for-each select="item[@state='hot']">
      <li><div class="i_hotnews">&nbsp;</div>
        <small><xsl:value-of select="@date"/></small>
        <xsl:copy-of select="*|text()"/>
      </li>
    </xsl:for-each>
    <xsl:for-each select="item[@state='old' or not(@state)]">
      <li><div>
        <xsl:if test="@state='old'"><xsl:attribute name="class">i_oldnews</xsl:attribute></xsl:if>&nbsp;</div>
        <small><xsl:value-of select="@date"/></small>
        <xsl:copy-of select="*|text()"/>
      </li>
    </xsl:for-each>
    </ul>
  </div><!-- h2c -->
 </div><!-- h2 -->
</xsl:template>

<xsl:template match="oldnews">
 <!--xsl:call-template name="h2toc">
   <xsl:with-param name="hdr">Old News:</xsl:with-param>
   <xsl:with-param name="a">oldnews</xsl:with-param>
 </xsl:call-template-->
 <ul class="news">
 <xsl:for-each select="item[@state!='off' or not(@state)]">
  <li><div>
  <xsl:attribute name="class">i_oldnews</xsl:attribute>&nbsp;</div>
  <small><xsl:value-of select="@date"/></small>
  <xsl:copy-of select="*|text()"/>
  </li>
 </xsl:for-each>
 </ul>
</xsl:template>

<xsl:template match="disclaimer">
  <div class="h2">
    <xsl:call-template name="h2toc">
      <xsl:with-param name="hdr"><xsl:value-of select="@name"/></xsl:with-param>
    </xsl:call-template>
    <div class="h2c">
      <xsl:copy-of select="*|text()"/>
    </div><!-- h2c -->
  </div><!-- h2 -->
</xsl:template>

<xsl:template match="closing">
    <hr/>
    <xsl:copy-of select="*|text()"/>
</xsl:template>

<xsl:template match="extlink">
	<li>
	      <a href="{@link}" target="_blank" class="extlink">
	      <xsl:value-of select="@name"/>
	      </a><xsl:text> </xsl:text>
  	      <xsl:copy-of select="*|text()"/>
	</li>
</xsl:template>

<!-- deprecated use extlink instead -->
<xsl:template match="subitem">
  <xsl:choose>
    <xsl:when test="@link">
	<li class="subitem">
	      <a href="{@link}" target="_blank" class="extlink">
	      <xsl:value-of select="@name"/>
	      </a><xsl:text> </xsl:text>
  	      <xsl:copy-of select="*|text()"/>
	</li>
    </xsl:when>
    <xsl:otherwise>
	<li class="subitem">
	<xsl:if test="@icon"><div><xsl:attribute name="class"><xsl:value-of select="@icon"/></xsl:attribute>&nbsp;</div></xsl:if>
	      <strong>
	      <xsl:value-of select="@name"/>
	      </strong>: <!--<br/>-->
  	      <xsl:copy-of select="*|text()"/>
	</li>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- teaser subitem -->
<xsl:template match="tsubitem">
  <xsl:choose>
    <xsl:when test="@link">
	<h3 class="subitem">
	      <a href="{@link}" target="_blank" class="extlink">
	      <xsl:value-of select="@name"/>
	      </a>
	</h3>
  	<xsl:copy-of select="*|text()"/>
    </xsl:when>
    <xsl:otherwise>
	<h3 class="subitem">
	<xsl:if test="@icon"><div><xsl:attribute name="class"><xsl:value-of select="@icon"/></xsl:attribute>&nbsp;</div></xsl:if>
	      <xsl:value-of select="@name"/>
	</h3>
        <xsl:copy-of select="*|text()"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="*|@*|text()|comment()">
   <xsl:copy></xsl:copy>
</xsl:template>

<xsl:template name="head">
<xsl:text>
</xsl:text>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/><xsl:text>
</xsl:text>
<meta name="viewport" content="width=device-width; initial-scale=1.0; maximum-scale=1.0; user-scalable=0;" /><xsl:text>
</xsl:text>
<meta name="author" content="{author/name}"/><xsl:text>

</xsl:text>
<meta name="description" content="{metadesc}"/><xsl:text>
</xsl:text>
<meta name="keywords" content="{keywords}"/><xsl:text>
</xsl:text>
<link rev="made" href="mailto:{author/email}"/><xsl:text>
</xsl:text>
<link rel="stylesheet" title="Default" type="text/css" href="%up%style2-min.css"/>
<!--
<link href="%up%shariff.complete.css" rel="stylesheet"/>
-->
<xsl:if test="style">
  <link rel="stylesheet" type="text/css" href="{style}"/>
</xsl:if>
<!--link rel="alternate stylesheet" title="Advanced" type="text/css" href="%up%advanced.css"/-->
<xsl:text>
</xsl:text>
</xsl:template>

<xsl:template name="bottom">
  <script type="text/javascript">myUp="%up%";</script>
  <script type="text/javascript" src="%up%scripts2-all.js"></script>
<!--
  <script type="text/javascript" src="%up%shariff.min.js"></script>
-->
</xsl:template>

</xsl:stylesheet>

