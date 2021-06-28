<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="1.0" xmlns:res="http://www.esri.com/metadata/res/" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:gmd="http://www.isotc211.org/2005/gmd" 
  xmlns:gmi="http://www.isotc211.org/2005/gmi">

<!-- An XSLT template for displaying metadata that is stored in the ArcGIS metadata format.
Modified from ESRI xslt, for use by ESRI Geoportal 
Copyright (c) 2009-2010, Environmental Systems Research Institute, Inc. All rights reserved.
Revision History: Created 3/19/2009 avienneau
2011-10-17 SMR simplified so just does ISO19139 for USGIN. This is just a shell; actual transformation 
is done ISO19139usgin.xslt. Leave it here so nothing in Geoportal gets broken...
-->

  <xsl:import href = "imports/general.xslt" />
  <xsl:import href = "imports/iso19139usgin.xslt" />
  <xsl:import href = "imports/XML.xslt" />
  <xsl:import href = "imports/codelists.xslt" />
  <xsl:import href = "imports/auxLanguages.xslt" />
  <xsl:import href = "imports/auxCountries.xslt" />
  <xsl:import href = "imports/auxUCUM.xslt" />
  <xsl:import href = "ISO19139ToSchemaOrgDataset1.0.xslt"/>
  <xsl:param name="isopath"></xsl:param>
  
  <xsl:output method="xml" indent="yes" encoding="UTF-8" doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN" doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd" />
  
  <xsl:variable name="iso19139" select="count(//*[(local-name() = 'MD_Metadata') or (local-name() = 'MI_Metadata')])>0 " />
  
  <xsl:param name="flowdirection"/>

  <xsl:template match="/">
  <html xmlns="http://www.w3.org/1999/xhtml">
  <xsl:if test="/*/@xml:lang[. != '']">
	  <xsl:attribute name="xml:lang"><xsl:value-of select="/*/@xml:lang"/></xsl:attribute>
	  <xsl:attribute name="lang"><xsl:value-of select="/*/@xml:lang"/></xsl:attribute>
  </xsl:if>
  
  <head>
    <meta http-equiv="content-type" content="text/html; charset=UTF-8"/>
    <xsl:call-template name="styles" />
    <xsl:call-template name="scripts" />
    
    <script type="application/ld+json">
      <xsl:text>&#10;</xsl:text>
      <xsl:call-template name="iso2sdo">
        <xsl:with-param name="isopath" select="$isopath"/>
      </xsl:call-template>
      <xsl:text>&#10;</xsl:text>
    </script>
    
  </head>

  <body oncontextmenu="return true">
  <xsl:if test="$flowdirection = 'RTL'">
    <xsl:attribute name="style">direction:rtl;</xsl:attribute>
  </xsl:if>
    
	<xsl:if test="$iso19139">
		<xsl:call-template name="iso19139"/> 
	</xsl:if>

	<xsl:if test="not($iso19139)">
		<xsl:call-template name="unknown" /> 
	</xsl:if>

  </body>
  </html>

</xsl:template>

</xsl:stylesheet>