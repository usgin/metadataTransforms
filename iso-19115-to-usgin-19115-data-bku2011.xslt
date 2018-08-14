<?xml version="1.0" encoding="UTF-8"?>
<!--*************************************************************************************************** 
*** This transform maps a generic ISO19139 XML metadata record to a record conforming 
	to the USGIN profile by adding appropriate missing values for required elements
	 This style sheet converts ISO 19139 XML to ISO 19139 XML metadata that conforms with the USGIN 
	 profile. See http://lab.usgin.org/profiles/usgin-iso-metadata-profile (http://lab.usgin.org/node/235)
	 also http://usgin.github.io/usginspecs/USGIN_ISO_Metadata.htm
	 
	*** by USGIN Standards and Protocols Drafting Team *** U.S. Geoscience 
	Information System (USGIN) - http://lab.usgin.org *** 
	
	Contributors:  Lund Wolfe, Wolfgang Grunberg, Stephen Richard 
	*** 02/02/2010 *** 


   
This program based on ogc-toISO19139.xslt provided with ESRI geoportal software package
and USGIN service metadata example xml document 

LICENSE:
Apache License, Version 2.0: (the "License"); 
you may not use this file except in compliance with
 the License.  You may obtain a copy of the License at
     http://www.apache.org/licenses/LICENSE-2.0
 Unless requird by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 
updated 11/19/2010 correct 
	distribution section 
	
- version 1.0 2011-1-25 
 updated 2018-06-22 SMR. Move from original USGIN geoportal installation to USGIN/metadataTransforms gitHub
	Did some work on xslt, then realized have a newer version that Leah Musil cleaned up. Abandon updates
	
	************************************************************************************************** -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:exslt="http://exslt.org/common" xmlns="http://www.isotc211.org/2005/gmd"
    xmlns:gmd="http://www.isotc211.org/2005/gmd" xmlns:gco="http://www.isotc211.org/2005/gco"
    xmlns:gml="http://www.opengis.net/gml" xmlns:xlink="http://www.w3.org/1999/xlink"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:gts="http://www.isotc211.org/2005/gts" xmlns:geonet="http://www.fao.org/geonetwork"
    xmlns:csw="http://www.opengis.net/cat/csw/2.0.2" xmlns:srv="http://www.isotc211.org/2005/srv"
    xmlns:gmx="http://www.isotc211.org/2005/gmx"
    xsi:schemaLocation="http://www.isotc211.org/2005/gmd http://schemas.opengis.net/csw/2.0.2/profiles/apiso/1.0.0/apiso.xsd"
    exclude-result-prefixes="geonet csw xsi exslt xsl">


    <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>

    <!-- this transform designed for use in ESRI geoportal v1.x; the server provides values for these
    parameters  -->
    <xsl:param name="sourceUrl"/>
    <xsl:param name="serviceType"/>
    <xsl:param name="currentDate"/>
    <xsl:param name="generatedUUID"/>


    <!--    *****************************************************
 Metadata element summary and treatment in USGIN profile:
    fileIdentifier{0-1}, mandatory 
    language{0-1}, 
    characterSet{0-1}, 
    parentIdentifier{0-1}, 
    hierarchyLevel{0-UNBOUNDED}, mandatory in base standard
    hierarchyLevelName{0-UNBOUNDED}, 
    contact{1-UNBOUNDED}, requires a contact name and either telephone or e-mail
    dateStamp, mandatory
    metadataStandardName{0-1}, 
    metadataStandardVersion{0-1}, 
    dataSetURI{0-1}, 
    locale{0-UNBOUNDED}, 
    spatialRepresentationInfo{0-UNBOUNDED}, 
    referenceSystemInfo{0-UNBOUNDED}, 
    metadataExtensionInfo{0-UNBOUNDED}, 
    identificationInfo{1-UNBOUNDED}, requires citation title and date; and an abstract
    contentInfo{0-UNBOUNDED}, 
    distributionInfo{0-1}, 
    dataQualityInfo{0-UNBOUNDED}, 
    portrayalCatalogueInfo{0-UNBOUNDED}, 
    metadataConstraints{0-UNBOUNDED}, 
    applicationSchemaInfo{0-UNBOUNDED}, 
    metadataMaintenance{0-1} 
-->

    <!-- ************************************************************* -->
    <!-- templates for copying elements without all namespaces like xsl:copy-of does
      from https://stackoverflow.com/questions/19998180/xsl-copy-nodes-without-xmlns -->
    <xsl:template match="*" mode="copy">
        <xsl:element name="{name()}" namespace="{namespace-uri()}">
            <xsl:apply-templates select="@* | node()" mode="copy"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="@* | text() | comment()" mode="copy">
        <xsl:copy/>
    </xsl:template>

    <!--  Replace copy-of with
    
    <xsl:apply-templates mode="copy"
        select="....node to copy" />   -->

    <!-- ************************************************************ -->

    <xsl:template match="/">
        <xsl:call-template name="main"/>
    </xsl:template>

    <xsl:template name="main">
        <!-- converts generic ISO 19115 metadata to USGIN ISO 191115 metadata -->
        <gmd:MD_Metadata xmlns:gmd="http://www.isotc211.org/2005/gmd"
            xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
            xmlns:gco="http://www.isotc211.org/2005/gco" xmlns:gml="http://www.opengis.net/gml/3.2"
            xsl:exclude-result-prefixes="geonet csw xsi exslt xsl srv"
            xsi:schemaLocation="http://www.isotc211.org/2005/gmd http://schemas.opengis.net/csw/2.0.2/profiles/apiso/1.0.0/apiso.xsd">

            <!-- fileIdentifier{0-1}, mandatory   -->
            <gmd:fileIdentifier>
                <gco:CharacterString>
                    <xsl:choose>
                        <xsl:when
                            test="string-length(/gmd:MD_Metadata/gmd:fileIdentifier/gco:CharacterString) > 0">
                            <xsl:value-of
                                select="/gmd:MD_Metadata/gmd:fileIdentifier/gco:CharacterString"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="$generatedUUID"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </gco:CharacterString>
            </gmd:fileIdentifier>

            <!-- language{0-1} -->
            <gmd:language>
                <gco:CharacterString>
                    <xsl:choose>
                        <xsl:when
                            test="string-length(/gmd:MD_Metadata/gmd:language/gco:CharacterString) > 0">
                            <xsl:value-of select="/gmd:MD_Metadata/gmd:language/gco:CharacterString"
                            />
                        </xsl:when>
                        <xsl:otherwise>eng</xsl:otherwise>
                    </xsl:choose>
                </gco:CharacterString>
            </gmd:language>

            <!-- characterSet{0-1}-->
            <gmd:characterSet>
                <gmd:MD_CharacterSetCode>
                    <xsl:choose>
                        <xsl:when test="/gmd:MD_Metadata/gmd:characterSet/gmd:MD_CharacterSetCode">
                            <xsl:attribute name="codeList">
                                <xsl:value-of
                                    select="/gmd:MD_Metadata/gmd:characterSet/gmd:MD_CharacterSetCode/@codeList"
                                />
                            </xsl:attribute>
                            <xsl:attribute name="codeListValue">
                                <xsl:value-of
                                    select="/gmd:MD_Metadata/gmd:characterSet/gmd:MD_CharacterSetCode/@codeListValue"
                                />
                            </xsl:attribute>
                            <xsl:value-of select="/gmd:MD_Metadata/gmd:characterSet"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:attribute name="codeList"
                                >http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/Codelist/gmxCodelists.xml#MD_CharacterSetCode </xsl:attribute>
                            <xsl:attribute name="codeListValue"
                            >utf8</xsl:attribute>UTF-8</xsl:otherwise>
                    </xsl:choose>
                </gmd:MD_CharacterSetCode>
            </gmd:characterSet>

            <!-- parentIdentifier{0-1},-->
            <!--<xsl:copy-of select="/gmd:MD_Metadata/gmd:parentIdentifier"/>-->
            <xsl:apply-templates mode="copy" select="/gmd:MD_Metadata/gmd:parentIdentifier"/>

            <!--  hierarchyLevel{0-UNBOUNDED}, mandatory in base standard  -->
            <xsl:choose>
                <xsl:when
                    test="//gmd:hierarchyLevel/gmd:MD_ScopeCode[string-length(@codeListValue) > 0]">
                    <xsl:for-each
                        select="//gmd:hierarchyLevel[string-length(gmd:MD_ScopeCode/@codeListValue) > 0]">
                        <gmd:hierarchyLevel>
                            <xsl:apply-templates mode="copy" select="gmd:MD_ScopeCode"/>
                            <!--<xsl:copy-of select="gmd:MD_ScopeCode"/>-->
                        </gmd:hierarchyLevel>
                    </xsl:for-each>
                </xsl:when>
                <xsl:otherwise>
                    <gmd:hierarchyLevel>
                        <gmd:MD_ScopeCode
                            codeList="http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/Codelist/gmxCodelists.xml#MD_ScopeCode"
                            codeListValue="dataset">dataset</gmd:MD_ScopeCode>
                    </gmd:hierarchyLevel>
                </xsl:otherwise>
            </xsl:choose>

            <!-- hierarchyLevelName{0-UNBOUNDED} -->
            <xsl:for-each select="//gmd:hierarchyLevelName[string-length(gco:CharacterString) > 0]">
                <gmd:hierarchyLevelName>
                    <gco:CharacterString>
                        <xsl:value-of select="normalize-space(gco:CharacterString)"/>
                    </gco:CharacterString>
                </gmd:hierarchyLevelName>
            </xsl:for-each>
            <xsl:if
                test="count(//gmd:hierarchyLevelName[string-length(gco:CharacterString) > 0]) = 0">
                <gmd:hierarchyLevelName>
                    <gco:CharacterString>dataset</gco:CharacterString>
                </gmd:hierarchyLevelName>
            </xsl:if>


            <!-- contact{1-UNBOUNDED}, requires a contact name and either telephone or e-mail -->
            <xsl:apply-templates select="/gmd:MD_Metadata/gmd:contact"/>

            <!-- dateStamp, mandatory-->
            <gmd:dateStamp>
                <gco:DateTime>
                    <xsl:choose>
                        <xsl:when test="/gmd:MD_Metadata/gmd:dateStamp/gco:Date">
                            <xsl:value-of  select="concat(/gmd:MD_Metadata/gmd:dateStamp/gco:Date, 'T00:00:00')"/>
                        </xsl:when>
                        <xsl:when test="/gmd:MD_Metadata/gmd:dateStamp/gco:DateTime">
                            <xsl:value-of  select="/gmd:MD_Metadata/gmd:dateStamp/gco:DateTime"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="string('1900-01-01T12:00:00')"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </gco:DateTime>
            </gmd:dateStamp>

            <!--  metadataStandardName{0-1} -->
            <gmd:metadataStandardName>
                <gco:CharacterString>ISO-NAP-USGIN</gco:CharacterString>
            </gmd:metadataStandardName>

            <!-- metadataStandardVersion{0-1}-->
            <gmd:metadataStandardVersion>
                <gco:CharacterString>1.1</gco:CharacterString>
            </gmd:metadataStandardVersion>


            <!--dataSetURI{0-1} -->
            <xsl:apply-templates mode="copy" select="//gmd:dataSetURI" />
            
            <!--  locale{0-UNBOUNDED} -->
                <xsl:apply-templates mode="copy" select="//gmd:locale" />
            
            <!-- spatialRepresentationInfo{0-UNBOUNDED} -->
                <xsl:apply-templates mode="copy" select="//gmd:spatialRepresentationInfo" />
            
            <!-- referenceSystemInfo{0-UNBOUNDED -->
                <xsl:apply-templates mode="copy" select="//gmd:referenceSystemInfo" />
            
            <!-- not used in USGIN <gmd:metadataExtensionInfo/> -->
            
            <!--  identificationInfo{1-UNBOUNDED}, requires citation title and date; and an abstract -->
            <xsl:copy-of select="/gmd:MD_Metadata/gmd:identificationInfo"/>
            
            <xsl:copy-of select="/gmd:MD_Metadata/gmd:distributionInfo"/>

            <gmd:dataQualityInfo>
                <gmd:DQ_DataQuality>
                    <gmd:scope>
                        <gmd:DQ_Scope>
                            <gmd:level>
                                <xsl:choose>
                                    <xsl:when
                                        test="/gmd:MD_Metadata/gmd:dataQualityInfo/gmd:DQ_DataQuality/gmd:scope/gmd:DQ_Scope/gmd:level/gmd:MD_ScopeCode">
                                        <xsl:copy-of
                                            select="/gmd:MD_Metadata/gmd:dataQualityInfo/gmd:DQ_DataQuality/gmd:scope/gmd:DQ_Scope/gmd:level/gmd:MD_ScopeCode"
                                        />
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <gmd:MD_ScopeCode
                                            codeList="http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/Codelist/gmxCodelists.xml#MD_ScopeCode"
                                            codeListValue="dataset">dataset</gmd:MD_ScopeCode>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </gmd:level>
                        </gmd:DQ_Scope>
                    </gmd:scope>
                    <xsl:copy-of
                        select="/gmd:MD_Metadata/gmd:dataQualityInfo/gmd:DQ_DataQuality/gmd:report"/>
                    <gmd:lineage>
                        <gmd:LI_Lineage>
                            <gmd:statement>
                                <gco:CharacterString>
                                    <xsl:value-of
                                        select="concat(/gmd:MD_Metadata/gmd:dataQualityInfo/gmd:DQ_DataQuality/gmd:lineage/gmd:LI_Lineage/gmd:statement/gco:CharacterString, ' This metadata record harvested from ', $sourceUrl, '. and transformed to USGIN ISO19139 profile using iso-19115-to usgin_19115.xslt version 1.0')"
                                    />
                                </gco:CharacterString>
                            </gmd:statement>
                            <xsl:copy-of
                                select="/gmd:MD_Metadata/gmd:dataQualityInfo/gmd:DQ_DataQuality/gmd:lineage/gmd:LI_Lineage/gmd:processStep"
                            />
                            <xsl:copy-of
                                select="/gmd:MD_Metadata/gmd:dataQualityInfo/gmd:DQ_DataQuality/gmd:lineage/gmd:LI_Lineage/gmd:source"/>
                            
                        </gmd:LI_Lineage>
                    </gmd:lineage>
                </gmd:DQ_DataQuality>
            </gmd:dataQualityInfo>

            <xsl:copy-of select="/gmd:MD_Metadata/gmd:portrayalCatalogueInfo"/>
            <xsl:copy-of select="/gmd:MD_Metadata/gmd:metadataConstraints"/>
            <xsl:copy-of select="/gmd:MD_Metadata/gmd:applicationSchemaInfo"/>
            <xsl:copy-of select="/gmd:MD_Metadata/gmd:metadataMaintenance"/>
            <!-- not used in USGIN <gmd:series/> -->
            <!-- not used in USGIN <gmd:describes/> -->
            <!-- not used in USGIN <gmd:propertyType/> -->
            <!-- not used in USGIN <gmd:featureType/> -->
            <!-- not used in USGIN <gmd:featureAttribute/> -->
        </gmd:MD_Metadata>
    </xsl:template>

    <xsl:template match="/gmd:MD_Metadata/gmd:contact">
        <gmd:contact>
            <gmd:CI_ResponsibleParty>
                <xsl:attribute name="uuid">
                    <xsl:value-of select="gmd:CI_ResponsibleParty/@uuid"/>
                </xsl:attribute>
                <xsl:copy-of select="gmd:CI_ResponsibleParty/gmd:individualName"/>
                <xsl:copy-of select="gmd:CI_ResponsibleParty/gmd:organisationName"/>
                <xsl:copy-of select="gmd:CI_ResponsibleParty/gmd:positionName"/>
                <gmd:contactInfo>
                    <gmd:CI_Contact>
                        <xsl:attribute name="uuid">
                            <xsl:value-of
                                select="gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/@uuid"
                            />
                        </xsl:attribute>
                        <xsl:copy-of
                            select="gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:phone"/>
                        <gmd:address>
                            <gmd:CI_Address>
                                <xsl:copy-of
                                    select="gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:deliveryPoint"/>
                                <xsl:copy-of
                                    select="gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:city"/>
                                <xsl:copy-of
                                    select="gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:administrativeArea"/>
                                <xsl:copy-of
                                    select="gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:postalCode"/>
                                <xsl:copy-of
                                    select="gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:country"/>
                                <gmd:electronicMailAddress>
                                    <gco:CharacterString>
                                        <xsl:choose>
                                            <xsl:when
                                                test="gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:electronicMailAddress">
                                                <xsl:value-of
                                                  select="gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:electronicMailAddress/gco:CharacterString"
                                                />
                                            </xsl:when>
                                            <xsl:otherwise>missing</xsl:otherwise>
                                        </xsl:choose>
                                    </gco:CharacterString>
                                </gmd:electronicMailAddress>
                            </gmd:CI_Address>
                        </gmd:address>
                        <xsl:copy-of
                            select="gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:onlineResource"/>
                        <xsl:copy-of
                            select="gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:hoursOfService"/>
                        <xsl:copy-of
                            select="gmd:CI_ResponsibleParty/gmd:contactInfo/gmd:CI_Contact/gmd:contactInstructions"
                        />
                    </gmd:CI_Contact>
                </gmd:contactInfo>
                <xsl:copy-of select="gmd:CI_ResponsibleParty/gmd:role"/>
            </gmd:CI_ResponsibleParty>
        </gmd:contact>
    </xsl:template>

</xsl:stylesheet>
