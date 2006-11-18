<?xml version="1.0"?>
<!DOCTYPE xsl:stylesheet [ <!ENTITY eac "&#38;eacute; "> ] >
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<!-- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx -->

<xsl:template match="board">
<HTML><HEAD><xsl:text>
</xsl:text>
<META HTTP-EQUIV="content-type" CONTENT="text/html; charset=iso8859-1"/><xsl:text>
</xsl:text>
<META NAME="keywords" CONTENT="{keywords}"/>
<TITLE><xsl:value-of select="name"/></TITLE>
<LINK REL="stylesheet" TYPE="text/css" HREF="%up%style.css"/>
</HEAD><xsl:text>
</xsl:text><BODY>
@MENU@
<DIV ID="content"><xsl:text>
</xsl:text><H1><xsl:value-of select="name"/></H1><xsl:text>
</xsl:text><P><xsl:copy-of select="desc/*|desc/text()"/></P><xsl:text>
</xsl:text>
<xsl:apply-templates select="news"/>
<DIV ID="toc">
<H2>Table of content</H2>
<dir>
<xsl:for-each select="section">
<li><a href="#{@toc}"><xsl:value-of select="@name"/></a></li>
<xsl:if test="subsection">
<dir>
<xsl:for-each select="subsection">
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
</dir>
</DIV>
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
<P><xsl:copy-of select="diagram/desc"/></P>
</xsl:if>
<xsl:apply-templates select="disclaimer"/>
<DIV ID="footer">
<P><xsl:text>Last modified: </xsl:text><xsl:value-of select="lastmodified"/>.</P>
@FOOTER@
</DIV>
</DIV>
</BODY></HTML>
</xsl:template>

<xsl:template match="section">
<H2><a name="{@toc}"><xsl:value-of select="@name"/></a></H2>
<xsl:if test="desc"><p><xsl:copy-of select="desc/*|desc/text()"/></p></xsl:if>
<xsl:apply-templates select="subsection"/>
<ul>
<xsl:apply-templates select="subitem"/>
</ul>
</xsl:template>

<xsl:template match="subsection">
<H3><a name="{@toc}"><xsl:value-of select="@name"/></a></H3>
<xsl:copy-of select="*|text()"/>
</xsl:template>

<xsl:template match="rev">
<H3><A NAME="board{position()}">Version: <xsl:value-of select="version"/></A></H3><xsl:text>
</xsl:text>
<P>Status: <xsl:value-of select="status"/></P><xsl:text>
</xsl:text>
<TABLE>
<xsl:for-each select="note">
<TR><TD><IMG SRC="%up%imgs/note_{@type}.gif" ALT="{@type}"/></TD><xsl:text>
</xsl:text><TD><xsl:copy-of select="text()|*"/></TD></TR><xsl:text>
</xsl:text>
</xsl:for-each><!-- note -->
</TABLE>
<TABLE>
<xsl:apply-templates select="file"/>
</TABLE><xsl:text>
</xsl:text>
</xsl:template>

<xsl:template match="driver">
<H3><A NAME="driver{position()}"><xsl:value-of select="name"/></A></H3>
<P><xsl:copy-of select="desc/*|desc/text()"/></P>
<TABLE><xsl:apply-templates select="file"/></TABLE>
</xsl:template>

<xsl:template match="file">
<xsl:variable name="note"><xsl:if test="@note">(<xsl:value-of select="@note"/>)</xsl:if></xsl:variable>
<xsl:text>
</xsl:text><TR><TD><IMG SRC="%up%imgs/file_{@ltype}.gif" ALT="{@ltype}"/></TD><xsl:text>
</xsl:text><!-- <TD><xsl:value-of select="@ptype"/></TD><xsl:text>
</xsl:text>--><TD><A HREF="{.}"><xsl:value-of select="."/></A><xsl:value-of select="$note"/></TD><xsl:text>
</xsl:text></TR>
</xsl:template>

<!-- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx -->

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
<LINK REL="stylesheet" TYPE="text/css" HREF="%up%style.css"/>
</head>
<xsl:text>
</xsl:text>
<body>
@MENU@
<DIV ID="content">
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
<p>
<xsl:copy-of select="overview/*|overview/text()"/>
</p>
<xsl:apply-templates select="news"/>
<xsl:for-each select="itemlist">
  <h2><xsl:value-of select="@name"/></h2>
  <xsl:apply-templates select="description"/>
   <xsl:for-each select="items[item|subitem]">
   <ul>
    <xsl:if test="@class"><xsl:attribute name="class"><xsl:value-of select="@class"/></xsl:attribute></xsl:if>
    <xsl:apply-templates select="subitem"/>
    <xsl:for-each select="item">
      <li>
	<xsl:if test="@class"><xsl:attribute name="class"><xsl:value-of select="@class"/></xsl:attribute></xsl:if>
	<strong><xsl:value-of select="@name"/></strong><br/>
        <br/>
	<ul>
          <xsl:apply-templates select="subitem"/>
	</ul>
      </li>
      <br/>
    </xsl:for-each>
   </ul>
   </xsl:for-each>
  <xsl:apply-templates select="disclaimer"/>
</xsl:for-each>
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
 <xsl:for-each select="item">
  <li>
  <xsl:if test="@state='old'"><xsl:attribute name="class">oldnews</xsl:attribute></xsl:if>
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

<xsl:template match="description">
    <xsl:copy-of select="*|text()"/>
</xsl:template>

<xsl:template match="closing">
    <hr/>
    <xsl:copy-of select="*|text()"/>
</xsl:template>

<xsl:template match="subitem[@link]">
	<li class="subitem">
	      <a href="{@link}">
	      <xsl:value-of select="@name"/>
	      </a><!--<br/>-->
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

