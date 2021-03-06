<?xml version="1.0"?>
<xsl:stylesheet version="1.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:gmd="http://www.isotc211.org/2005/gmd" 
    xmlns:gco="http://www.isotc211.org/2005/gco"
    xmlns:gml="http://www.opengis.net/gml/3.2" 
    xmlns:xlink="http://www.w3.org/1999/xlink"
    xmlns:datetime="http://exslt.org/dates-and-times"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
    xmlns:ows="http://www.opengis.net/ows"
    xmlns:dct="http://purl.org/dc/terms/" 
    xmlns:dc="http://purl.org/dc/elements/1.1/"
    xmlns:dcmiBox="http://dublincore.org/documents/2000/07/11/dcmi-box/"
    exclude-result-prefixes="datetime">
    <xsl:output method="xml" encoding="utf-8" omit-xml-declaration="no" indent="yes"/>
    <!-- 
	
	SMR 2018-04-06 
	Version 1.0 2018-04-25
	Transform qualified DC XML metadata to ISO 19139
    
    Version 1.0.1 2018-07-25
       update handling of @scheme or @dct:scheme on dct:references to populate gmd:applicationProfile
       in CI_OnlineResource elements. 
       Change title handler to handle only first dc:title if there are >1 titles.
    -->
    <!--  * @copyright 2018 Stephen M Richard. 
	        All Rights Reserved.
 *          Licensed under the Apache License, Version 2.0 (the "License"); 
            you may not use this file except in compliance with the License. 
			You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software distributed under the License is 
    distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. 
    See the License for the specific language governing permissions and limitations under the License -->
   
    <!-- The contact for the metadata - static value; customize for your application.  -->
    <xsl:template name="metadatacontact">
        <gmd:contact>
            <gmd:CI_ResponsibleParty>
                <gmd:organisationName>
                    <gco:CharacterString>CINERGI Metadata catalog</gco:CharacterString>
                </gmd:organisationName>
                <gmd:contactInfo>
                    <gmd:CI_Contact>
                        <gmd:address>
                            <gmd:CI_Address>
                                <gmd:electronicMailAddress>
                                    <!--<gco:CharacterString>info@EarthChem.org</gco:CharacterString>-->
                                    <gco:CharacterString>
                                        <xsl:value-of select="'cinergi@sdsc.edu'"/>
                                    </gco:CharacterString>
                                </gmd:electronicMailAddress>
                            </gmd:CI_Address>
                        </gmd:address>
                    </gmd:CI_Contact>
                </gmd:contactInfo>
                <gmd:role>
                    <gmd:CI_RoleCode
                        codeList="http://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#CI_RoleCode"
                        codeListValue="pointOfContact">pointOfContact</gmd:CI_RoleCode>
                </gmd:role>
            </gmd:CI_ResponsibleParty>
        </gmd:contact>
    </xsl:template>
    
    <!-- define variables for top level elements in dc xml to simplify xpaths... -->
    <xsl:variable name="dc-identifier" select="//*[local-name() = 'identifier']"/>
    <xsl:variable name="dc-title">
        <!-- make sure something gets put in the title, if there are multiple titles, only take the first -->
        <!-- TBD if have multiple title elements, put others in alternate title -->
        <xsl:choose>
            <xsl:when test="string-length(//*[local-name() = 'title'][1])>0">
                <xsl:value-of select="//*[local-name() = 'title'][1]"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="string('No title provided')"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    
    <!--    <xsl:variable name="dc-alternateIDs" select="//*[local-name() = 'alternateIdentifiers']"/>-->
    <xsl:variable name="dc-contributors" select="//*[local-name() = 'contributor']"/>
    <!-- dc: or dct: -->
    <xsl:variable name="dc-creators" select="//*[local-name() = 'creator']"/>
    <xsl:variable name="dc-dates" select="//*[contains($dcdates, local-name())]"/>
    <xsl:variable name="smallcase" select="'abcdefghijklmnopqrstuvwxyz'"/>
    <xsl:variable name="uppercase" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'"/>
    <!-- don't include references because that will be called out for distribution links -->
    <xsl:variable name="dcrelation"
        select="'relation|hasVersion|isVersionOf|isReplacedBy|replaces|isRequiredBy|requires|isPartOf|hasPart|isReferencedBy|isFormatOf|hasFormat|conformsTo'"/>
    <xsl:variable name="dcdates"
        select="'date|created|valid|available|issued|modified|dateAccepted|dateCopyrighted|dateSubmitted'"/>
    <!-- these variables set content for gmd:metadataMaintenance element at the end of the record
		recommend using these to report on how this record was created and by who. -->
    <xsl:variable name="metaMaintenanceNote"
        select="
            string('This metadata record was generated by an xslt transformation from a dc metadata record; Transform by Stephen M. Richard, based on a transform by Damian Ulbricht. ')"/>
    <xsl:variable name="maintenanceContactID" select="string('')"/>
    <xsl:variable name="maintenanceContactName" select="string('CINERGI metadata curator')"/>
    <xsl:variable name="maintenanceContactEmail" select="string('valentin@sdsc.edu')"/>
    <xsl:variable name="currentDateTime">
        <xsl:value-of select="datetime:date-time()"/>
    </xsl:variable>
    <!-- end of configuration variables -->
    <!-- here we go..... -->
    <xsl:template match="/">
        <gmd:MD_Metadata xmlns:gmd="http://www.isotc211.org/2005/gmd"
            xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
            xmlns:gco="http://www.isotc211.org/2005/gco" xmlns:gml="http://www.opengis.net/gml/3.2"
            xsi:schemaLocation="http://www.isotc211.org/2005/gmd http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/gmd/gmd.xsd">
            <!--  The fileIdentifier identifies the 
				metadata record, not the described resource which is identified by a DOI.
			-->
            <xsl:variable name="fileIdentifierPrefix" select="string('urn:dciso:')"/>
            <gmd:fileIdentifier>
                <gco:CharacterString>
                    <xsl:choose>
                        <xsl:when test="string-length($dc-identifier[1]) &gt; 0">
                            <xsl:value-of
                                select="concat($fileIdentifierPrefix, string('metadataabout:'), normalize-space(translate($dc-identifier[1], '/:', '--')))"
                            />
                        </xsl:when>
                        <!-- <xsl:when
                            test="count($dc-alternateIDs/*[local-name() = 'alternateIdentifier'][@alternateIdentifierType = 'IEDA submission_ID']) &gt; 0">
                            <xsl:value-of
                                select="
                                    concat($fileIdentifierPrefix, string('metadataabout:'),
                                    normalize-space(substring-after($dc-alternateIDs/*[local-name() = 'alternateIdentifier'][@alternateIdentifierType = 'IEDA submission_ID']/text(), 'urn:')))"
                            />
                        </xsl:when>-->
                        <xsl:otherwise>
                            <xsl:value-of
                                select="concat($fileIdentifierPrefix, string('metadata:'), normalize-space(translate($dc-title, '/: ,', '----')))"
                            />
                        </xsl:otherwise>
                    </xsl:choose>
                </gco:CharacterString>
            </gmd:fileIdentifier>
            <gmd:language>
                <gmd:LanguageCode codeList="http://www.loc.gov/standards/iso639-2/"
                    codeListValue="eng">eng</gmd:LanguageCode>
            </gmd:language>
            <gmd:characterSet>
                <gmd:MD_CharacterSetCode
                    codeList="http://www.isotc211.org/2005/resources/codeList.xml#MD_CharacterSetCode"
                    codeListValue="utf8"/>
            </gmd:characterSet>
            <xsl:variable name="MDScopelist"
                select="string('http://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#MD_ScopeCode')"/>
            <xsl:variable name="seriesScope" select="'Collection'"/>
            <xsl:variable name="datasetScope"
                select="'Dataset|Event|Image|MovingImage|StillImage|Sound|Text|PhysicalObject'"/>
            <xsl:variable name="serviceScope" select="'InteractiveResource|Service'"/>
            <xsl:variable name="softwareScope" select="'Software'"/>
            <xsl:for-each select="//*[local-name() = 'type']">
                <gmd:hierarchyLevel>
                    <gmd:MD_ScopeCode>
                        <xsl:attribute name="codeList">
                            <xsl:value-of select="$MDScopelist"/>
                        </xsl:attribute>
                        <xsl:attribute name="codeListValue">
                            <xsl:choose>
                                <xsl:when test="contains($seriesScope, normalize-space(string(.)))">
                                    <xsl:value-of select="string('series')"/>
                                </xsl:when>
                                <xsl:when test="contains($datasetScope, normalize-space(string(.)))">
                                    <xsl:value-of select="string('dataset')"/>
                                </xsl:when>
                                <xsl:when test="contains($serviceScope, normalize-space(string(.)))">
                                    <xsl:value-of select="string('service')"/>
                                </xsl:when>
                                <xsl:when
                                    test="contains($softwareScope, normalize-space(string(.)))">
                                    <xsl:value-of select="string('software')"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="string('dataset')"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:attribute>
                        <xsl:value-of select="normalize-space(string(.))"/>
                    </gmd:MD_ScopeCode>
                </gmd:hierarchyLevel>
            </xsl:for-each>
            <!-- The contact for the metadata - static value assigned in template at the top of this file; -->
            <xsl:call-template name="metadatacontact"/>
            <gmd:dateStamp>
                <gco:DateTime>
                    <xsl:value-of select="$currentDateTime"/>
                </gco:DateTime>
            </gmd:dateStamp>
            <gmd:metadataStandardName>
                <gco:CharacterString>ISO 19139 Geographic Information - Metadata - Implementation Specification</gco:CharacterString>
            </gmd:metadataStandardName>
            <gmd:metadataStandardVersion>
                <gco:CharacterString>2007</gco:CharacterString>
            </gmd:metadataStandardVersion>
            <gmd:identificationInfo>
                <gmd:MD_DataIdentification>
                    <gmd:citation>
                        <gmd:CI_Citation>
                            <gmd:title>
                                <gco:CharacterString>
                                     <xsl:value-of select="normalize-space(string($dc-title))"/>
                                </gco:CharacterString>
                            </gmd:title>
                            <xsl:for-each select="//*[local-name() = 'alternative']">
                                <gmd:alternateTitle>
                                    <gco:CharacterString>
                                        <xsl:value-of select="normalize-space(string(.))"/>
                                    </gco:CharacterString>
                                </gmd:alternateTitle>
                            </xsl:for-each>
                            <xsl:call-template name="resourcedates"/>
                            <xsl:for-each select="$dc-identifier">
                                <gmd:identifier>
                                    <gmd:MD_Identifier>
                                        <gmd:code>
                                            <gco:CharacterString>
                                                <xsl:value-of select="normalize-space(string(.))"/>
                                            </gco:CharacterString>
                                        </gmd:code>
                                    </gmd:MD_Identifier>
                                </gmd:identifier>
                            </xsl:for-each>
                            <xsl:call-template name="creators"/>
                            <xsl:call-template name="contributors"/>
                            <xsl:for-each select="//*[local-name() = 'publisher']">
                                <gmd:citedResponsibleParty>
                                    <xsl:call-template name="ci_responsibleparty">
                                        <xsl:with-param name="organisation">
                                            <xsl:value-of select="normalize-space(string(.))"/>
                                        </xsl:with-param>
                                        <xsl:with-param name="role">publisher</xsl:with-param>
                                    </xsl:call-template>
                                </gmd:citedResponsibleParty>
                            </xsl:for-each>
                            <xsl:for-each select="//*[local-name() = 'rightsHolder']">
                                <gmd:citedResponsibleParty>
                                    <xsl:call-template name="ci_responsibleparty">
                                        <xsl:with-param name="organisation">
                                            <xsl:value-of select="normalize-space(string(.))"/>
                                        </xsl:with-param>
                                        <xsl:with-param name="role">owner</xsl:with-param>
                                    </xsl:call-template>
                                </gmd:citedResponsibleParty>
                            </xsl:for-each>
                            <xsl:if
                                test="
                                    //*[local-name() = 'audience'] | //*[local-name() = 'mediator']
                                    | //*[local-name() = 'educationLevel']
                                    | //*[local-name() = 'bibliographicCitation']
                                    | //*[local-name() = 'instructionalMethod']
                                    | //*[local-name() = 'extent']">
                                <gmd:otherCitationDetails>
                                    <gco:CharacterString>
                                        <xsl:for-each
                                            select="
                                                //*[local-name() = 'audience'] | //*[local-name() = 'mediator']
                                                | //*[local-name() = 'educationLevel']
                                                | //*[local-name() = 'bibliographicCitation']
                                                | //*[local-name() = 'instructionalMethod']
                                                | //*[local-name() = 'extent']">
                                            <xsl:value-of
                                                select="concat(local-name(), ': ', normalize-space(string(.)), ';    ')"
                                            />
                                        </xsl:for-each>
                                    </gco:CharacterString>
                                </gmd:otherCitationDetails>
                            </xsl:if>
                        </gmd:CI_Citation>
                    </gmd:citation>
                    <gmd:abstract>
                        <gco:CharacterString>
                            <xsl:for-each select="//*[local-name() = 'description']">
                                <xsl:value-of
                                    select="concat('description: ', normalize-space(string(.)))"/>
                                <xsl:if test="following::*[local-name() = 'description']">
                                    <xsl:text>;   </xsl:text>
                                </xsl:if>
                            </xsl:for-each>
                            <xsl:if
                                test="//*[local-name() = 'abstract'] and //*[local-name() = 'description']">
                                <xsl:text>;   </xsl:text>
                            </xsl:if>
                            <xsl:for-each select="//*[local-name() = 'abstract']">
                                <xsl:value-of
                                    select="concat('abstract: ', normalize-space(string(.)))"/>
                                <xsl:if test="following::*[local-name() = 'abstract']">
                                    <xsl:text>;   </xsl:text>
                                </xsl:if>
                            </xsl:for-each>
                            <xsl:if
                                test="
                                    (//*[local-name() = 'abstract'] or //*[local-name() = 'description'])
                                    and //*[local-name() = 'tableOfContents']">
                                <xsl:text>;   </xsl:text>
                            </xsl:if>
                            <xsl:for-each select="//*[local-name() = 'tableOfContents']">
                                <xsl:value-of
                                    select="concat('tableOfContents: ', normalize-space(string(.)))"/>
                                <xsl:if test="following::*[local-name() = 'tableOfContents']">
                                    <xsl:text>;   </xsl:text>
                                </xsl:if>
                            </xsl:for-each>
                        </gco:CharacterString>
                    </gmd:abstract>
                    <!--                    <gmd:status>
                        <gmd:MD_ProgressCode
                            codeList="http://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#MD_ProgressCode"
                            codeListValue="Complete">Complete</gmd:MD_ProgressCode>
                    </gmd:status>
-->
                    <!-- gmd:pointOfContact -->
                    <xsl:call-template name="datasetcontact"/>
                    <!-- put dc:accrual stuff in resource maintenance -->
                    <xsl:if test="//*[contains(local-name(), 'accrual')]">
                        <gmd:resourceMaintenance>
                            <gmd:MD_MaintenanceInformation>
                                <xsl:choose>
                                    <xsl:when test="//*[local-name() = 'accrualPeriodicity']">
                                        <gmd:maintenanceAndUpdateFrequency>
                                            <gmd:MD_MaintenanceFrequencyCode>
                                                <xsl:attribute name="codeList">
                                                  <xsl:value-of
                                                  select="string('http://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#MD_MaintenanceFrequencyCode')"
                                                  />
                                                </xsl:attribute>
                                                <xsl:attribute name="codeListValue">
                                                  <xsl:value-of select="string('unknown')"/>
                                                  <!-- there might be a mapping from accrualPeriodicity to the
                                                                                        ISO codelist..., but this is quick fix for now to be sure its valid-->
                                                </xsl:attribute>
                                                <xsl:value-of
                                                  select="normalize-space(string(//*[local-name() = 'accrualPeriodicity'][1]))"
                                                />
                                            </gmd:MD_MaintenanceFrequencyCode>
                                        </gmd:maintenanceAndUpdateFrequency>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <gmd:maintenanceAndUpdateFrequency gco:nilReason="missing"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                                <xsl:for-each
                                    select="
                                        //*[local-name() = 'accrualMethod']
                                        | //*[local-name() = 'accrualPolicy']">
                                    <gmd:maintenanceNote>
                                        <gco:CharacterString>
                                            <xsl:value-of
                                                select="concat(local-name(), ': ', normalize-space(string(.)))"
                                            />
                                        </gco:CharacterString>
                                    </gmd:maintenanceNote>
                                </xsl:for-each>
                            </gmd:MD_MaintenanceInformation>
                        </gmd:resourceMaintenance>
                    </xsl:if>
                    <xsl:call-template name="versionandformat"/>
                    <xsl:call-template name="temporalkeywords"/>
                    <xsl:call-template name="geolocationplace"/>
                    <xsl:call-template name="keywords"/>
                    <xsl:call-template name="license"/>
                    <xsl:call-template name="relatedResources">
                        <xsl:with-param name="relres"
                            select="//*[contains($dcrelation, local-name())]"/>
                        <!-- pass a set of related identifier nodes -->
                    </xsl:call-template>
                    <!-- assume english for now -->
                    <xsl:choose>
                        <xsl:when test="//*[local-name() = 'language']">
                            <xsl:for-each select="//*[local-name() = 'language']">
                                <gmd:language>
                                    <gco:CharacterString>
                                        <xsl:value-of select="normalize-space(string(.))"/>
                                    </gco:CharacterString>
                                </gmd:language>
                            </xsl:for-each>
                        </xsl:when>
                        <xsl:otherwise>
                            <gmd:language gco:nilReason="missing"/>
                        </xsl:otherwise>
                    </xsl:choose>
                    <gmd:characterSet/>
                    <gmd:topicCategory/>
                    <gmd:environmentDescription/>
                    <!-- handle spatial and temporal extent -->
                    <xsl:for-each select="//*[local-name() = 'coverage']">
                        <gmd:extent>
                            <gmd:EX_Extent>
                                <gmd:description>
                                    <gco:CharacterString>
                                        <xsl:value-of
                                            select="concat('dc:coverage: ', normalize-space(string(.)))"
                                        />
                                    </gco:CharacterString>
                                </gmd:description>
                            </gmd:EX_Extent>
                        </gmd:extent>
                    </xsl:for-each>
                    <xsl:call-template name="spatialcoverage"/>
                    <xsl:call-template name="temporalcoverage"/>
                </gmd:MD_DataIdentification>
            </gmd:identificationInfo>
            <gmd:distributionInfo>
                <gmd:MD_Distribution>
                    <gmd:transferOptions>
                        <gmd:MD_DigitalTransferOptions>
                            <xsl:call-template name="size"/>
                            <!-- dc:extent goes here -->
                            <xsl:for-each select="$dc-identifier">
                                <xsl:if
                                    test="
                                        starts-with(normalize-space(string(.)), 'doi:')
                                        or starts-with(normalize-space(string(.)), 'http')">
                                    <gmd:onLine>
                                        <gmd:CI_OnlineResource>
                                            <gmd:linkage>
                                                <gmd:URL>
                                                  <xsl:choose>
                                                  <xsl:when
                                                  test="starts-with(normalize-space(string(.)), 'doi:')">
                                                  <xsl:value-of
                                                  select="concat('https://doi.org/', substring-after(normalize-space(string(.)), 'doi:'))"
                                                  />
                                                  </xsl:when>
                                                  <xsl:when
                                                  test="starts-with(normalize-space(string(.)), 'http')">
                                                  <xsl:value-of select="normalize-space(string(.))"
                                                  />
                                                  </xsl:when>
                                                  </xsl:choose>
                                                </gmd:URL>
                                            </gmd:linkage>
                                            <gmd:protocol>
                                                <gco:CharacterString>WWW:LINK-1.0-http--link</gco:CharacterString>
                                            </gmd:protocol>
                                            <gmd:name>
                                                <gco:CharacterString>Landing Page</gco:CharacterString>
                                            </gmd:name>
                                            <gmd:description>
                                                <gco:CharacterString>
                                                  <xsl:value-of
                                                  select="normalize-space(string('Link to landing page referenced by identifier'))"/>
                                                </gco:CharacterString>
                                            </gmd:description>
                                            <gmd:function>
                                                <gmd:CI_OnLineFunctionCode
                                                  codeList="http://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#CI_OnLineFunctionCode"
                                                  codeListValue="information"
                                                  >dc:identifier</gmd:CI_OnLineFunctionCode>
                                            </gmd:function>
                                        </gmd:CI_OnlineResource>
                                    </gmd:onLine>
                                </xsl:if>
                            </xsl:for-each>
                            <xsl:for-each select="//*[local-name() = 'references']">
                                <xsl:if test="starts-with(normalize-space(string(.)), 'http')">
                                    <gmd:onLine>
                                        <gmd:CI_OnlineResource>
                                            <gmd:linkage>
                                                <gmd:URL>
                                                  <xsl:value-of select="normalize-space(string(.))"
                                                  />
                                                </gmd:URL>
                                            </gmd:linkage>
                                            <gmd:protocol>
                                                <gco:CharacterString>WWW:LINK-1.0-http--link</gco:CharacterString>
                                            </gmd:protocol>
                                            <xsl:if test="string-length(normalize-space(@scheme))>0 or 
                                                    string-length(normalize-space(@dct:scheme))>0">
                                                    <gmd:applicationProfile>
                                                        <gco:CharacterString>
                                                            <xsl:choose>
                                                                <xsl:when test="string-length(normalize-space(@scheme))>0">
                                                                    <xsl:value-of select="normalize-space(@scheme)"/>
                                                                </xsl:when>
                                                                <xsl:when test="string-length(normalize-space(@dct:scheme))>0">
                                                                    <xsl:value-of select="normalize-space(@dct:scheme)"/>
                                                                </xsl:when>
                                                            </xsl:choose>
                                                        </gco:CharacterString>
                                                    </gmd:applicationProfile>
                                                </xsl:if>
                                            <gmd:name>
                                                 <gco:CharacterString>Dublin Core references URL</gco:CharacterString>
                                            </gmd:name>
                                            <gmd:description>
                                                <gco:CharacterString>URL provided in Dublin Core references element</gco:CharacterString>
                                            </gmd:description>
                                            <gmd:function>
                                                <gmd:CI_OnLineFunctionCode
                                                  codeList="http://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#CI_OnLineFunctionCode"
                                                  codeListValue="information"
                                                  >dct:references</gmd:CI_OnLineFunctionCode>
                                            </gmd:function>
                                        </gmd:CI_OnlineResource>
                                    </gmd:onLine>
                                </xsl:if>
                            </xsl:for-each>

                            <!-- if a medium is specified, interpretationis that its accessed offline. -->
                            <xsl:if test="//*[local-name() = 'medium']">
                                <gmd:offLine>
                                    <gmd:MD_Medium>
                                        <gmd:mediumNote>
                                            <gco:CharacterString>
                                                <xsl:for-each select="//*[local-name() = 'medium']">
                                                  <xsl:value-of select="normalize-space(string(.))"/>
                                                  <xsl:if
                                                  test="following::*[local-name() = 'medium']">
                                                  <xsl:text>;   </xsl:text>
                                                  </xsl:if>
                                                </xsl:for-each>
                                            </gco:CharacterString>
                                        </gmd:mediumNote>
                                    </gmd:MD_Medium>
                                </gmd:offLine>
                            </xsl:if>

                        </gmd:MD_DigitalTransferOptions>
                    </gmd:transferOptions>
                </gmd:MD_Distribution>
            </gmd:distributionInfo>
            <!-- put method descripiton in the lineage statement -->
            <xsl:if test="//*[local-name() = 'provenance'] or //*[local-name() = 'source']">
                <gmd:dataQualityInfo>
                    <gmd:DQ_DataQuality>
                        <gmd:scope gco:nilReason="missing"/>
                        <gmd:lineage>
                            <gmd:LI_Lineage>
                                <xsl:if test="//*[local-name() = 'provenance']">
                                    <gmd:statement>
                                        <gco:CharacterString>
                                            <xsl:for-each select="//*[local-name() = 'provenance']">
                                                <xsl:value-of select="normalize-space(string(.))"/>
                                                <xsl:if
                                                  test="following::*[local-name() = 'provenance']">
                                                  <xsl:text>;   </xsl:text>
                                                </xsl:if>
                                            </xsl:for-each>
                                        </gco:CharacterString>
                                    </gmd:statement>
                                </xsl:if>
                                <xsl:for-each select="//*[local-name() = 'source']">
                                    <gmd:source>
                                        <gmd:LI_Source>
                                            <gmd:description>
                                                <gco:CharacterString>
                                                  <xsl:value-of select="normalize-space(string(.))"
                                                  />
                                                </gco:CharacterString>
                                            </gmd:description>
                                        </gmd:LI_Source>
                                    </gmd:source>
                                </xsl:for-each>
                            </gmd:LI_Lineage>
                        </gmd:lineage>
                    </gmd:DQ_DataQuality>
                </gmd:dataQualityInfo>
            </xsl:if>
            <gmd:metadataMaintenance>
                <gmd:MD_MaintenanceInformation>
                    <gmd:maintenanceAndUpdateFrequency gco:nilReason="unknown"/>
                    <gmd:maintenanceNote>
                        <gco:CharacterString>
                            <xsl:value-of
                                select="concat(string($metaMaintenanceNote), string('  Run on '), string($currentDateTime))"
                            />
                        </gco:CharacterString>
                    </gmd:maintenanceNote>
                    <gmd:contact>
                        <xsl:if test="$maintenanceContactID != ''">
                            <xsl:attribute name="xlink:href">
                                <xsl:value-of select="$maintenanceContactID"/>
                            </xsl:attribute>
                        </xsl:if>
                        <gmd:CI_ResponsibleParty>
                            <gmd:individualName>
                                <gco:CharacterString>
                                    <xsl:value-of select="$maintenanceContactName"/>
                                </gco:CharacterString>
                            </gmd:individualName>
                            <gmd:contactInfo>
                                <gmd:CI_Contact>
                                    <gmd:address>
                                        <gmd:CI_Address>
                                            <gmd:electronicMailAddress>
                                                <gco:CharacterString>
                                                  <xsl:value-of select="$maintenanceContactEmail"/>
                                                </gco:CharacterString>
                                            </gmd:electronicMailAddress>
                                        </gmd:CI_Address>
                                    </gmd:address>
                                </gmd:CI_Contact>
                            </gmd:contactInfo>
                            <gmd:role>
                                <gmd:CI_RoleCode
                                    codeList="http://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#CI_RoleCode"
                                    codeListValue="processor">processor</gmd:CI_RoleCode>
                            </gmd:role>
                        </gmd:CI_ResponsibleParty>
                    </gmd:contact>
                </gmd:MD_MaintenanceInformation>
            </gmd:metadataMaintenance>
        </gmd:MD_Metadata>
    </xsl:template>
    <!-- retrieves basic reference dates of the resource-->
    <xsl:template name="resourcedates">
        <!--<xsl:if test="$dc-dates/*[local-name() = 'date' and @dateType = 'Created'] != ''">-->
        <!-- dct date types to ISO, ad hoc mapping, maybe there's some 'standard' mapping?
        created - creation
        valid - publication
        available - publication
        issued - publication
        modified  - revision
        dateAccepted - publication
        dateCopyrighted  - publication
        dateSubmitted - creation        
        -->
        <xsl:choose>
            <xsl:when test="$dc-dates">
                <xsl:for-each select="$dc-dates">
                    <xsl:if test="normalize-space(string(.)) != ''">
                        <xsl:variable name="inputDate" select="normalize-space(string(.))"/>
                        <!-- YYYY-MM-DDTHH:MM:SS -->
                        <xsl:variable name="castableAsISODateTime"
                            select="
                                (substring($inputDate, 5, 1) = '-') and
                                (substring($inputDate, 8, 1) = '-') and
                                (substring($inputDate, 11, 1) = 'T') and
                                (substring($inputDate, 14, 1) = ':') and
                                (substring($inputDate, 17, 1) = ':')"/>
                        <!-- YYYY-MM-DD -->
                        <xsl:variable name="castableAsISODate"
                            select="
                                (substring($inputDate, 5, 1) = '-') and
                                (substring($inputDate, 8, 1) = '-') and
                                string-length($inputDate) = 10"/>
                        <!-- M/D/YYYY, MM/DD/YYYY, MM/YYYY, YYYY -->
                        <xsl:variable name="dayVal">
                            <xsl:choose>
                                <xsl:when test="string-length($inputDate) > 7">
                                    <xsl:value-of select="substring-before($inputDate, '/')"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="string('')"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:variable>
                        <xsl:variable name="monthVal">
                            <!--select="substring-before(substring-after($inputDate,'/'),'/')"-->
                            <xsl:choose>
                                <xsl:when test="string-length(normalize-space($inputDate)) > 7">
                                    <xsl:value-of
                                        select="substring-before(substring-after($inputDate, '/'), '/')"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="substring-before($inputDate, '/')"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:variable>
                        <xsl:variable name="yearVal">
                            <!--select="substring-after(substring-after($inputDate,'/'),'/')"-->
                            <xsl:choose>
                                <xsl:when test="string-length(normalize-space($inputDate)) > 7">
                                    <xsl:value-of
                                        select="substring(substring-after(substring-after($inputDate, '/'), '/'), 1, 4)"
                                    />
                                </xsl:when>
                                <xsl:when test="string-length(normalize-space($inputDate)) = 4">
                                    <xsl:value-of select="normalize-space($inputDate)"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="substring(substring-after($inputDate, '/'), 1, 4)"
                                    />
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:variable>
                        <xsl:variable name="castableAsMDYDate" select="number($yearVal)"/>
                        <!-- YYYYMMDD -->
                        <xsl:variable name="castableAsFDate"
                            select="string-length($inputDate) &lt;= 8 and number($inputDate)"/>
                        <gmd:date>
        
                            <xsl:if
                                test="
                                    not($castableAsISODateTime or
                                    $castableAsISODate or
                                    $castableAsFDate or
                                    $castableAsMDYDate)">
                                <!-- date is in format we don't have parser for -->
                                <!-- insert the date string in the xlink title so its in the result doc somewhere... -->
                                <xsl:attribute name="xlink:title">
                                    <xsl:value-of select="concat('can not parse date:', normalize-space(string(.)))"/>
                                </xsl:attribute>
                                <xsl:attribute name="gco:nilReason">unknown</xsl:attribute>
                            </xsl:if>
                            <gmd:CI_Date>
                                <gmd:date>
                                    <xsl:choose>
                                        <xsl:when
                                            test="
                                                not($castableAsISODateTime or
                                                $castableAsISODate or
                                                $castableAsFDate or
                                                $castableAsMDYDate)">
                                            <!-- date is in format we don't have parser for -->
                                            <xsl:attribute name="gco:nilReason">
                                                <xsl:value-of select="string('unknown')"/>
                                            </xsl:attribute>
        
                                        </xsl:when>
                                        <xsl:when test="$castableAsISODateTime">
                                            <gco:DateTime>
                                                <xsl:value-of select="normalize-space($inputDate)"/>
                                            </gco:DateTime>
                                        </xsl:when>
                                        <xsl:when test="$castableAsISODate">
                                            <gco:DateTime>
                                                <xsl:value-of
                                                    select="concat(normalize-space($inputDate), 'T12:00:00')"
                                                />
                                            </gco:DateTime>
                                        </xsl:when>
                                        <xsl:when test="$castableAsFDate">
                                            <gco:DateTime>
                                                <xsl:choose>
                                                    <xsl:when
                                                        test="string-length(normalize-space(string($inputDate))) = 8">
                                                        <xsl:value-of
                                                          select="
                                                                concat(substring(normalize-space(string($inputDate)), 0, 5), '-',
                                                                substring(normalize-space(string($inputDate)), 5, 2), '-',
                                                                substring(normalize-space(string($inputDate)), 7, 2),
                                                                'T12:00:00')"
                                                        />
                                                    </xsl:when>
                                                    <xsl:when
                                                        test="string-length(normalize-space(string($inputDate))) = 6">
                                                        <xsl:value-of
                                                          select="
                                                                concat(substring(normalize-space(string($inputDate)), 0, 5), '-',
                                                                substring(normalize-space(string($inputDate)), 5, 2), '-01T12:00:00')"
                                                        />
                                                    </xsl:when>
                                                    <xsl:when
                                                        test="string-length(normalize-space(string($inputDate))) = 4">
                                                        <xsl:value-of
                                                          select="concat(substring(normalize-space(string($inputDate)), 0, 5), '-01-01T12:00:00')"
                                                        />
                                                    </xsl:when>
                                                </xsl:choose>
                                            </gco:DateTime>
                                        </xsl:when>
                                        <xsl:when test="$castableAsMDYDate">
                                            <gco:DateTime>
                                                <xsl:choose>
                                                    <xsl:when
                                                        test="number($dayVal) and number($monthVal) and number($yearVal)">
                                                        <xsl:value-of
                                                          select="
                                                                concat($yearVal, '-',
                                                                format-number($monthVal, '00'), '-', format-number($dayVal, '00'), 'T12:00:00')"
                                                        />
                                                    </xsl:when>
                                                    <xsl:when test="number($monthVal) and number($yearVal)">
                                                        <xsl:value-of
                                                          select="
                                                                concat($yearVal, '-',
                                                                format-number($monthVal, '00'), '-', '01T12:00:00')"
                                                        />
                                                    </xsl:when>
                                                    <xsl:when test="number($yearVal)">
                                                        <xsl:value-of
                                                          select="
                                                                concat($yearVal, '-',
                                                                '01-01T12:00:00')"
                                                        />
                                                    </xsl:when>
                                                </xsl:choose>
                                            </gco:DateTime>
                                        </xsl:when>
                                        <!-- there is no otherwise, should have been caught before getting into this choose -->
                                    </xsl:choose>
        
                                </gmd:date>
                                <gmd:dateType>
                                    <xsl:choose>
                                        <xsl:when test="local-name() = 'created'">
                                            <gmd:CI_DateTypeCode
                                                codeList="http://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#CI_DateTypeCode"
                                                codeListValue="creation">created</gmd:CI_DateTypeCode>
                                        </xsl:when>
                                        <xsl:when test="local-name() = 'valid'">
                                            <gmd:CI_DateTypeCode
                                                codeList="http://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#CI_DateTypeCode"
                                                codeListValue="publication">valid</gmd:CI_DateTypeCode>
                                        </xsl:when>
                                        <xsl:when test="local-name() = 'available'">
                                            <gmd:CI_DateTypeCode
                                                codeList="http://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#CI_DateTypeCode"
                                                codeListValue="publication">available</gmd:CI_DateTypeCode>
                                        </xsl:when>
                                        <xsl:when test="local-name() = 'issued'">
                                            <gmd:CI_DateTypeCode
                                                codeList="http://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#CI_DateTypeCode"
                                                codeListValue="publication">issued</gmd:CI_DateTypeCode>
                                        </xsl:when>
                                        <xsl:when test="local-name() = 'modified'">
                                            <gmd:CI_DateTypeCode
                                                codeList="http://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#CI_DateTypeCode"
                                                codeListValue="revision">modified</gmd:CI_DateTypeCode>
                                        </xsl:when>
                                        <xsl:when test="local-name() = 'dateAccepted'">
                                            <gmd:CI_DateTypeCode
                                                codeList="http://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#CI_DateTypeCode"
                                                codeListValue="publication"
                                                >dateAccepted</gmd:CI_DateTypeCode>
                                        </xsl:when>
                                        <xsl:when test="local-name() = 'dateCopyrighted'">
                                            <gmd:CI_DateTypeCode
                                                codeList="http://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#CI_DateTypeCode"
                                                codeListValue="publication"
                                                >dateCopyrighted</gmd:CI_DateTypeCode>
                                        </xsl:when>
                                        <xsl:when test="local-name() = 'dateSubmitted'">
                                            <gmd:CI_DateTypeCode
                                                codeList="http://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#CI_DateTypeCode"
                                                codeListValue="creation">dateSubmitted</gmd:CI_DateTypeCode>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <gmd:CI_DateTypeCode
                                                codeList="http://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#CI_DateTypeCode"
                                                codeListValue="creation">creation</gmd:CI_DateTypeCode>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </gmd:dateType>
                            </gmd:CI_Date>
                        </gmd:date>
                    </xsl:if>
                </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
                <gmd:date gco:nilReason="missing"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!-- convert dc authors -->
    <xsl:template name="creators">
        <xsl:for-each select="$dc-creators">
            <gmd:citedResponsibleParty>
                <xsl:variable name="httpuri" select="string('')"/>
                <xsl:variable name="nameidscheme" select="string('')"/>
                <xsl:variable name="email" select="string('')"/>
                <xsl:variable name="namestring">
                    <xsl:value-of select="normalize-space(string(.))"/>
                </xsl:variable>
                <xsl:call-template name="ci_responsibleparty">
                    <xsl:with-param name="individual">
                        <xsl:value-of select="$namestring"/>
                    </xsl:with-param>
                    <xsl:with-param name="httpuri">
                        <xsl:value-of select="$httpuri"/>
                    </xsl:with-param>
                    <xsl:with-param name="personidtype">
                        <xsl:value-of select="$nameidscheme"/>
                    </xsl:with-param>
                    <xsl:with-param name="organisation">
                        <xsl:value-of select=".//*[local-name() = 'affiliation']"/>
                    </xsl:with-param>
                    <xsl:with-param name="position"/>
                    <xsl:with-param name="role">author</xsl:with-param>
                    <xsl:with-param name="email">
                        <xsl:value-of select="$email"/>
                    </xsl:with-param>
                </xsl:call-template>
            </gmd:citedResponsibleParty>
        </xsl:for-each>
    </xsl:template>
    <!-- convert dc contributors and try to translate the roles-->
    <xsl:template name="contributors">
        <xsl:for-each select="//*[local-name() = 'contributor']">
            <xsl:variable name="dcrole" select="'contributor'"/>
            <xsl:variable name="role">
                <xsl:choose>
                    <xsl:when test="$dcrole = 'ContactPerson'">pointOfContact</xsl:when>
                    <xsl:when test="$dcrole = 'DataCollector'">collaborator</xsl:when>
                    <xsl:when test="$dcrole = 'DataCurator'">custodian</xsl:when>
                    <xsl:when test="$dcrole = 'DataManager'">custodian</xsl:when>
                    <xsl:when test="$dcrole = 'Distributor'">originator</xsl:when>
                    <xsl:when test="$dcrole = 'Editor'">editor</xsl:when>
                    <xsl:when test="$dcrole = 'Funder'">funder</xsl:when>
                    <xsl:when test="$dcrole = 'HostingInstitution'">distributor</xsl:when>
                    <xsl:when test="$dcrole = 'ProjectLeader'">collaborator</xsl:when>
                    <xsl:when test="$dcrole = 'ProjectManager'">collaborator</xsl:when>
                    <xsl:when test="$dcrole = 'ProjectMember'">collaborator</xsl:when>
                    <xsl:when test="$dcrole = 'ResearchGroup'">collaborator</xsl:when>
                    <xsl:when test="$dcrole = 'Researcher'">collaborator</xsl:when>
                    <xsl:when test="$dcrole = 'RightsHolder'">rightsHolder</xsl:when>
                    <xsl:when test="$dcrole = 'Sponsor'">funder</xsl:when>
                    <xsl:when test="$dcrole = 'WorkPackageLeader'">collaborator</xsl:when>
                    <xsl:otherwise>contributor</xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <gmd:citedResponsibleParty>
                <xsl:variable name="httpuri" select="string('')"/>
                <xsl:variable name="nameidscheme" select="string('')"/>
                <xsl:variable name="email" select="string('')"/>
                <xsl:variable name="contrnamestring">
                    <xsl:value-of select="normalize-space(string(.))"/>
                </xsl:variable>
                <xsl:call-template name="ci_responsibleparty">
                    <xsl:with-param name="individual">
                        <xsl:value-of select="$contrnamestring"/>
                    </xsl:with-param>
                    <xsl:with-param name="httpuri">
                        <xsl:value-of select="$httpuri"/>
                    </xsl:with-param>
                    <xsl:with-param name="personidtype">
                        <xsl:value-of select="$nameidscheme"/>
                    </xsl:with-param>
                    <xsl:with-param name="organisation">
                        <xsl:value-of select="string('')"/>
                    </xsl:with-param>
                    <xsl:with-param name="position">
                        <xsl:value-of select="$dcrole"/>
                    </xsl:with-param>
                    <xsl:with-param name="email">
                        <xsl:value-of select="$email"/>
                    </xsl:with-param>
                    <xsl:with-param name="role" select="$role"/>
                </xsl:call-template>
            </gmd:citedResponsibleParty>
        </xsl:for-each>
    </xsl:template>
    <!-- retrieves a dataset contact and uses either the contributors with a 
		matching role "ContactPerson" or "DataCurator" or the first creator in the 'creators' sequence-->
    <xsl:template name="datasetcontact">
        <xsl:choose>
            <xsl:when test="$dc-creators[1]">
                <gmd:pointOfContact>
                    <xsl:variable name="httpuri" select="string('')"/>
                    <xsl:variable name="nameidscheme" select="string('')"/>
                    <xsl:if test="$httpuri != ''">
                        <xsl:attribute name="xlink:href">
                            <xsl:value-of select="$httpuri"/>
                        </xsl:attribute>
                    </xsl:if>
                    <xsl:variable name="email" select="string('')"/>
                    <xsl:variable name="namestring"
                        select="normalize-space(string($dc-creators[1]))"/>
                    <xsl:call-template name="ci_responsibleparty">
                        <xsl:with-param name="individual">
                            <xsl:value-of select="$namestring"/>
                        </xsl:with-param>
                        <xsl:with-param name="httpuri">
                            <xsl:value-of select="$httpuri"/>
                        </xsl:with-param>
                        <xsl:with-param name="personidtype">
                            <xsl:value-of select="$nameidscheme"/>
                        </xsl:with-param>
                        <xsl:with-param name="organisation">
                            <xsl:value-of select=".//*[local-name() = 'affiliation']"/>
                        </xsl:with-param>
                        <xsl:with-param name="position"/>
                        <xsl:with-param name="role">pointOfContact</xsl:with-param>
                    </xsl:call-template>
                </gmd:pointOfContact>
            </xsl:when>
            <xsl:otherwise>
                <gmd:pointOfContact gco:nilReason="missing"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <!-- A helper function to serialize basic person/affiliation information.
There are several ways to model a person ID (https://geo-ide.noaa.gov/wiki/index.php?title=ISO_Researcher_ID).
All approaches are based on URLs - currently only ORCID seems to support URLs.
The ID of persons should also be put as "xlink:href" attribute into the parent element. -->
    <xsl:template name="ci_responsibleparty">
        <xsl:param name="individual"/>
        <xsl:param name="httpuri"/>
        <xsl:param name="personidtype"/>
        <xsl:param name="organisation"/>
        <xsl:param name="position"/>
        <xsl:param name="role"/>
        <xsl:param name="email"/>
        <gmd:CI_ResponsibleParty>
            <xsl:if test="$individual != ''">
                <gmd:individualName>
                    <gco:CharacterString>
                        <xsl:value-of select="$individual"/>
                    </gco:CharacterString>
                </gmd:individualName>
            </xsl:if>
            <xsl:if test="$organisation != ''">
                <gmd:organisationName>
                    <gco:CharacterString>
                        <xsl:value-of select="$organisation"/>
                    </gco:CharacterString>
                </gmd:organisationName>
            </xsl:if>
            <xsl:if test="$position != ''">
                <gmd:positionName>
                    <gco:CharacterString>
                        <xsl:value-of select="$position"/>
                    </gco:CharacterString>
                </gmd:positionName>
            </xsl:if>
            <gmd:contactInfo>
                <xsl:choose>
                    <xsl:when test="string-length($email) + string-length($httpuri) = 0">
                        <xsl:attribute name="gco:nilReason">missing</xsl:attribute>
                    </xsl:when>
                    <xsl:otherwise>
                        <gmd:CI_Contact>
                            <!-- In the INSPIRE profile of the European Union the email is mandatory for contacts. 
							put in bogus null email-->
                            <gmd:address>
                                <gmd:CI_Address>
                                    <gmd:electronicMailAddress>
                                        <xsl:choose>
                                            <xsl:when test="$email != ''">
                                                <gco:CharacterString>
                                                  <xsl:value-of select="$email"/>
                                                </gco:CharacterString>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:attribute name="gco:nilReason">
                                                  <xsl:value-of select="string('missing')"/>
                                                </xsl:attribute>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </gmd:electronicMailAddress>
                                </gmd:CI_Address>
                            </gmd:address>
                            <xsl:if test="$httpuri != ''">
                                <gmd:onlineResource>
                                    <gmd:CI_OnlineResource>
                                        <gmd:linkage>
                                            <gmd:URL>
                                                <xsl:value-of select="$httpuri"/>
                                            </gmd:URL>
                                        </gmd:linkage>
                                        <gmd:protocol>
                                            <gco:CharacterString>
                                                <xsl:value-of select="$personidtype"/>
                                            </gco:CharacterString>
                                        </gmd:protocol>
                                    </gmd:CI_OnlineResource>
                                </gmd:onlineResource>
                            </xsl:if>
                        </gmd:CI_Contact>
                    </xsl:otherwise>
                </xsl:choose>
            </gmd:contactInfo>
            <gmd:role>
                <gmd:CI_RoleCode>
                    <xsl:attribute name="codeList"
                        >http://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#CI_RoleCode</xsl:attribute>
                    <xsl:attribute name="codeListValue">
                        <xsl:value-of select="$role"/>
                    </xsl:attribute>
                    <xsl:value-of select="$role"/>
                </gmd:CI_RoleCode>
            </gmd:role>
        </gmd:CI_ResponsibleParty>
    </xsl:template>


 <xsl:template name="spatialcoverage">
        <!-- handle ows: encoded bounding boxes, as expected in  csw:record -->
        <!-- Note: nLat is always the northernmost latitude, 
            wLong is always the westmost longitude. They are geographic, not algebraic -->
        <xsl:for-each select="//*[contains(local-name(), 'BoundingBox')]">
            <xsl:variable name="description" select="string('')"/>
            <xsl:variable name="sLat">
                <xsl:choose>
                    <xsl:when test="local-name()='WGS84BoundingBox'">
                        <xsl:value-of select="substring-after(normalize-space(ows:LowerCorner), ' ')"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="substring-before(normalize-space(ows:LowerCorner), ' ')"/>
                    </xsl:otherwise>
                </xsl:choose> 
            </xsl:variable>
                
            <xsl:variable name="nLat">
                <xsl:choose>
                    <xsl:when test="local-name()='WGS84BoundingBox'">
                        <xsl:value-of select="substring-after(normalize-space(ows:UpperCorner), ' ')"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="substring-before(normalize-space(ows:UpperCorner), ' ')"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
             
            <xsl:variable name="wLong">
                <xsl:choose>
                    <xsl:when test="local-name()='WGS84BoundingBox'">
                        <xsl:value-of select="substring-before(normalize-space(ows:LowerCorner), ' ')"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="substring-after(normalize-space(ows:LowerCorner), ' ')"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>

            <xsl:variable name="eLong">
                <xsl:choose>
                    <xsl:when test="local-name()='WGS84BoundingBox'">
                        <xsl:value-of select="substring-before(normalize-space(ows:UpperCorner), ' ')"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="substring-after(normalize-space(ows:UpperCorner), ' ')"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>

            <gmd:extent>
                <gmd:EX_Extent>
                    <xsl:if test="normalize-space($description)">
                        <gmd:description>
                            <gco:CharacterString>
                                <xsl:value-of select="normalize-space($description)"/>
                            </gco:CharacterString>
                        </gmd:description>
                    </xsl:if>
                    <xsl:choose>
                        <xsl:when test="$sLat = $nLat and $wLong = $eLong">
                            <!-- encode as point using EX_BoundingPolygon, which allows any kind of gml geometry -->
                            <gmd:geographicElement>
                                <gmd:EX_BoundingPolygon>
                                    <gmd:polygon>
                                        <gml:Point>
                                            <!-- generate a unique id of the source xml node -->
                                            <xsl:attribute name="gml:id">
                                                <xsl:value-of select="generate-id(.)"/>
                                            </xsl:attribute>
                                            <gml:pos>
                                                <xsl:value-of select="$sLat"/>
                                                <xsl:text> </xsl:text>
                                                <xsl:value-of select="$wLong"/>
                                            </gml:pos>
                                        </gml:Point>
                                    </gmd:polygon>
                                </gmd:EX_BoundingPolygon>
                            </gmd:geographicElement>
                        </xsl:when>

                        <!-- check to see if box crosses 180 with west side either in east long (positive) or <-180, or east side  
                            >180. If so, create two bounding box geographicElements-->
                        <xsl:when test="($wLong &gt;0 and $eLong &lt;0)">
                            <!-- use east longitude coordinates -->
                            <gmd:geographicElement>
                                <gmd:EX_GeographicBoundingBox>
                                    <gmd:westBoundLongitude>
                                        <gco:Decimal>
                                            <xsl:value-of select="$wLong"/>
                                        </gco:Decimal>
                                    </gmd:westBoundLongitude>
                                    <gmd:eastBoundLongitude>
                                        <gco:Decimal>
                                            <xsl:value-of select="180"/>
                                        </gco:Decimal>
                                    </gmd:eastBoundLongitude>
                                    <gmd:southBoundLatitude>
                                        <gco:Decimal>
                                            <xsl:choose>
                                                <xsl:when test="number($sLat) &lt; number($nLat)">
                                                    <xsl:value-of select="$sLat"/>
                                                </xsl:when>
                                                <xsl:otherwise>
                                                    <xsl:value-of select="$nLat"/>
                                                </xsl:otherwise>
                                            </xsl:choose>
                                        </gco:Decimal>
                                    </gmd:southBoundLatitude>
                                    <gmd:northBoundLatitude>
                                        <gco:Decimal>
                                            <xsl:choose>
                                                <xsl:when test="number($sLat) &lt; number($nLat)">
                                                    <xsl:value-of select="$nLat"/>
                                                </xsl:when>
                                                <xsl:otherwise>
                                                    <xsl:value-of select="$sLat"/>
                                                </xsl:otherwise>
                                            </xsl:choose>
                                        </gco:Decimal>
                                    </gmd:northBoundLatitude>
                                </gmd:EX_GeographicBoundingBox>
                            </gmd:geographicElement>
                            <gmd:geographicElement>
                                <gmd:EX_GeographicBoundingBox>
                                    <gmd:westBoundLongitude>
                                        <gco:Decimal>
                                            <xsl:value-of select="-180"/>
                                        </gco:Decimal>
                                    </gmd:westBoundLongitude>
                                    <gmd:eastBoundLongitude>
                                        <gco:Decimal>
                                            <xsl:value-of select="$eLong"/>
                                        </gco:Decimal>
                                    </gmd:eastBoundLongitude>
                                    <gmd:southBoundLatitude>
                                        <gco:Decimal>
                                            <xsl:choose>
                                                <xsl:when test="number($sLat) &lt; number($nLat)">
                                                    <xsl:value-of select="$sLat"/>
                                                </xsl:when>
                                                <xsl:otherwise>
                                                    <xsl:value-of select="$nLat"/>
                                                </xsl:otherwise>
                                            </xsl:choose>
                                        </gco:Decimal>
                                    </gmd:southBoundLatitude>
                                    <gmd:northBoundLatitude>
                                        <gco:Decimal>
                                            <xsl:choose>
                                                <xsl:when test="number($sLat) &lt; number($nLat)">
                                                    <xsl:value-of select="$nLat"/>
                                                </xsl:when>
                                                <xsl:otherwise>
                                                    <xsl:value-of select="$sLat"/>
                                                </xsl:otherwise>
                                            </xsl:choose>
                                        </gco:Decimal>
                                    </gmd:northBoundLatitude>
                                </gmd:EX_GeographicBoundingBox>
                            </gmd:geographicElement>
                        </xsl:when>
                        <xsl:otherwise>
                            <!-- we know $wLong < 0 or $eLong > 0) -->
                            <gmd:geographicElement>
                                <gmd:EX_GeographicBoundingBox>
                                    <gmd:westBoundLongitude>
                                        <gco:Decimal>
                                            <xsl:choose>
                                                  <xsl:when
                                                  test="number($wLong) &lt; number($eLong)">
                                            <xsl:value-of select="$wLong"/>
                                            </xsl:when>
                                                  <xsl:otherwise>
                                                  <xsl:value-of select="$eLong"/>
                                                  </xsl:otherwise>
                                                  </xsl:choose>
                                        </gco:Decimal>
                                    </gmd:westBoundLongitude>
                                    <gmd:eastBoundLongitude>
                                        <gco:Decimal>
                                            <xsl:choose>
                                                  <xsl:when
                                                  test="number($wLong) &lt; number($eLong)">
                                            <xsl:value-of select="$eLong"/>
                                            </xsl:when>
                                                  <xsl:otherwise>
                                                  <xsl:value-of select="$wLong"/>
                                                  </xsl:otherwise>
                                                  </xsl:choose>
                                        </gco:Decimal>
                                    </gmd:eastBoundLongitude>
                                    <gmd:southBoundLatitude>
                                        <gco:Decimal>
                                            <xsl:choose>
                                                <xsl:when test="number($sLat) &lt; number($nLat)">
                                                    <xsl:value-of select="$sLat"/>
                                                </xsl:when>
                                                <xsl:otherwise>
                                                    <xsl:value-of select="$nLat"/>
                                                </xsl:otherwise>
                                            </xsl:choose>
                                        </gco:Decimal>
                                    </gmd:southBoundLatitude>
                                    <gmd:northBoundLatitude>
                                        <gco:Decimal>
                                            <xsl:choose>
                                                <xsl:when test="number($sLat) &lt; number($nLat)">
                                                    <xsl:value-of select="$nLat"/>
                                                </xsl:when>
                                                <xsl:otherwise>
                                                    <xsl:value-of select="$sLat"/>
                                                </xsl:otherwise>
                                            </xsl:choose>
                                        </gco:Decimal>
                                    </gmd:northBoundLatitude>
                                </gmd:EX_GeographicBoundingBox>
                            </gmd:geographicElement>
                        </xsl:otherwise>
                    </xsl:choose>
                </gmd:EX_Extent>
            </gmd:extent>
        </xsl:for-each>
        <!-- deal with dublin core spatial recommended encoding for point and bounding box 
        see http://dublincore.org/documents/2006/04/10/dcmi-box/-->
        <xsl:for-each select="//*[local-name() = 'spatial']">
            <xsl:choose>
                <xsl:when
                    test="
                        contains(string(.), 'northlimit') and
                        contains(string(.), 'southlimit') and
                        contains(string(.), 'eastlimit') and
                        contains(string(.), 'westlimit')">
                    <xsl:variable name="description">
                        <xsl:choose>
                            <xsl:when
                                test="
                                contains(substring-after(normalize-space(string(.)), 'name='), ';') and
                                    contains(string(.), 'name=')">
                                <xsl:value-of
                                    select="substring-before(substring-after(normalize-space(string(.)), 'name='), '; ')"
                                />
                            </xsl:when>
                            <xsl:when test="contains(string(.), 'name=')">
                                <xsl:value-of
                                    select="substring-after(normalize-space(string(.)), 'name=')"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="string('')"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                    <xsl:variable name="sLat">
                        <xsl:choose>
                            <xsl:when
                                test="contains(substring-after(string(.), 'southlimit='), ';')">
                                <xsl:value-of
                                    select="substring-before(substring-after(normalize-space(string(.)), 'southlimit='), '; ')"
                                />
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of
                                    select="substring-after(normalize-space(string(.)), 'southlimit=')"
                                />
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>

                    <xsl:variable name="nLat">
                        <xsl:choose>
                            <xsl:when
                                test="contains(substring-after(string(.), 'northlimit='), ';')">
                                <xsl:value-of
                                    select="substring-before(substring-after(normalize-space(string(.)), 'northlimit='), '; ')"
                                />
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of
                                    select="substring-after(normalize-space(string(.)), 'northlimit=')"
                                />
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>

                    <xsl:variable name="wLong">
                        <xsl:choose>
                            <xsl:when test="contains(substring-after(string(.), 'westlimit='), ';')">
                                <xsl:value-of
                                    select="substring-before(substring-after(normalize-space(string(.)), 'westlimit='), '; ')"
                                />
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of
                                    select="substring-after(normalize-space(string(.)), 'westlimit=')"
                                />
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>

                    <xsl:variable name="eLong">
                        <xsl:choose>
                            <xsl:when test="contains(substring-after(string(.), 'eastlimit='), ';')">
                                <xsl:value-of
                                    select="substring-before(substring-after(normalize-space(string(.)), 'eastlimit='), '; ')"
                                />
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of
                                    select="substring-after(normalize-space(string(.)), 'eastlimit=')"
                                />
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>

                    <gmd:extent>
                        <gmd:EX_Extent>
                            <xsl:if test="string-length(normalize-space($description)) > 0">
                                <gmd:description>
                                    <gco:CharacterString>
                                        <xsl:value-of select="normalize-space($description)"/>
                                    </gco:CharacterString>
                                </gmd:description>
                            </xsl:if>
                            <xsl:choose>
                                <xsl:when test="$sLat = $nLat and $wLong = $eLong">
                                    <!-- degenerate box, encode as point -->
                                    <gmd:geographicElement>
                                        <gmd:EX_BoundingPolygon>
                                            <gmd:polygon>
                                                <gml:Point>
                                                  <!-- generate a unique id of the source xml node -->
                                                  <xsl:attribute name="gml:id">
                                                  <xsl:value-of select="generate-id(.)"/>
                                                  </xsl:attribute>
                                                  <gml:pos>
                                                  <xsl:value-of select="$sLat"/>
                                                  <xsl:text> </xsl:text>
                                                  <xsl:value-of select="$wLong"/>
                                                  </gml:pos>
                                                </gml:Point>
                                            </gmd:polygon>
                                        </gmd:EX_BoundingPolygon>
                                    </gmd:geographicElement>
                                </xsl:when>
                                <xsl:otherwise>
                                    <gmd:geographicElement>
                                        <gmd:EX_GeographicBoundingBox>
                                            <gmd:westBoundLongitude>
                                                <gco:Decimal>
                                                  <xsl:value-of select="$wLong"/>
                                                </gco:Decimal>
                                            </gmd:westBoundLongitude>
                                            <gmd:eastBoundLongitude>
                                                <gco:Decimal>
                                                  <xsl:value-of select="$eLong"/>
                                                </gco:Decimal>
                                            </gmd:eastBoundLongitude>
                                            <gmd:southBoundLatitude>
                                                <gco:Decimal>
                                                  <xsl:value-of select="$sLat"/>
                                                </gco:Decimal>
                                            </gmd:southBoundLatitude>
                                            <gmd:northBoundLatitude>
                                                <gco:Decimal>
                                                  <xsl:value-of select="$nLat"/>
                                                </gco:Decimal>
                                            </gmd:northBoundLatitude>
                                        </gmd:EX_GeographicBoundingBox>
                                    </gmd:geographicElement>
                                </xsl:otherwise>
                            </xsl:choose>
                        </gmd:EX_Extent>
                    </gmd:extent>
                </xsl:when>
                <xsl:when
                    test="
                        contains(string(.), 'north=') and
                        contains(string(.), 'east=')">
                    <!-- encode point -->
                    <xsl:variable name="description">
                        <xsl:choose>
                            <xsl:when
                                test="
                                    contains(string(.), ';') and
                                    contains(string(.), 'name=')">
                                <xsl:value-of
                                    select="substring-before(substring-after(normalize-space(string(.)), 'name='), '; ')"
                                />
                            </xsl:when>
                            <xsl:when test="contains(string(.), 'name=')">
                                <xsl:value-of
                                    select="substring-after(normalize-space(string(.)), 'name=')"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="string('')"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                    <xsl:variable name="sLat">
                        <xsl:choose>
                            <xsl:when test="contains(substring-after(string(.), 'north='), ';')">
                                <xsl:value-of
                                    select="substring-before(substring-after(normalize-space(string(.)), 'north='), '; ')"
                                />
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of
                                    select="substring-after(normalize-space(string(.)), 'north=')"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                    <xsl:variable name="wLong">
                        <xsl:choose>
                            <xsl:when test="contains(substring-after(string(.), 'east='), ';')">
                                <xsl:value-of
                                    select="substring-before(substring-after(normalize-space(string(.)), 'east='), '; ')"
                                />
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of
                                    select="substring-after(normalize-space(string(.)), 'east=')"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                    <gmd:extent>
                        <gmd:EX_Extent>
                            <xsl:if test="normalize-space($description)">
                                <gmd:description>
                                    <gco:CharacterString>
                                        <xsl:value-of select="normalize-space($description)"/>
                                    </gco:CharacterString>
                                </gmd:description>
                            </xsl:if>
                            <gmd:geographicElement>
                                <gmd:EX_BoundingPolygon>
                                    <gmd:polygon>
                                        <gml:Point>
                                            <!-- generate a unique id of the source xml node -->
                                            <xsl:attribute name="gml:id">
                                                <xsl:value-of select="generate-id(.)"/>
                                            </xsl:attribute>
                                            <gml:pos>
                                                <xsl:value-of select="$sLat"/>
                                                <xsl:text> </xsl:text>
                                                <xsl:value-of select="$wLong"/>
                                            </gml:pos>
                                        </gml:Point>
                                    </gmd:polygon>
                                </gmd:EX_BoundingPolygon>
                            </gmd:geographicElement>
                        </gmd:EX_Extent>
                    </gmd:extent>
                </xsl:when>
                <xsl:otherwise>
                    <!-- put the text in geographic description -->
                    <gmd:extent>
                        <gmd:EX_Extent>
                            <gmd:description>
                                <gco:CharacterString>
                                    <xsl:value-of select="normalize-space(string(.))"/>
                                </gco:CharacterString>
                            </gmd:description>
                        </gmd:EX_Extent>
                    </gmd:extent>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>
    <!-- handle dc:temporal -->
    <xsl:template name="temporalcoverage">
        
        <xsl:for-each select="//*[local-name() = 'temporal']">
         <xsl:if test="string-length(normalize-space(string(.)))>0">
            <xsl:variable name="description">
                <xsl:choose>
                    <xsl:when
                        test="
                            contains(substring-after(string(.), 'name='), ';') and
                            contains(string(.), 'name=')">
                        <xsl:value-of
                            select="substring-before(substring-after(normalize-space(string(.)), 'name='), '; ')"
                        />
                    </xsl:when>
                    <xsl:when test="contains(string(.), 'name=')">
                        <xsl:value-of select="substring-after(normalize-space(string(.)), 'name=')"
                        />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="string('')"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:variable name="mindate">
                <!-- end -->
                <xsl:choose>
                    <xsl:when
                        test="contains(string(.), 'end=') and contains(substring-after(string(.), 'end='), ';')">
                        <xsl:value-of
                            select="substring-before(substring-after(normalize-space(string(.)), 'end='), ';')"
                        />
                    </xsl:when>
                    <xsl:when test="contains(string(.), 'end=')">
                        <xsl:value-of select="substring-after(normalize-space(string(.)), 'end=')"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="string('')"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:variable name="maxdate">
                <!-- start -->
                <xsl:choose>
                    <xsl:when
                        test="contains(string(.), 'start=') and contains(substring-after(string(.), 'start='), ';')">
                        <xsl:value-of
                            select="substring-before(substring-after(normalize-space(string(.)), 'start='), ';')"
                        />
                    </xsl:when>
                    <xsl:when test="contains(string(.), 'start=')">
                        <xsl:value-of select="substring-after(normalize-space(string(.)), 'start=')"
                        />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="string('')"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <gmd:extent>
                <gmd:EX_Extent>
                    <xsl:choose>
                        <xsl:when
                            test="
                                string-length(normalize-space($description)) +
                                string-length(normalize-space($mindate)) +
                                string-length(normalize-space($maxdate)) = 0">
                            <!--  doesn't use the  key-value pair encoding, no name, start, end... -->
                            <gmd:description>
                                <gco:CharacterString>
                                    <xsl:value-of select="normalize-space(string(.))"/>
                                </gco:CharacterString>
                            </gmd:description>
                            <gmd:temporalElement gco:nilReason="unknown"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:if test="string-length(normalize-space($description)) > 0">
                                <gmd:description>
                                    <gco:CharacterString>
                                        <xsl:value-of select="normalize-space($description)"/>
                                    </gco:CharacterString>
                                </gmd:description>
                            </xsl:if>
                            <gmd:temporalElement>
                                <gmd:EX_TemporalExtent>
                                    <gmd:extent>
                                        <xsl:choose>
                                            <xsl:when test="$mindate != '' and $maxdate != ''">
                                                <gml:TimePeriod>
                                                  <xsl:attribute name="gml:id">
                                                  <xsl:value-of select="generate-id(.)"/>
                                                  </xsl:attribute>
                                                  <gml:beginPosition>
                                                  <xsl:value-of select="$maxdate"/>
                                                  </gml:beginPosition>
                                                  <gml:endPosition>
                                                  <xsl:value-of select="$mindate"/>
                                                  </gml:endPosition>
                                                </gml:TimePeriod>
                                            </xsl:when>
                                            <xsl:when test="$mindate != '' and $maxdate = ''">
                                                <gml:TimePeriod>
                                                  <xsl:attribute name="gml:id">
                                                  <xsl:value-of select="generate-id(.)"/>
                                                  </xsl:attribute>
                                                  <gml:beginPosition>
                                                  <xsl:value-of select="$mindate"/>
                                                  </gml:beginPosition>
                                                  <gml:endPosition indeterminatePosition="unknown"/>
                                                </gml:TimePeriod>
                                            </xsl:when>
                                            <xsl:when test="$mindate = '' and $maxdate != ''">
                                                <gml:TimePeriod>
                                                  <xsl:attribute name="gml:id">
                                                  <xsl:value-of select="generate-id(.)"/>
                                                  </xsl:attribute>
                                                  <gml:beginPosition indeterminatePosition="unknown"/>
                                                  <gml:endPosition>
                                                  <xsl:value-of select="$mindate"/>
                                                  </gml:endPosition>
                                                </gml:TimePeriod>
                                            </xsl:when>
                                            <!--<xsl:otherwise>
                                        <gml:TimeInstant>
                                            <!-\- generate a unique id of the source xml node -\->
                                            <xsl:attribute name="gml:id">
                                                <xsl:value-of select="generate-id(.)"/>
                                            </xsl:attribute>
                                            <gml:timePosition>
                                                <xsl:value-of select="normalize-space(.)"/>
                                            </gml:timePosition>
                                        </gml:TimeInstant>
                                    </xsl:otherwise>-->
                                        </xsl:choose>
                                    </gmd:extent>
                                </gmd:EX_TemporalExtent>
                            </gmd:temporalElement>
                        </xsl:otherwise>
                    </xsl:choose>
                </gmd:EX_Extent>
            </gmd:extent>
         </xsl:if>
        
        </xsl:for-each>
    </xsl:template>
    <!-- retrieves names in key-value encoded dc:tempporal elements, put in gmd keywords -->
    <xsl:template name="temporalkeywords">
        <xsl:if test="//*[local-name() = 'temporal' and contains(string(.), 'name=')]">
            <gmd:descriptiveKeywords>
                <gmd:MD_Keywords>
                    <xsl:for-each
                        select="//*[local-name() = 'temporal' and contains(string(.), 'name=')]">
                        <gmd:keyword>
                            <gco:CharacterString>
                                <xsl:choose>
                                    <xsl:when
                                        test="
                                            contains(substring-after(normalize-space(string(.)), 'name='), ';') and
                                            contains(string(.), 'name=')">
                                        <xsl:value-of
                                            select="substring-before(substring-after(normalize-space(string(.)), 'name='), '; ')"
                                        />
                                    </xsl:when>
                                    <xsl:when test="contains(string(.), 'name=')">
                                        <xsl:value-of
                                            select="substring-after(normalize-space(string(.)), 'name=')"
                                        />
                                    </xsl:when>
                                </xsl:choose>
                            </gco:CharacterString>
                        </gmd:keyword>
                    </xsl:for-each>
                    <gmd:type>
                        <gmd:MD_KeywordTypeCode
                            codeList="http://www.ngdc.noaa.gov/metadata/published/xsd/schema/resources/Codelist/gmxCodelists.xml#MD_KeywordTypeCode"
                            codeListValue="temporal">dc:temporal</gmd:MD_KeywordTypeCode>
                    </gmd:type>
                </gmd:MD_Keywords>
            </gmd:descriptiveKeywords>
        </xsl:if>
    </xsl:template>
    <!-- retrieves keywords that have a subject scheme - group by subjectScheme -->
    <xsl:template name="keywords">
        <xsl:if test="//*[local-name() = 'subject']">
            <gmd:descriptiveKeywords>
                <gmd:MD_Keywords>
                    <xsl:for-each select="//*[local-name() = 'subject']">
                        <gmd:keyword>
                            <gco:CharacterString>
                                <xsl:value-of select="normalize-space(.)"/>
                            </gco:CharacterString>
                        </gmd:keyword>
                    </xsl:for-each>
                    <gmd:type>
                        <gmd:MD_KeywordTypeCode
                            codeList="http://www.ngdc.noaa.gov/metadata/published/xsd/schema/resources/Codelist/gmxCodelists.xml#MD_KeywordTypeCode"
                            codeListValue="theme">
                            <xsl:value-of select="string('theme')"/>
                        </gmd:MD_KeywordTypeCode>
                    </gmd:type>

                </gmd:MD_Keywords>
            </gmd:descriptiveKeywords>
        </xsl:if>
    </xsl:template>
    <xsl:template name="geolocationplace">
        <xsl:if test="//*[local-name() = 'spatial' and contains(string(.), 'name=')]">
            <gmd:descriptiveKeywords>
                <gmd:MD_Keywords>
                    <xsl:for-each
                        select="//*[local-name() = 'spatial' and contains(string(.), 'name=')]">
                        <gmd:keyword>
                            <gco:CharacterString>
                                <xsl:choose>
                                    <xsl:when
                                        test="
                                            contains(substring-after(normalize-space(string(.)), 'name='), ';') and
                                            contains(string(.), 'name=')">
                                        <xsl:value-of
                                            select="substring-before(substring-after(normalize-space(string(.)), 'name='), '; ')"
                                        />
                                    </xsl:when>
                                    <xsl:when test="contains(string(.), 'name=')">
                                        <xsl:value-of
                                            select="substring-after(normalize-space(string(.)), 'name=')"
                                        />
                                    </xsl:when>
                                </xsl:choose>
                            </gco:CharacterString>
                        </gmd:keyword>
                    </xsl:for-each>
                    <gmd:type>
                        <gmd:MD_KeywordTypeCode
                            codeList="http://www.ngdc.noaa.gov/metadata/published/xsd/schema/resources/Codelist/gmxCodelists.xml#MD_KeywordTypeCode"
                            codeListValue="place">dc:spatial</gmd:MD_KeywordTypeCode>
                    </gmd:type>
                </gmd:MD_Keywords>
            </gmd:descriptiveKeywords>
        </xsl:if>
    </xsl:template>
    <!-- rights and license information into access constraints -->
    <xsl:template name="license">
        <xsl:for-each
            select="
                //*[local-name() = 'rights'] |
                //*[local-name() = 'accessRights'] |
                //*[local-name() = 'license']">
            <gmd:resourceConstraints>
                <xsl:if test="contains(string(.), 'http')">
                    <xsl:attribute name="xlink:href">
                        <xsl:value-of select="normalize-space(string(.))"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:choose>
                    <xsl:when test="contains(local-name(), 'ights')">
                        <gmd:MD_Constraints>
                            <gmd:useLimitation>
                                <gco:CharacterString>
                                    <xsl:value-of
                                        select="concat(local-name(), ': ', normalize-space(string(.)))"
                                    />
                                </gco:CharacterString>
                            </gmd:useLimitation>
                        </gmd:MD_Constraints>
                    </xsl:when>
                    <xsl:when test="local-name() = 'license'">
                        <gmd:MD_LegalConstraints>
                            <gmd:accessConstraints>
                                <gmd:MD_RestrictionCode
                                    codeList="http://www.isotc211.org/2005/resources/codeList.xml#MD_RestrictionCode"
                                    codeListValue="license"/>
                            </gmd:accessConstraints>
                            <gmd:otherConstraints>
                                <gco:CharacterString>
                                    <xsl:value-of select="normalize-space(string(.))"/>
                                </gco:CharacterString>
                            </gmd:otherConstraints>
                        </gmd:MD_LegalConstraints>
                    </xsl:when>
                </xsl:choose>
            </gmd:resourceConstraints>
        </xsl:for-each>
    </xsl:template>
    <!-- retrieves version and format - only the first occurents of these elements-->
    <xsl:template name="versionandformat">
        <xsl:for-each select="//*[local-name() = 'format']">
            <xsl:if test="string-length(normalize-space(string(.))) > 0">
                <gmd:resourceFormat>
                    <gmd:MD_Format>
                        <gmd:name>
                            <gco:CharacterString>
                                <xsl:value-of select="normalize-space(string(.))"/>
                            </gco:CharacterString>
                        </gmd:name>
                        <gmd:version gco:nilReason="missing"/>
                    </gmd:MD_Format>
                </gmd:resourceFormat>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
    <xsl:template name="getidscheme">
        <xsl:param name="httpuri"/>
        <xsl:choose>
            <!-- add tests for other identifier schemes here... -->
            <xsl:when test="starts-with($httpuri, 'http://orcid.org/')">
                <xsl:value-of select="string('ORCID')"/>
            </xsl:when>
            <xsl:when test="starts-with($httpuri, 'http://isni.org/isni')">
                <xsl:value-of select="string('ISNI')"/>
            </xsl:when>
            <xsl:when test="starts-with($httpuri, 'https://www.scopus.com/authid')">
                <xsl:value-of select="string('SCOPUS')"/>
            </xsl:when>
            <xsl:when test="starts-with($httpuri, 'http://')">
                <xsl:value-of select="string('HTTP')"/>
            </xsl:when>
            <!-- context for template call is the local context, so * is OK -->
            <xsl:when
                test="
                    count(*[local-name() = 'nameIdentifier']/@nameIdentifierScheme) &gt; 0 and
                    *[local-name() = 'nameIdentifier']/@nameIdentifierScheme != ''">
                <xsl:value-of
                    select="normalize-space(*[local-name() = 'nameIdentifier'][1]/@nameIdentifierScheme)"
                />
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="string('')"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template name="gethttpuri">
        <xsl:param name="theids"/>
        <xsl:choose>
            <!-- add tests for other identifier schemes here... -->
            <xsl:when test="count($theids[@nameIdentifierScheme = 'ORCID']) &gt; 0"
                    >http://orcid.org/<xsl:value-of
                    select="$theids[@nameIdentifierScheme = 'ORCID'][1]"/>
            </xsl:when>
            <xsl:when test="count($theids[@nameIdentifierScheme = 'ISNI']) &gt; 0"
                    >http://isni.org/isni/<xsl:value-of
                    select="$theids[@nameIdentifierScheme = 'ISNI'][1]"/>
            </xsl:when>
            <xsl:when test="count($theids[@nameIdentifierScheme = 'SCOPUS']) &gt; 0"
                    >https://www.scopus.com/authid/detail.uri?authorId=<xsl:value-of
                    select="$theids[@nameIdentifierScheme = 'SCOPUS'][1]"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="test1">
                    <xsl:for-each select="$theids">
                        <xsl:if test="starts-with(., 'http://')">
                            <xsl:value-of select="."/>
                            <!-- if there is more than one http id, will 
									take the last one it checks... -->
                        </xsl:if>
                    </xsl:for-each>
                </xsl:variable>
                <xsl:choose>
                    <xsl:when test="$test1 = ''">
                        <xsl:value-of select="string('')"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$test1"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <xsl:template name="relatedResources">
        <!-- relres is a set of relatedIdentifier nodes -->
        <xsl:param name="relres"/>
        <xsl:for-each select="$relres">
            <xsl:choose>
                <xsl:when
                    test="
                        not(contains(normalize-space(string(.)), 'missing')) and
                        not(contains(normalize-space(string(.)), 'unknown'))">
                    <gmd:aggregationInfo>
                        <gmd:MD_AggregateInformation>
                            <gmd:aggregateDataSetIdentifier>
                                <gmd:RS_Identifier>
                                    <gmd:code>
                                        <gco:CharacterString>
                                            <xsl:value-of select="normalize-space(string(.))"/>
                                        </gco:CharacterString>
                                    </gmd:code>
                                    <xsl:if test="@scheme | @xsi:type">
                                        <gmd:codeSpace>
                                            <gco:CharacterString>
                                                <xsl:choose>
                                                  <xsl:when test="@scheme">
                                                  <xsl:value-of
                                                  select="normalize-space(string(@scheme))"/>
                                                  </xsl:when>
                                                  <xsl:when test="@xsi:type">
                                                  <xsl:value-of
                                                  select="normalize-space(string(@xsi:type))"/>
                                                  </xsl:when>
                                                </xsl:choose>
                                            </gco:CharacterString>
                                        </gmd:codeSpace>
                                    </xsl:if>
                                </gmd:RS_Identifier>
                            </gmd:aggregateDataSetIdentifier>
                            <gmd:associationType>
                                <xsl:element name="gmd:DS_AssociationTypeCode">
                                    <xsl:attribute name="codeList">
                                        <xsl:value-of
                                            select="string('http://www.isotc211.org/2005/resources/codeList.xml#DS_AssociationTypeCode')"/>
                                    </xsl:attribute>
                                    <xsl:attribute name="codeListValue">
                                        <xsl:value-of select="string('crossReference')"/>
                                    </xsl:attribute>
                                    <xsl:value-of select="local-name()"/>
                                </xsl:element>
                            </gmd:associationType>
                        </gmd:MD_AggregateInformation>
                    </gmd:aggregationInfo>
                </xsl:when>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>



    <xsl:template name="FormatDate">
        <!-- designed for dates formatted like Date value="4/1/2013" -->
        <xsl:param name="dt"/>
        <xsl:choose>
            <xsl:when test="contains($dt, '/') and contains(substring-after($dt, '/'), '/')">
                <xsl:variable name="M" select="substring-before($dt, '/')"/>
                <xsl:variable name="D-Y" select="substring-after($dt, '/')"/>
                <xsl:variable name="D" select="substring-before($D-Y, '/')"/>
                <xsl:variable name="Y" select="substring-after($D-Y, '/')"/>
                <xsl:value-of
                    select="concat($Y, '-', format-number($M, '00'), '-', format-number($D, '00'), 'T12:00:00')"
                />
            </xsl:when>
            <xsl:when test="contains($dt, '/')">
                <!-- assume mm/yyyy -->
                <xsl:variable name="M" select="substring-before($dt, '/')"/>
                <xsl:variable name="Y" select="substring-after($dt, '/')"/>
                <xsl:value-of select="concat($Y, '-', format-number($M, '00'), '-', '01T12:00:00')"
                />
            </xsl:when>
            <xsl:when test="string-length($dt) = 4">
                <xsl:value-of select="concat($dt, '-01-01T12:00:00')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="string('error')"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!-- tries to retrieve the size of the data and does a conversion to bytes -->
    <xsl:template name="size">
        <xsl:variable name="alpha">abcdefghijklmnopqrstuvwxyz</xsl:variable>
        <xsl:variable name="ALPHA">ABCDEFGHIJKLMNOPQRSTUVWXYZ</xsl:variable>
        <xsl:variable name="numeric">1234567890.-</xsl:variable>
        <xsl:variable name="sizes"
            select="//*[local-name() = 'extent' and (contains(translate(., $ALPHA, $alpha), 'byte') or 
            contains(translate(., $ALPHA, $alpha), 'kb') or contains(translate(., $ALPHA, $alpha), 'kilobyte') or 
            contains(translate(., $ALPHA, $alpha), 'mb') or contains(translate(., $ALPHA, $alpha), 'megabyte') or 
            contains(translate(., $ALPHA, $alpha), 'gb') or contains(translate(., $ALPHA, $alpha), 'gigabyte') or 
            contains(translate(., $ALPHA, $alpha), 'tb') or contains(translate(., $ALPHA, $alpha), 'terabyte') or 
            contains(translate(., $ALPHA, $alpha), 'pb') or 
            contains(translate(., $ALPHA, $alpha), 'petabyte'))][1]"/>
        <xsl:variable name="sizevalue"
            select="normalize-space(translate($sizes, translate($sizes, $numeric, ''), ''))"/>
        <xsl:variable name="size">
            <xsl:choose>
                <xsl:when
                    test="contains(translate($sizes, $ALPHA, $alpha), 'pb') or contains(translate($sizes, $ALPHA, $alpha), 'petabyte')">
                    <xsl:value-of select="$sizevalue"/>000000000000000 </xsl:when>
                <xsl:when
                    test="contains(translate($sizes, $ALPHA, $alpha), 'tb') or contains(translate($sizes, $ALPHA, $alpha), 'terabyte')">
                    <xsl:value-of select="$sizevalue"/>000000000000 </xsl:when>
                <xsl:when
                    test="contains(translate($sizes, $ALPHA, $alpha), 'gb') or contains(translate($sizes, $ALPHA, $alpha), 'gigabyte')">
                    <xsl:value-of select="$sizevalue"/>000000000 </xsl:when>
                <xsl:when
                    test="contains(translate($sizes, $ALPHA, $alpha), 'mb') or contains(translate($sizes, $ALPHA, $alpha), 'megabyte')">
                    <xsl:value-of select="$sizevalue"/>000000 </xsl:when>
                <xsl:when
                    test="contains(translate($sizes, $ALPHA, $alpha), 'kb') or contains(translate($sizes, $ALPHA, $alpha), 'kilobyte')">
                    <xsl:value-of select="$sizevalue"/>000 </xsl:when>
                <xsl:when test="contains(translate($sizes, $ALPHA, $alpha), 'byte')">
                    <xsl:value-of select="$sizevalue"/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:if test="normalize-space($size) != ''">
            <gmd:transferSize>
                <gco:Real>
                    <xsl:value-of select="$size"/>
                </gco:Real>
            </gmd:transferSize>
        </xsl:if>
    </xsl:template>
</xsl:stylesheet>
