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
<H2>Board revisions</H2>
<xsl:for-each select="rev">
<H3>Version: <xsl:value-of select="version"/></H3><xsl:text>
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

<TABLE><xsl:for-each select="file"><xsl:text>
</xsl:text><TR><TD><IMG SRC="%up%imgs/file_{@ltype}.gif" ALT="{@ltype}"/></TD><xsl:text>
</xsl:text><!-- <TD><xsl:value-of select="@ptype"/></TD><xsl:text>
</xsl:text>--><TD><A HREF="{.}"><xsl:value-of select="."/></A></TD><xsl:text>
</xsl:text></TR>
</xsl:for-each><!-- file -->
</TABLE><xsl:text>
</xsl:text>
</xsl:for-each><!-- rev -->
<xsl:if test="diagram">
<H2>Block diagram</H2>
<img src="{diagram/file}" alt="block diagram"/>
<P><xsl:copy-of select="diagram/desc"/></P>
</xsl:if>
<BR></BR>
<P><xsl:text>Last modified: </xsl:text><xsl:value-of select="lastmodified"/>.</P>
</DIV>
</BODY></HTML>
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
<h2>(C)
<xsl:value-of select="yearstart"/>-<xsl:value-of select="yearend"/>
<xsl:text> </xsl:text>
<xsl:value-of select="name"/> 
</h2>
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
</DIV></body></html>
<xsl:text> 
</xsl:text>
</xsl:template>

<!-- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx -->

<xsl:template match="news">
 <hr/>
 <h3>News:</h3>
 <ul class="news">
 <xsl:for-each select="item">
  <li>
  <small><xsl:value-of select="@date"/></small>
  <xsl:copy-of select="*|text()"/>
  </li>
 </xsl:for-each>
 </ul>
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

