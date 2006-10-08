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
<DIV ID="menu">
@MENU@
</DIV>
<DIV ID="content"><xsl:text>
</xsl:text><H1><xsl:value-of select="name"/></H1><xsl:text>
</xsl:text><P><xsl:value-of select="desc"/></P><xsl:text>
</xsl:text>
<xsl:for-each select="rev">
<H2>Version: <xsl:value-of select="version"/></H2><xsl:text>
</xsl:text>
<P>Status: <xsl:value-of select="status"/></P><xsl:text>
</xsl:text>
<xsl:for-each select="note">
<TABLE><TR><TD><IMG SRC="%up%imgs/note_{@type}.gif" ALT="{@type}"/></TD><xsl:text>
</xsl:text><TD><xsl:copy-of select="text()"/></TD></TR></TABLE><xsl:text>
</xsl:text>
</xsl:for-each><!-- note -->

<TABLE><xsl:for-each select="file"><xsl:text>
</xsl:text><TR><TD><IMG SRC="%up%imgs/file_{@ltype}.gif" ALT="{@ltype}"/></TD><xsl:text>
</xsl:text><!-- <TD><xsl:value-of select="@ptype"/></TD><xsl:text>
</xsl:text>--><TD><A HREF="{.}"><xsl:value-of select="."/></A></TD><xsl:text>
</xsl:text></TR>
</xsl:for-each><!-- file -->
</TABLE><xsl:text>
</xsl:text>
</xsl:for-each><!-- rev -->
<BR></BR>
<P><xsl:text>Last modified: @LASTMODIFIED@</xsl:text></P>
</DIV>
</BODY></HTML>
</xsl:template>

<!-- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx -->

<xsl:template match="webpage">
<html><head><base target="_top"/>
<xsl:text>
</xsl:text>
<meta name="author" content="{author/name}"/>
<xsl:text>
</xsl:text>
<meta http-equiv="content-type" content="text/html; charset=iso8859-1"/>
<xsl:text>
</xsl:text>
<meta name="description" content="{metadesc}"/>
<xsl:text>
</xsl:text>
<meta name="keywords" content="{keywords}"/>
<xsl:text>
</xsl:text>
<title>www.6502.org: <xsl:value-of select="@name"/></title>
<xsl:text>
</xsl:text>
<link rev="made" href="mailto:{author/email}"/>
</head>
<xsl:text>
</xsl:text>
<body bgcolor="#ffffff" text="#000000" link="#0000ff" alink="#ff0000" vlink="#220088">
<xsl:text>
</xsl:text>
<img src="@WEBROOT@/logo2.png" alt="logo" align="left"/>
<A HREF="http://www.6502.org"><IMG SRC="http://www.6502.org/mainlink.jpg" align="right" border="0" alt="[Return to www.6502.org]"/></A><br/>
<xsl:text>
</xsl:text>
<h1><xsl:value-of select="@name"/></h1>

<xsl:for-each select="author">
<h2>(C)
<xsl:value-of select="yearstart"/>-<xsl:value-of select="yearend"/>
<xsl:text> </xsl:text>
<xsl:value-of select="name"/> 
&lt;<a href="mailto:{email}"><xsl:value-of select="email"/></a>&gt; 
[<a href="{homepage}">Homepage</a>]</h2>
<xsl:text> 
</xsl:text>
</xsl:for-each>

<p>
<xsl:value-of select="overview"/>
</p>
<xsl:apply-templates select="news"/>
<xsl:for-each select="itemlist">
  <hr/>
  <h3><xsl:value-of select="@name"/></h3>
  <xsl:apply-templates select="description"/>
   <xsl:for-each select="items[item|subitem]">
   <ul>
    <xsl:apply-templates select="subitem"/>
    <xsl:for-each select="item">
      <li><strong><xsl:value-of select="@name"/></strong><br/>
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
</body></html>
<xsl:text> 
</xsl:text>
</xsl:template>

<!-- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx -->

<xsl:template match="news">
 <hr/>
 <strong>News:</strong>
 <xsl:for-each select="item">
  <p>
  <small><xsl:value-of select="@date"/></small>
  <xsl:copy-of select="*|text()"/>
  </p>
 </xsl:for-each>
</xsl:template>

<xsl:template match="disclaimer">
    <hr/>
    <h4><xsl:value-of select="@name"/></h4>
    <xsl:copy-of select="*|text()"/>
</xsl:template>

<xsl:template match="description">
    <xsl:copy-of select="*|text()"/>
</xsl:template>

<xsl:template match="closing">
    <hr/>
    <xsl:copy-of select="*|text()"/>
</xsl:template>

<xsl:template match="subitem[@link]">
	<li>
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

