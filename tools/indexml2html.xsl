<?xml version="1.0"?>
<!DOCTYPE xsl:stylesheet [ <!ENTITY eac "&#38;eacute; "> ] >
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<!-- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx -->

<xsl:template name="toc">
<DIV ID="toc">
<H2>Table of content</H2>
<dir>
<xsl:for-each select="section|itemlist">
<li><a href="#{@toc}"><xsl:value-of select="@name"/></a></li>
<xsl:if test="subsection|items/item">
<dir>
<xsl:for-each select="subsection|items/item">
<li><a href="#{@toc}"><xsl:value-of select="@name"/></a></li>
</xsl:for-each>
</dir>
</xsl:if>
</xsl:for-each>
<xsl:if test="driver">
<li><a href="#driver">Driver</a></li>
<dir>
<xsl:for-each select="driver">
<li><a href="#driver{position()}"><xsl:value-of select="name"/></a></li>
</xsl:for-each>
</dir>
</xsl:if>
<xsl:if test="rev">
<li><a href="#boards">Board Revisions</a></li>
<dir>
<xsl:for-each select="rev">
<li><a href="#board{position()}"><xsl:value-of select="version"/></a> (<xsl:value-of select="status"/>)</li>
</xsl:for-each>
</dir>
</xsl:if>
<xsl:if test="diagram">
<li><a href="#blkdiag">Block diagram</a></li>
</xsl:if>
<xsl:if test="oldnews">
<li><a href="#oldnews">Old News</a></li>
</xsl:if>
</dir>
</DIV>
</xsl:template>

<!-- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx -->

<xsl:template match="board">
<HTML><HEAD><xsl:text>
</xsl:text>
<META HTTP-EQUIV="content-type" CONTENT="text/html; charset=iso8859-1"/><xsl:text>
</xsl:text>
<META NAME="keywords" CONTENT="{keywords}"/>
<TITLE><xsl:value-of select="name"/></TITLE>
<LINK REL="stylesheet" TITLE="Default" TYPE="text/css" HREF="%up%style.css"/>
<LINK REL="alternate stylesheet" TITLE="Advanced" TYPE="text/css" HREF="%up%advanced.css"/>
</HEAD><xsl:text>
</xsl:text><BODY>
@MENU@
<DIV class="top" ID="content"><xsl:text>
</xsl:text><H1><xsl:value-of select="name"/></H1><xsl:text>
</xsl:text><xsl:apply-templates select="copyright"/><xsl:text>
</xsl:text><div class="overview"><xsl:apply-templates select="desc"/><xsl:text>
</xsl:text></div>
<xsl:apply-templates select="news"/>
<xsl:call-template name="toc"/>
<xsl:apply-templates select="section"/>
<xsl:if test="driver">
<H2><A NAME="driver">Driver</A></H2>
<xsl:apply-templates select="driver"/>
</xsl:if>
<xsl:if test="rev">
<H2><A NAME="boards">Board revisions</A></H2>
<xsl:apply-templates select="rev"/>
</xsl:if>
<xsl:if test="diagram">
<H2><A name="blkdiag">Block diagram</A></H2>
<img src="{diagram/file}" alt="block diagram"/>
<xsl:apply-templates select="diagram/desc"/>
</xsl:if>
<xsl:apply-templates select="oldnews"/>
<xsl:apply-templates select="disclaimer"/>
<DIV ID="footer">
<P><xsl:text>Last modified: </xsl:text><xsl:value-of select="lastmodified"/>.</P>
@FOOTER@
</DIV>
</DIV>
</BODY></HTML>
</xsl:template>


<xsl:template match="desc">
<p><xsl:copy-of select="*|text()"/></p>
</xsl:template>

<xsl:template match="section">
<H2><a name="{@toc}"><xsl:value-of select="@name"/></a></H2>
<xsl:apply-templates select="desc"/>
<xsl:apply-templates select="subsection"/>
<xsl:if test="subitem|extlink">
<ul>
<xsl:apply-templates select="subitem"/>
<xsl:apply-templates select="extlink"/>
</ul>
</xsl:if>
</xsl:template>

<xsl:template match="subsection">
<H3><a name="{@toc}"><xsl:value-of select="@name"/></a></H3>
<xsl:apply-templates select="desc"/>
<xsl:if test="subitem|extlink">
<ul>
<xsl:apply-templates select="subitem"/>
<xsl:apply-templates select="extlink"/>
</ul>
</xsl:if>
</xsl:template>

<xsl:template match="rev">
<H3><A NAME="board{position()}">Version: <xsl:value-of select="version"/></A></H3><xsl:text>
</xsl:text>
<P>Status: <xsl:value-of select="status"/></P><xsl:text>
</xsl:text>
<xsl:if test="note">
<H4>Notes</H4>
<TABLE class="notes">
<xsl:for-each select="note">
<TR><TD class="noteicon"><IMG SRC="%up%imgs/note_{@type}.gif" ALT="{@type}"/></TD><xsl:text>
</xsl:text><TD><xsl:copy-of select="text()|*"/></TD></TR><xsl:text>
</xsl:text>
</xsl:for-each><!-- note -->
</TABLE>
</xsl:if>
<xsl:if test="file">
<H4>Files</H4>
<TABLE class="files">
<xsl:apply-templates select="file"/>
</TABLE></xsl:if><xsl:text>
</xsl:text>
</xsl:template>

<xsl:template match="driver">
<H3><A NAME="driver{position()}"><xsl:value-of select="name"/></A></H3>
<xsl:apply-templates select="desc"/>
<TABLE class="files"><xsl:apply-templates select="file"/></TABLE>
</xsl:template>

<xsl:template match="file">
<xsl:variable name="note"><xsl:if test="@note">(<xsl:value-of select="@note"/>)</xsl:if></xsl:variable>
<xsl:text>
</xsl:text><TR CLASS="R{position() mod 2}"><TD><IMG SRC="%up%imgs/file_{@ltype}.gif" ALT="{@ltype}"/></TD><xsl:text>
</xsl:text><!-- <TD><xsl:value-of select="@ptype"/></TD><xsl:text>
</xsl:text>--><TD><A HREF="{.}"><xsl:value-of select="."/></A><xsl:value-of select="$note"/></TD><xsl:text>
</xsl:text></TR>
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

<xsl:template match="webpage">
<html><head>
<xsl:text>
</xsl:text>
<meta name="author" content="{author/name}"/><xsl:text>
</xsl:text>
<meta http-equiv="content-type" content="text/html; charset=iso8859-1"/><xsl:text>
</xsl:text>
<meta name="description" content="{metadesc}"/><xsl:text>
</xsl:text>
<meta name="keywords" content="{keywords}"/><xsl:text>
</xsl:text>
<title><xsl:value-of select="@name"/></title><xsl:text>
</xsl:text>
<link rev="made" href="mailto:{author/email}"/><xsl:text>
</xsl:text>
<LINK REL="stylesheet" TITLE="Default" TYPE="text/css" HREF="%up%style.css"/>
<LINK REL="alternate stylesheet" TITLE="Advanced" TYPE="text/css" HREF="%up%advanced.css"/>
</head>
<xsl:text>
</xsl:text>
<body>
@MENU@
<DIV class="top" ID="content">
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
</div>
<xsl:apply-templates select="news"/>
<xsl:if test="toc"><xsl:call-template name="toc"/></xsl:if>
<xsl:for-each select="itemlist|section">
  <h2><xsl:call-template name="aname"/></h2>
  <xsl:apply-templates select="desc"/>
  <xsl:apply-templates select="subsection"/>
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
	<strong><xsl:call-template name="aname"/></strong><br/>
        <br/>
          <xsl:apply-templates select="desc"/>
	  <xsl:if test="subitem|extlink">
	<ul>
          <xsl:apply-templates select="subitem"/>
          <xsl:apply-templates select="extlink"/>
	</ul>
	  </xsl:if>
      </li>
      <br/>
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
</xsl:for-each>
<xsl:apply-templates select="oldnews"/>
<xsl:apply-templates select="disclaimer"/>
<xsl:apply-templates select="closing"/>
</DIV></body></html>
<xsl:text> 
</xsl:text>
</xsl:template>

<!-- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx -->

<xsl:template match="news">
 <h3>News:</h3>
 <ul class="news">
 <xsl:for-each select="item[@state='hot']">
  <li class="hotnews">
  <small><xsl:value-of select="@date"/></small>
  <xsl:copy-of select="*|text()"/>
  </li>
 </xsl:for-each>
 <xsl:for-each select="item[@state='old' or not(@state)]">
  <li>
  <xsl:if test="@state='old'"><xsl:attribute name="class">oldnews</xsl:attribute></xsl:if>
  <small><xsl:value-of select="@date"/></small>
  <xsl:copy-of select="*|text()"/>
  </li>
 </xsl:for-each>
 </ul>
</xsl:template>

<xsl:template match="oldnews">
 <h2><a name="oldnews">Old News:</a></h2>
 <ul class="oldnews">
 <xsl:for-each select="item[@state!='off']">
  <li>
  <xsl:attribute name="class">oldnews</xsl:attribute>
  <small><xsl:value-of select="@date"/></small>
  <xsl:copy-of select="*|text()"/>
  </li>
 </xsl:for-each>
 </ul>
</xsl:template>

<xsl:template match="disclaimer">
    <h2><xsl:value-of select="@name"/></h2>
    <p><xsl:copy-of select="*|text()"/></p>
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
<xsl:template match="subitem[@link]">
	<li class="subitem">
	      <a href="{@link}">
	      <xsl:value-of select="@name"/>
	      </a><xsl:text> </xsl:text>
  	      <xsl:copy-of select="*|text()"/>
        <br/>
        <br/>
	</li>
</xsl:template>

<xsl:template match="subitem">
	<li>
	      <strong>
	      <xsl:value-of select="@name"/>
	      </strong>: <!--<br/>-->
  	      <xsl:copy-of select="*|text()"/>
        <br/>
        <br/>
	</li>
</xsl:template>

<xsl:template match="*|@*|text()|comment()">
   <xsl:copy></xsl:copy>
</xsl:template>

</xsl:stylesheet>

