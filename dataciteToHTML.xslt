<?xml version="1.0"?>
<!--
    Document   : dataciteToHTML.xsl. (version created from datadoi.xsl)
    Original Created on : February 18, 2015, 11:49 AM
    Author     : vickiferrini

    Description: XSLT to generate html for IEDA Data DOI landing page.
	Repository : https://github.com/iedadata/resources
    
    Updates
               : May 26, 2017  Stephen Richard adapt for Datacite v4; use local names so is 
			   version-agnostic.  Only major change in v4 is geoLocation encoding
		       : 2018-02-05.  Superseded by dataciteToHTMLwithSDO.xsl SMR 
			   
			   
 * @copyright    2007-2017 Interdisciplinary Earth Data Alliance, Columbia University. All Rights Reserved.
 *               Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance 
                 with the License. You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
 *
 *               Unless required by applicable law or agreed to in writing, software distributed under the License is 
                 distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. 
				 See the License for the specific language governing permissions and limitations under the License
			   
-->

<xsl:stylesheet xmlns:k4="http://datacite.org/schema/kernel-4"
    xmlns:k3="http://datacite.org/schema/kernel-3" xmlns:k2="http://datacite.org/schema/kernel-2.2"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
    <xsl:output method="html"/>
    <xsl:template match="/">

        <html>
            <head>
                <title>IEDA Data DOI</title>
                <!--          <link rel="stylesheet" href="/doi/datadoi.css"/>-->
                <link rel="stylesheet" href="http://get.iedadata.org/doi/datadoi.css"/>
                <link rel="stylesheet" href="http://www.marine-geo.org/css/mapv3.css"/>
                <link rel="stylesheet" type="text/css"
                    href="http://www.marine-geo.org/inc/jquery-ui-1.10.2.custom/css/smoothness/jquery-ui-1.10.2.custom.min.css"
                    media="all"/>
                <script src="http://maps.googleapis.com/maps/api/js?key=AIzaSyATYahozDIlFIM1mO7o66AocXi72mkPT18&amp;sensor=false&amp;libraries=drawing" type="text/javascript"/>
                <script type="text/javascript" src="http://www.marine-geo.org/inc/jquery-1.9.1.js"/>
                <script type="text/javascript" src="http://www.marine-geo.org/inc/jquery-ui-1.10.2.custom.min.js"/>
                <script type="text/javascript" src="http://www.marine-geo.org/inc/basemap_v3.js"/>
                <!-- <script type="text/javascript" src="/doi/doimap.js"/>-->
                <script type="text/javascript" src="http://get.iedadata.org/doi/doimap.js"/>
            </head>

            <xsl:element name="body">
                <xsl:choose>
                    <xsl:when test="//@alternateIdentifierType = 'CSDMS'">
                        <xsl:attribute name="onload">
                            <xsl:text>window.location.href='</xsl:text>
                            <xsl:text>http://csdms.colorado.edu/wiki/Model:</xsl:text>
                            <xsl:value-of select="//*[@alternateIdentifierType = 'CSDMS'][1]"/>
                            <xsl:text>'</xsl:text>
                        </xsl:attribute>
                    </xsl:when>
                    <xsl:otherwise>
                        <div id="container">
                            <div>
                                <a href="http://www.iedadata.org">
                                    <img onclick="http://www.iedadata.org"
                                        src="http://get.iedadata.org/doi/ieda_logo_200x88.png"
                                        alt="IEDA"/>
                                </a>
                            </div>
                            <h1>
                                <xsl:text>Data DOI: </xsl:text>
                                <xsl:value-of select="//*[local-name() = 'identifier']"/>
                            </h1>
                            <div id="right-side">
                                <xsl:apply-templates select="//k3:geoLocations"/>
                                <xsl:apply-templates select="//k4:geoLocations"/>
                            </div>
                            <div>
                                <!--  CITATION for resource -->
                                <div class="row">
                                    <div class="title">
                                        <xsl:text>Citation:</xsl:text>
                                    </div>
                                    <div class="description">
                                        <xsl:value-of select="//*[local-name() = 'creatorName'][1]"/>
                                        <xsl:variable name="thecount"
                                            select="count(//*[local-name() = 'creatorName'])"/>
                                        <xsl:if test="count(//*[local-name() = 'creatorName']) > 1">
                                            <xsl:text>, et al., </xsl:text>
                                        </xsl:if>
                                        <xsl:text> (</xsl:text>
                                        <xsl:value-of select="//*[local-name() = 'publicationYear']"/>
                                        <!--<xsl:value-of select="substring(/k3:resource/k3:dates/k3:date[@dateType='Created'],1,4)"/> -->
                                        <xsl:text>), </xsl:text>
                                        <!-- will potentially have problems here if there are multiple titles; this just takes the first one -->
                                        <xsl:value-of disable-output-escaping="yes"
                                            select="//*[local-name() = 'title'][1]"/>
                                        <xsl:text>. </xsl:text>
                                        <xsl:variable name="thepublisher" select="//*[local-name() = 'publisher']"/>
                                        <xsl:choose>
                                            <xsl:when test="contains($thepublisher,'Integrated Earth Data Applications')">
                                                <xsl:value-of select="string('Interdisciplinary Earth Data Alliance (IEDA)')"/>
                                            </xsl:when>
                                            <xsl:when test="contains(normalize-space($thepublisher),'EarthChem Library')">
                                                <xsl:value-of select="string('Interdisciplinary Earth Data Alliance (IEDA)')"/>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:value-of  disable-output-escaping="yes" select="normalize-space(string($thepublisher))"/>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                        <xsl:text>. doi:</xsl:text>
                                        <xsl:value-of select="//*[local-name() = 'identifier']"/>
                                    </div>
                                </div>

                                <!-- resource TITLE -->
                                <div class="row">
                                    <div class="title">Title:</div>
                                    <div class="description">
                                        <xsl:for-each select="//*[local-name() = 'title']">
                                            <div>
                                                <xsl:if test="@titleType">
                                                  <xsl:value-of
                                                  select="normalize-space(string(@titleType))"/>
                                                  <xsl:text>: </xsl:text>
                                                </xsl:if>
                                                <xsl:value-of disable-output-escaping="yes"
                                                  select="normalize-space(string(.))"/>
                                            </div>
                                        </xsl:for-each>
                                    </div>
                                </div>

                                <!-- resource DESCRIPTIONS -->
                                <xsl:if test="//*[local-name() = 'descriptions']">
                                    <xsl:for-each select="//*[local-name() = 'description']">
                                        <xsl:if test="string-length(normalize-space(string(.))) > 0 and 
                                            not(normalize-space(string(.)) = 'Related publications:')">
                                        <div class="row">
                                            <div class="title">
                                                <xsl:choose>
                                                  <xsl:when test="@descriptionType = 'Other'">
                                                    <xsl:value-of select="string('Other Description')"/>
                                                  </xsl:when>
                                                  <xsl:when test="@descriptionType">
                                                    <xsl:value-of disable-output-escaping="yes"
                                                            select="normalize-space(string(@descriptionType))"/>
                                                  </xsl:when>
                                                    <!-- no description type property -->
                                                  <xsl:otherwise>
                                                    <xsl:value-of select="string('Description')"/>
                                                  </xsl:otherwise>
                                                </xsl:choose>
                                                <xsl:text>: </xsl:text>
                                            </div>
                                            <div class="description">
                                                <xsl:value-of disable-output-escaping="yes"
                                                  select="normalize-space(string(.))"/>
                                            </div>
                                        </div>
                                </xsl:if>
                                    </xsl:for-each>
                                </xsl:if>

                                <!--  resource CREATORS -->
                                <div class="row">
                                    <div class="title">
                                        <xsl:text>Creator(s):</xsl:text>
                                    </div>
                                    <div class="description">
                                        <xsl:for-each select="//*[local-name() = 'creator']">
                                            <div>
                                                <xsl:value-of disable-output-escaping="yes"
                                                  select="normalize-space(string(*[local-name() = 'creatorName']))"/>
                                                <xsl:for-each
                                                  select="*[local-name() = 'affiliation']">
                                                  <xsl:text>, </xsl:text>
                                                    <xsl:value-of disable-output-escaping="yes" select="normalize-space(string(.))"/>
                                                </xsl:for-each>
                                                <xsl:for-each  select="*[local-name() = 'nameIdentifier']">
                                                    <xsl:choose>
                                                      <xsl:when test="@nameIdentifierScheme = 'SCOPUS'">
                                                          <xsl:text>; ScopusID:</xsl:text>
                                                          <a
                                                              href="https://www.scopus.com/authid/detail.uri?authorId={.}">
                                                              <xsl:value-of select="."/>
                                                          </a>
                                                      </xsl:when>
                                                        <xsl:when test="@nameIdentifierScheme = 'ORCID'">
                                                            <xsl:text>; ORCID:</xsl:text>
                                                            <a
                                                                href="https://orcid.org/{.}">
                                                                <xsl:value-of select="."/>
                                                            </a>
                                                        </xsl:when>

                                                        <xsl:when test="(@nameIdentifierScheme = 'e-mail address') 
                                                            or contains(.,'mailto:')" >
                                                            <xsl:choose>
                                                                <xsl:when test="contains(.,'mailto:')">
                                                                    <xsl:text>; e-mail: </xsl:text>
                                                                        <xsl:value-of select="substring(.,8)"/>
                                                                </xsl:when>
                                                                <xsl:otherwise>
                                                                        <xsl:value-of select="concat('; e-mail: ',.)"/>
                                                                </xsl:otherwise>
                                                            </xsl:choose>
                                                        </xsl:when>
                                                        <!-- handle other possible schemes, but not MGDS or UTIG, which simply echo
                                                            creator name with different syntax -->
                                                        <xsl:when test="(@nameIdentifierScheme 
                                                            and not(string(@nameIdentifierScheme)='MGDS')
                                                            and not(string(@nameIdentifierScheme)='UTIG')
                                                            and not(contains(string(.),'urn'))
                                                            ) ">
                                                            <xsl:text>, </xsl:text>
                                                            <xsl:value-of select="normalize-space(string(@nameIdentifierScheme))" />
                                                                <xsl:text>--</xsl:text>
                                                            <xsl:value-of select="."/>
                                                        </xsl:when>
                                                    </xsl:choose>
                                                    <!-- no schemeURIs at this point so don't need to handle -->
                                                    
                                                </xsl:for-each>
                                            </div>
                                        </xsl:for-each>
                                    </div>
                                </div>

                                <!--  resource Available DATE -->
                                    <xsl:if test="//*[local-name() = 'date'][@dateType='Available']">
                                        <div class="row">
                                        <div class="title">
                                            <xsl:text>Date Available:</xsl:text>
                                        </div>
                                        <div class="description">
                                            <xsl:value-of select="//*[local-name() = 'date'][@dateType='Available'][1]"/>
                                        </div>
                                        </div>
                                    </xsl:if>
                                
                                <!--  resource Created DATE -->
                                <xsl:if test="//*[local-name() = 'date'][@dateType='Created']">
                                    <div class="row">
                                        <div class="title">
                                            <xsl:text>Date Created:</xsl:text>
                                        </div>
                                        <div class="description">
                                            <xsl:value-of select="//*[local-name() = 'date'][@dateType='Created'][1]"/>
                                        </div>
                                    </div>
                                </xsl:if>
                                
                                <!--  resource update DATE -->
                                <!-- if update date is same as create date, don't show -->
                                <xsl:if test="(//*[local-name() = 'date'][@dateType='Updated']) 
                                    and not(contains(normalize-space(//*[local-name() = 'date'][@dateType='Updated'][1]),
                                            substring(normalize-space(//*[local-name() = 'date'][@dateType='Created'][1]),1,10)))">
                                    <div class="row">
                                        <div class="title">
                                            <xsl:text>Date Updated:</xsl:text>
                                        </div>
                                        <div class="description">
                                            <xsl:value-of select="//*[local-name() = 'date'][@dateType='Updated'][1]"/>
                                        </div>
                                    </div>
                                </xsl:if>
                                
                                <!--  resource KEYWORDS -->
                                <xsl:if test="(//*[local-name() = 'subject'][not(@subjectScheme='MGDS')])">
                                <div class="row">
                                    <div class="title">
                                        <xsl:text>Keyword(s):</xsl:text>
                                    </div>
                                    <xsl:for-each select="//*[local-name() = 'subject']">
                                        <xsl:if test="string-length(.)>0">
                                        <div class="description">
                                            <xsl:value-of select="normalize-space(string(.))"/>
                                            <xsl:if test="@xml:lang">
                                                <xsl:text>@</xsl:text>
                                                <xsl:value-of
                                                  select="normalize-space(string(@xml:lang))"/>
                                            </xsl:if>
                                            <xsl:if test="@subjectScheme">
                                                <xsl:text> (</xsl:text>
                                                <xsl:value-of
                                                  select="normalize-space(string(@subjectScheme))"/>
                                                <xsl:text>)</xsl:text>
                                            </xsl:if>
                                            <xsl:if test="@schemeURI">
                                                <xsl:text>; ID scheme URI--</xsl:text>
                                                <xsl:value-of
                                                  select="normalize-space(string(@schemeURI))"/>
                                            </xsl:if>

                                            <xsl:if test="@valueIRI">
                                                <xsl:text> (value IRI: </xsl:text>
                                                <xsl:value-of
                                                  select="normalize-space(string(@valueIRI))"/>
                                                <xsl:text>)</xsl:text>
                                            </xsl:if>
                                        </div>
                                        </xsl:if>
                                    </xsl:for-each>
                                    <!-- show geoLocationPlace names as geographic keywords -->
                                    <xsl:for-each select="//*[local-name() = 'geoLocationPlace']">
                                        <xsl:if test="string-length(.)>1">
                                        <div class="description">
                                            <xsl:value-of select="normalize-space(string(.))"/>
                                            <xsl:text> (geographic location)</xsl:text>
                                        </div>
                                        </xsl:if>
                                    </xsl:for-each>
                                </div>
                                </xsl:if>
                                
                                <!--  resource MGDS DATA TYPES -->
                                <xsl:if test="//*[@subjectScheme='MGDS']">
                                <div class="row">
                                    <div class="title">
                                        <xsl:text>Data Type(s):</xsl:text>
                                    </div>
                                    <xsl:for-each select="//*[local-name() = 'subject']">
                                        <div class="description">
                                            <xsl:value-of select="normalize-space(string(.))"/>
                                        </div>
                                    </xsl:for-each>
                                </div>
                                </xsl:if>

                                <!--  resource RESOURCE TYPE -->
                                <xsl:for-each select="//*[local-name() = 'resourceType']">
                                    <div class="row">
                                        <div class="title">
                                            <xsl:text>Resource Type:</xsl:text>
                                        </div>
                                        <div class="description">
                                            <div>
                                                <xsl:value-of select="@resourceTypeGeneral"/>
                                                <xsl:if test="string(.) and 
                                                    not(normalize-space(string(.))=normalize-space(string(@resourceTypeGeneral)))">
                                                  <xsl:text> -- </xsl:text>
                                                  <xsl:value-of select="string(.)"/>
                                                </xsl:if>
                                            </div>
                                        </div>
                                    </div>
                                </xsl:for-each>

                                <!--  resource FORMAT -->
                                <xsl:if test="//*[local-name() = 'format']">
                                    <div class="row">
                                        <div class="title">
                                            <xsl:text>File Format(s):</xsl:text>
                                        </div>
                                        <xsl:for-each select="//*[local-name() = 'format']">
                                            <div class="description">
                                                <xsl:value-of select="normalize-space(string(.))"/>
                                            </div>
                                        </xsl:for-each>
                                    </div>
                                </xsl:if>

                                <!--  resource CURATOR-alternate Identifier -->
                                <xsl:for-each select="//*[local-name() = 'alternateIdentifier']">
                                    <xsl:call-template name="altIDHandler"/>
                                </xsl:for-each>

                                <!--  resource VERSION -->
                                <xsl:if test="//*[local-name() = 'version']">
                                    <div class="row">
                                        <div class="title">
                                            <xsl:text>Version:</xsl:text>
                                        </div>
                                        <div class="description">
                                            <div>
                                                <xsl:value-of disable-output-escaping="yes"
                                                  select="normalize-space(string(//*[local-name() = 'version']))"
                                                />
                                            </div>
                                        </div>
                                    </div>
                                </xsl:if>

                                <!--  resource LANGUAGE -->
                                <xsl:if test="//*[local-name() = 'language']">
                                    <div class="row">
                                        <div class="title">
                                            <xsl:text>Language: </xsl:text>
                                        </div>
                                        <div class="description">
                                            <div>
                                                <xsl:value-of disable-output-escaping="yes"
                                                  select="normalize-space(string(//*[local-name() = 'language']))"
                                                />
                                            </div>
                                        </div>
                                    </div>
                                </xsl:if>

                                <!--  resource USE LIMITATIONS and LICENSE -->
                                <xsl:if test="//*[local-name() = 'rights']">
                                    <div class="row">
                                        <div class="title">
                                            <xsl:text>License:</xsl:text>
                                        </div>
                                        <xsl:for-each select="//*[local-name() = 'rights']">
                                            <div class="description">
                                                <div>
                                                  <xsl:value-of disable-output-escaping="yes"
                                                  select="normalize-space(string(.))"/>
                                                  <xsl:if test="@rightsURI">
                                                  <xsl:text> URI: </xsl:text>
                                                  <xsl:value-of disable-output-escaping="yes"
                                                  select="normalize-space(string(@rightsURI))"/>
                                                  </xsl:if>

                                                </div>
                                            </div>
                                        </xsl:for-each>
                                    </div>
                                </xsl:if>
                            </div>
                            <div style="clear:both"/>
                            
                            
                            <!--  RELATED RESOURCES -->
                            <xsl:if test="//*[local-name() = 'relatedIdentifier']">
                                <h1>
                                    <xsl:text>Related Information</xsl:text>
                                </h1>
                                <xsl:for-each select="//*[local-name() = 'relatedIdentifier']">
                                    <xsl:call-template name="relIDHandler"/>
                                </xsl:for-each>

                            </xsl:if>
                        </div>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:element>
        </html>
    </xsl:template>


    <xsl:template name="relIDHandler">
        <xsl:if test="string-length(.)>1 and not(contains(.,'nknown'))
            and not(contains(.,'group:'))">
        <div class="row">
            <div class="title">
                <xsl:value-of select="./@relationType"/>
                <xsl:text>:</xsl:text>
            </div>
            <xsl:choose>
                <xsl:when test="@relatedIdentifierType = 'URL'">
                    <div class="description"> url: <a href="{.}">
                            <xsl:value-of select="."/>
                        </a>
                    </div>
                </xsl:when>
                <xsl:when test="@relatedIdentifierType = 'DOI'">
                    <div class="description"> doi: <a href="http://dx.doi.org/{.}">
                            <xsl:value-of select="."/>
                        </a>
                    </div>
                </xsl:when>
                <xsl:when test="@relatedIdentifierType = 'ISBN'">
                    <div class="description"> isbn: <a
                            href="http://www.worldcat.org/search?qt=wikipedia&amp;q=isbn%3A{.}">
                            <xsl:value-of select="."/>
                        </a>
                    </div>
                </xsl:when>
                <xsl:when test="@relatedIdentifierType = 'IGSN'">
                    <div class="description"> Sample ID: <a
                        href="https://app.geosamples.org/sample/igsn/{substring(.,string-length('igsn:')+1)}">
                        <xsl:value-of select="."/>
                    </a>
                    </div>
                </xsl:when>
                <xsl:otherwise>
                    
                    <div class="description">
                        <xsl:choose>
                            <!-- this test was moved outside the div so we don't get the relType in output
                               but leave here to allow for otehr special cases to be handled-->
                            <xsl:when test="contains(.,'group:') ">
                                <!--<xsl:value-of select="substring-after(., 'group:')"/>-->
                                <!-- don't report the  'grouping', its for internal purposes -->
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="@relatedIdentifierType"/>
                                <xsl:text>: </xsl:text>
                                <xsl:value-of select="."/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </div>
                    
                </xsl:otherwise>
            </xsl:choose>
        </div>
    </xsl:if>
    </xsl:template>


    <xsl:template name="altIDHandler">
        <xsl:param name="theAltID"/>
        <xsl:choose>
            <xsl:when test="@alternateIdentifierType = 'MGDS'">
                <div class="row" style="min-height:36px;">
                    <div class="title">
                        <xsl:text>Data Curated by:</xsl:text>
                    </div>
                     <div class="description">
                        <a href="http://www.marine-geo.org">
                            <xsl:text>Marine Geoscience Data System (MGDS)</xsl:text>
                        </a>
                    </div>
                    <button type="button" class="btn"
                        onclick="window.location='http://www.marine-geo.org/tools/files/{.}'"> Download
                        Data </button>
                    <div style="clear:both"/>
                </div>
            </xsl:when>
            <xsl:when test="contains(string(.),'earthchem.org')">
                <div class="row" style="min-height:36px;">
                    <div class="title">
                        <xsl:text>Data Curated by:</xsl:text>
                    </div>
                    <div class="description">
                      <a href="http://www.earthchem.org/library">
                          <xsl:text>EarthChem Library (ECL) </xsl:text>
                      </a>
                    </div>
                    <button type="button" class="btn" onclick="window.location='{.}'"> Download Data </button>
                    <div style="clear:both"/>
                </div>
            </xsl:when>
            <xsl:when test="(@alternateIdentifierType = 'URL') and (//*[local-name()='publisher'])">
                <div class="row" style="min-height:36px;">
                    <div class="title">
                        <xsl:text>Data Curated by:</xsl:text>
                    </div>
                    <div class="description">
                         <xsl:value-of select="//*[local-name()='publisher']"/>
                         <xsl:text>- </xsl:text>
                     </div>
                    <button type="button" class="btn" onclick="window.location='{.}'"> Download Data </button> 
                    <div style="clear:both"/>
                </div>
             </xsl:when>
            <xsl:when test="@alternateIdentifierType = 'UTIG'">
                <div class="row" style="min-height:36px;">
                    <div class="title">
                        <xsl:text>Data Curated by:</xsl:text>
                    </div>
                    <div class="description">
                       <a href="http://www-udc.ig.utexas.edu/sdc/">
                           <xsl:text>Academic Seismic Portal @ UTIG </xsl:text>
                       </a>
                    </div>
                    <button type="button" class="btn"
                        onclick="window.location='http://www-udc.ig.utexas.edu/sdc/DOI/datasetDOI.php?datasetuID={.}'"
                        > Download Data </button>
                    <div style="clear:both"/>
                </div>
            </xsl:when>
            <xsl:otherwise>
                <!-- filter out identifiers we don't want to display -->
                <xsl:if test="not(contains(string(.),'urn:grl:submission'))">
                <div class="row">
                    <div class="title">
                        <xsl:text>Alternate Identifier:</xsl:text>
                    </div>
                    <div class="description">
                        <xsl:value-of select="@alternateIdentifierType"/>
                        <xsl:text>: </xsl:text>
                        <xsl:value-of select="."/>
                    </div>
                </div>
                </xsl:if>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="k3:geoLocations">
        <form id="geoLocations">
            <xsl:apply-templates select="k3:geoLocation"/>
        </form>
        <div id="mapc"/>
    </xsl:template>

    <xsl:template match="k3:geoLocation">
        <xsl:choose>
            <xsl:when test="./k3:geoLocationPoint">
                <xsl:element name="input">
                    <xsl:attribute name="class">
                        <xsl:text>geoLocationPoint</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="type">
                        <xsl:text>hidden</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="value">
                        <xsl:value-of select="./k3:geoLocationPoint"/>
                    </xsl:attribute>
                </xsl:element>
            </xsl:when>
            <xsl:when test="./k3:geoLocationBox">
                <xsl:element name="input">
                    <xsl:attribute name="class">
                        <xsl:text>geoLocationBox</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="type">
                        <xsl:text>hidden</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="value">
                        <xsl:value-of select="./k3:geoLocationBox"/>
                    </xsl:attribute>
                </xsl:element>
            </xsl:when>
        </xsl:choose>
    </xsl:template>


    <xsl:template match="k4:geoLocations">
        <form id="geoLocations">
            <xsl:apply-templates select="k4:geoLocation"/>
        </form>
        <div id="mapc"/>
    </xsl:template>

    <xsl:template match="k4:geoLocation">
        <xsl:choose>
            <xsl:when test="./k4:geoLocationPoint">
                <xsl:element name="input">
                    <xsl:attribute name="class">
                        <xsl:text>geoLocationPoint</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="type">
                        <xsl:text>hidden</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="value">
                        <xsl:value-of select="./k4:geoLocationPoint/k4:pointLatitude"/>
                        <xsl:text> </xsl:text>
                        <xsl:value-of select="./k4:geoLocationPoint/k4:pointLongitude"/>
                    </xsl:attribute>
                </xsl:element>
            </xsl:when>
            <xsl:when test="./k4:geoLocationBox">
                <xsl:element name="input">
                    <xsl:attribute name="class">
                        <xsl:text>geoLocationBox</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="type">
                        <xsl:text>hidden</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="value">
                        <xsl:value-of select="./k4:geoLocationBox/k4:southBoundLatitude"/>
                        <xsl:text> </xsl:text>
                        <xsl:value-of select="./k4:geoLocationBox/k4:westBoundLongitude"/>
                        <xsl:text> </xsl:text>
                        <xsl:value-of select="./k4:geoLocationBox/k4:northBoundLatitude"/>
                        <xsl:text> </xsl:text>
                        <xsl:value-of select="./k4:geoLocationBox/k4:eastBoundLongitude"/>
                    </xsl:attribute>
                </xsl:element>
            </xsl:when>
        </xsl:choose>
    </xsl:template>


</xsl:stylesheet>
