<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format"
                xmlns:ows="http://www.opengis.net/ows" xmlns:ows11="http://www.opengis.net/ows/1.1"
                xmlns:csw="http://www.opengis.net/cat/csw" xmlns:csw202="http://www.opengis.net/cat/csw/2.0.2"
                xmlns:wcs="http://www.opengis.net/wcs" xmlns:wcs11="http://www.opengis.net/wcs/1.1"
                xmlns:wcs111="http://www.opengis.net/wcs/1.1.1" xmlns:wfs="http://www.opengis.net/wfs"
                xmlns:wms="http://www.opengis.net/wms" xmlns:wps100="http://www.opengis.net/wps/1.0.0"
                xmlns:sos10="http://www.opengis.net/sos/1.0" xmlns:sps="http://www.opengis.net/sps"
                xmlns:tml="http://www.opengis.net/tml" xmlns:sml="http://www.opengis.net/sensorML/1.0.1"
                xmlns:gco="http://www.isotc211.org/2005/gco" xmlns:myorg="http://www.myorg.org/features"
                xmlns:swe="http://www.opengis.net/swe/1.0.1" xmlns:exslt="http://exslt.org/common"
                xmlns:gmd="http://www.isotc211.org/2005/gmd" xmlns:gml="http://www.opengis.net/gml"
                xmlns:srv="http://www.isotc211.org/2005/srv" xmlns:xlink="http://www.w3.org/1999/xlink"
                xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                xsi:schemaLocation="http://www.isotc211.org/2005/gmd http://schemas.opengis.net/iso/19139/20060504/gmd/gmd.xsd
 http://www.isotc211.org/2005/srv http://schemas.opengis.net/iso/19139/20060504/srv/srv.xsd">

    <xsl:output method="xml" version="1.0" encoding="UTF-8"
                indent="yes"/>
    <xsl:param name="sourceUrl"/>
    <xsl:param name="serviceType"/>
    <xsl:param name="currentDate"/>
    <xsl:param name="generatedUUID"/>
    <!-- *********** -->
    <!-- This style sheet converts OGC WMS capabilities response document (versions 1.0.0, 1.1.1 or 1.3.0 to
         ISO (19115(2006), 19119, 19139 metadata that conforms with the USGIN metadata profile.
         See http://lab.usgin.org/profiles/usgin-iso-metadata-profile (http://lab.usgin.org/node/235) -->
    <!-- Lund Wolfe, lund.wolfe@azgs.az.gov -->
    <!-- provided as-is, use at your own risk! -->
    <!-- this program based on ogc-toISO19139.xslt provided with ESRI geoportal software package
and USGIN service metadata example xml document -->
    <!-- version 1.0 2011-1-25 -->
    <xsl:template match="/">
        <xsl:call-template name="main"/>
    </xsl:template>
    <xsl:template name="main">
        <!-- Core gmd based instance document -->
        <!-- USGIN ISO 19139 geospatial service metadata record with explicitly
              linked references to coupled resources (map layers) for a WMS service -->
        <gmd:MD_Metadata
                xsl:exclude-result-prefixes="ows ows11 wms wps100 swe myorg tml sml sps sos10 wfs wcs wcs11 wcs111 csw csw202 gml">
            <!-- (M-M) Metadata file identifier - A unique File Identifier (GUID)
                   - USGIN recommends using a valid Universally Unique Identifier (UUID) -->
            <gmd:fileIdentifier>
                <gco:CharacterString>
                    <xsl:value-of select="$generatedUUID"/>
                </gco:CharacterString>
            </gmd:fileIdentifier>
            <!-- language -->
            <xsl:choose>
                <xsl:when test="//ows:Language | //Language">
                    <gmd:language>
                        <gco:CharacterString>
                            <xsl:value-of select="text()"/>
                        </gco:CharacterString>
                    </gmd:language>
                </xsl:when>
                <xsl:otherwise>
                    <gmd:language>
                        <gco:CharacterString>eng</gco:CharacterString>
                    </gmd:language>
                </xsl:otherwise>
            </xsl:choose>
            <!-- (M-M) Metadata character set - default is "utf8", codelist = MD_CharacterSetCode.
                   USGIN requires that a character set code is defined to facilitate CSW servers
                   (deegree, GeoNetwork, etc.). -->
            <gmd:characterSet>
                <gmd:MD_CharacterSetCode
                        codeList="http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/Codelist/gmxCodelists.xml#MD_CharacterSetCode"
                        codeListValue="utf8">UTF-8
                </gmd:MD_CharacterSetCode>
            </gmd:characterSet>
            <!-- (M-M) Resource type - this is specific to WMS, so define as service -->
            <gmd:hierarchyLevel>
                <gmd:MD_ScopeCode
                        codeList="http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/Codelist/gmxCodelists.xml#MD_ScopeCode"
                        codeListValue="service">service
                </gmd:MD_ScopeCode>
            </gmd:hierarchyLevel>
            <!-- (O-M) Resource hierarchy level name - For services USGIN hierarchyLevelName.CharacterString
                   is “Service”. -->
            <gmd:hierarchyLevelName>
                <gco:CharacterString>Service</gco:CharacterString>
            </gmd:hierarchyLevelName>
            <!-- (M-M) Metadata point of contact - Point of contact for the metadata
                   record, e.g. for users to report errors, updates to metadata, etc. This will
                   default to the harvesting agent for USGIN purposes, so define with USGIN
                   contact information -->
            <gmd:contact>
                <gmd:CI_ResponsibleParty>
                    <!-- (M-M) (individualName + organisationName + positionName) > 0 -->
                    <gmd:organisationName>
                        <gco:CharacterString>US Geoscience Information Network, Arizona Geological Survey
                        </gco:CharacterString>
                    </gmd:organisationName>
                    <gmd:positionName>
                        <gco:CharacterString>Metadata Editor</gco:CharacterString>
                    </gmd:positionName>
                    <gmd:contactInfo>
                        <gmd:CI_Contact>
                            <!-- Phone -->
                            <gmd:phone>
                                <gmd:CI_Telephone>
                                    <gmd:voice>
                                        <gco:CharacterString>520.770.3500</gco:CharacterString>
                                    </gmd:voice>
                                </gmd:CI_Telephone>
                            </gmd:phone>
                            <!-- Address -->
                            <gmd:address>
                                <gmd:CI_Address>
                                    <gmd:deliveryPoint>
                                        <gco:CharacterString>416 W. Congress St., Suite 100</gco:CharacterString>
                                    </gmd:deliveryPoint>
                                    <gmd:city>
                                        <gco:CharacterString>Tucson</gco:CharacterString>
                                    </gmd:city>
                                    <gmd:administrativeArea>
                                        <gco:CharacterString>Arizona</gco:CharacterString>
                                    </gmd:administrativeArea>
                                    <gmd:postalCode>
                                        <gco:CharacterString>85701-1381</gco:CharacterString>
                                    </gmd:postalCode>
                                    <gmd:country>
                                        <gco:CharacterString>USA</gco:CharacterString>
                                    </gmd:country>
                                    <!-- (O-M) Metadata point of contact e-mail address - mandatory
                                                 in USGIN -->
                                    <gmd:electronicMailAddress>
                                        <gco:CharacterString>metadata@azgs.az.gov</gco:CharacterString>
                                    </gmd:electronicMailAddress>
                                </gmd:CI_Address>
                            </gmd:address>
                            <!-- (O-O) online resources - this is the online resource to contact
                                       the metadata person -->
                            <gmd:onlineResource>
                                <gmd:CI_OnlineResource>
                                    <gmd:linkage>
                                        <gmd:URL>http://www.azgs.az.gov</gmd:URL>
                                    </gmd:linkage>
                                    <gmd:protocol>
                                        <gco:CharacterString>http</gco:CharacterString>
                                    </gmd:protocol>
                                    <gmd:description>
                                        <gco:CharacterString>Arizona Geological Survey Web Site</gco:CharacterString>
                                    </gmd:description>
                                </gmd:CI_OnlineResource>
                            </gmd:onlineResource>
                            <!-- (O-O) hours of service -->
                            <gmd:hoursOfService>
                                <gco:CharacterString>8 AM to 5 PM Mountain Standard time (no daylight savings)
                                </gco:CharacterString>
                            </gmd:hoursOfService>
                            <!-- (O-O) contact instructions -->
                            <gmd:contactInstructions>
                                <gco:CharacterString>Fill out contact form at http://www.azgs.az.gov
                                </gco:CharacterString>
                            </gmd:contactInstructions>
                        </gmd:CI_Contact>
                    </gmd:contactInfo>
                    <!-- (M-M) ISO 19139 Mandatory: contact role -->
                    <gmd:role>
                        <!-- CI_RoleCode names: {resourceProvider, custodian, owner, user,
                                  distributor, originator, pointOfContact, principalInvestigator, processor,
                                  publisher, author} - NAP expands with {collaborator, editor, mediator, rightsHolder}. -->
                        <!-- NAP example -->
                        <!-- <gmd:CI_RoleCode codeList="http://www.fgdc.gov/nap/metadata/register/codelists.html#IC_90"
                                  codeListValue="RI_414">pointOfContact</gmd:CI_RoleCode> -->
                        <!-- ISO example -->
                        <gmd:CI_RoleCode
                                codeList="http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/Codelist/gmxCodelists.xml#CI_RoleCode"
                                codeListValue="pointOfContact">point of contact
                        </gmd:CI_RoleCode>
                    </gmd:role>
                </gmd:CI_ResponsibleParty>
            </gmd:contact>
            <!-- (X-O) Metadata should include a URL that locates a thumbnail logo
                   for organizations related to the metadata origination, the organization hosting
                   the catalog that returned the metadata, the organization that originated
                   the data, and the organization hosting online services that provide access
                   to the data. -->
            <gmd:contact>
                <gmd:CI_ResponsibleParty>
                    <gmd:organisationName>
                        <gco:CharacterString>Arizona Geological Survey</gco:CharacterString>
                    </gmd:organisationName>
                    <gmd:contactInfo>
                        <gmd:CI_Contact>
                            <gmd:onlineResource>
                                <gmd:CI_OnlineResource>
                                    <!-- Icon image file (e.g. tif, png, jpg) for the metadata originator.
                                                 This Icon will be displayed in search results to credit the metadata originator. -->
                                    <gmd:linkage>
                                        <gmd:URL>
                                            http://resources.usgin.org/uri-gin/usgin/organization/azgs/logo/50x50.png
                                        </gmd:URL>
                                    </gmd:linkage>
                                    <!-- (X-C) For URL’s that indicate icon thumbnails, the CI_OnlineResource/name
                                                 should be ‘icon’. -->
                                    <gmd:name>
                                        <gco:CharacterString>icon</gco:CharacterString>
                                    </gmd:name>
                                </gmd:CI_OnlineResource>
                            </gmd:onlineResource>
                        </gmd:CI_Contact>
                    </gmd:contactInfo>
                    <gmd:role>
                        <!-- CI_RoleCode names: {resourceProvider, custodian, owner, user,
                                  distributor, originator, pointOfContact, principalInvestigator, processor,
                                  publisher, author} - NAP expands with {collaborator, editor, mediator, rightsHolder}. -->
                        <gmd:CI_RoleCode
                                codeList="http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/Codelist/gmxCodelists.xml#CI_RoleCode"
                                codeListValue="originator">originator
                        </gmd:CI_RoleCode>
                    </gmd:role>
                </gmd:CI_ResponsibleParty>
            </gmd:contact>
            <!-- (M-M) Metadata date stamp - USGIN profile requires use of dateStamp/gco:DateTime
                   (Note this contrasts with INSPIRE mandate to use dateStamp/gco:Date). This
                   is the date and time when the metadata record was created or updated (following
                   NAP). -->
            <gmd:dateStamp>
                <gco:DateTime>
                    <xsl:value-of select="concat($currentDate,'T12:00:00')"/>
                </gco:DateTime>
            </gmd:dateStamp>
            <!-- (M-M) metadata standard - NAP specifies "NAP - Metadata". USGIN profile
                   conformant metadata is indicated by using “ISO-NAP-USGIN" -->
            <gmd:metadataStandardName>
                <gco:CharacterString>ISO-NAP-USGIN</gco:CharacterString>
            </gmd:metadataStandardName>
            <!-- (O-M) USGIN profile version -->
            <gmd:metadataStandardVersion>
                <gco:CharacterString>1.1</gco:CharacterString>
            </gmd:metadataStandardVersion>
            <!-- (O-O) Resource’s spatial reference system -->
            <xsl:if
                    test="//Capability/Layer[1]/SRS | //wms:Capability/wms:Layer[1]/wms:SRS">
                <gmd:referenceSystemInfo>
                    <gmd:MD_ReferenceSystem>
                        <!-- ISO 19115:2003 Corrigendum 1:2006 removes CRS and projection parameter
                                  information. It uses the new ISO 19111 instead -->
                        <gmd:referenceSystemIdentifier>
                            <gmd:RS_Identifier>
                                <!-- (C-C) Reference System identifier code - For USGIN the code
                                            should be a value from the EPSG Geodetic Parameter Dataset register (http://www.epsg-registry.org/)
                                            in the form "EPSG:nnnn" where nnnn is the EPSG code number for the CRS. -->
                                <gmd:code>
                                    <gco:CharacterString>
                                        <xsl:value-of
                                                select="//Capability/Layer[1]/SRS | //wms:Capability/wms:Layer[1]/wms:SRS"/>
                                    </gco:CharacterString>
                                </gmd:code>
                                <gmd:codeSpace>
                                    <gco:CharacterString>urn:ogc:def:crs</gco:CharacterString>
                                </gmd:codeSpace>
                            </gmd:RS_Identifier>
                        </gmd:referenceSystemIdentifier>
                    </gmd:MD_ReferenceSystem>
                </gmd:referenceSystemInfo>
            </xsl:if>
            <!--******************* -->
            <!-- (M-M) Resource identification information - At least one of MD_DataIdentification
                   (dataset, dataset series) or SV_ServiceIdentification (service) is required. -->
            <gmd:identificationInfo>
                <!-- Resource Service Identification -->
                <srv:SV_ServiceIdentification>
                    <gmd:citation>
                        <!-- (M-M) Resource citation - For USGIN purposes, this should be viewed
                                  as information to identify the intellectual origin of the content in the
                                  described resource, along the lines of a citation in a scientific journal.
                                  Required content for a CI_Citation element are title, date, and responsibleParty -->
                        <gmd:CI_Citation>
                            <!-- (M-M) Resource title - USGIN recommends using titles that inform
                                       the human reader about the dataset’s content as well as its context. -->
                            <gmd:title>
                                <xsl:if
                                        test="
								/WMT_MS_Capabilities/Service/Title |
								//wms:Service/wms:Title  | 
								/wms:WMT_MS_Capabilities/wms:Service/wms:Title				
						">
                                    <gco:CharacterString>
                                        <xsl:value-of
                                                select="
								/WMT_MS_Capabilities/Service/Title |
								//wms:Service/wms:Title  | 
								/wms:WMT_MS_Capabilities/wms:Service/wms:Title				
						"/>
                                    </gco:CharacterString>
                                </xsl:if>
                            </gmd:title>
                            <!-- (M-M) Resource reference date - This will be difficult to know
                                       for harvested ogc GetCapabilities -->
                            <xsl:choose>
                                <xsl:when test="//gml:relatedTime">
                                    <gmd:date>
                                        <gmd:CI_Date>
                                            <gmd:date>
                                                <gco:Date>
                                                    <xsl:value-of select="//gml:relatedTime"/>
                                                </gco:Date>
                                            </gmd:date>
                                            <gmd:dateType>
                                                <gmd:CI_DateTypeCode
                                                        codeList="http://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#CI_DateTypeCode"
                                                        codeListValue="publication"/>
                                            </gmd:dateType>
                                        </gmd:CI_Date>
                                    </gmd:date>
                                </xsl:when>
                                <xsl:otherwise>
                                    <gmd:date>
                                        <gmd:CI_Date>
                                            <gmd:date gco:nilReason="missing">
                                                <gco:DateTime>
                                                    <xsl:value-of select="concat($currentDate,'T12:00:00')"/>
                                                </gco:DateTime>
                                            </gmd:date>
                                            <gmd:dateType gco:nilReason="missing">
                                                <gmd:CI_DateTypeCode
                                                        codeList="http://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#CI_DateTypeCode"
                                                        codeListValue="publication"/>
                                            </gmd:dateType>
                                        </gmd:CI_Date>
                                    </gmd:date>
                                </xsl:otherwise>
                            </xsl:choose>
                            <!-- (C-O) Unique resource identifier - For USGIN, because the Citation
                                       is for the service, this identifier should be identical to MD_Metadta/dataSetURI,
                                       and is therefore optional. For USGIN purposes, this element content value
                                       is only an identifier for the citation; it is not a URL for accessing the
                                       service -->
                            <!-- <gmd:identifier/> -->
                            <!-- (M-M) Resource responsible party - The citation attribute provides
                                       information for citing the described service. -->
                            <xsl:choose>
                                <xsl:when test="//wms:ContactInformation | //ContactInformation">
                                    <gmd:citedResponsibleParty>
                                        <gmd:CI_ResponsibleParty>
                                            <!-- (M-M) (individualName + organisationName + positionName)
                                                           > 0 -->
                                            <xsl:if test="//wms:ContactPerson | //ContactPerson">
                                                <gmd:individualName>
                                                    <gco:CharacterString>
                                                        <xsl:value-of select="//wms:ContactPerson | //ContactPerson"/>
                                                    </gco:CharacterString>
                                                </gmd:individualName>
                                            </xsl:if>
                                            <xsl:if test="//wms:ContactOrganization | //ContactOrganization">
                                                <gmd:organisationName>
                                                    <gco:CharacterString>
                                                        <xsl:value-of
                                                                select="//wms:ContactOrganization | //ContactOrganization"/>
                                                    </gco:CharacterString>
                                                </gmd:organisationName>
                                            </xsl:if>
                                            <xsl:if test="//wms:ContactPosition | //ContactPosition">
                                                <gmd:positionName>
                                                    <gco:CharacterString>
                                                        <xsl:value-of
                                                                select="//wms:ContactPosition | //ContactPosition"/>
                                                    </gco:CharacterString>
                                                </gmd:positionName>
                                            </xsl:if>
                                            <!-- (O-C) Contact Information - (phone + deliveryPoint + electronicMailAddress
                                                           ) > 0. Best practice is to include at least an e-mail address -->
                                            <gmd:contactInfo>
                                                <gmd:CI_Contact>
                                                    <xsl:if
                                                            test="//wms:ContactVoiceTelephone | ContactVoiceTelephone | wms:ContactFacsimileTelephone |
												ContactFacsimileTelephone">
                                                        <gmd:phone>
                                                            <gmd:CI_Telephone>
                                                                <xsl:if
                                                                        test="//wms:ContactVoiceTelephone | //ContactVoiceTelephone">
                                                                    <gmd:voice>
                                                                        <gco:CharacterString>
                                                                            <xsl:value-of
                                                                                    select="//wms:ContactVoiceTelephone | //ContactVoiceTelephone"/>
                                                                        </gco:CharacterString>
                                                                    </gmd:voice>
                                                                </xsl:if>
                                                                <xsl:if
                                                                        test="//wms:ContactFacsimileTelephone | //ContactFacsimileTelephone">
                                                                    <gmd:facsimile>
                                                                        <gco:CharacterString>
                                                                            <xsl:value-of
                                                                                    select="//wms:ContactFacsimileTelephone | //ContactFacsimileTelephone"/>
                                                                        </gco:CharacterString>
                                                                    </gmd:facsimile>
                                                                </xsl:if>
                                                            </gmd:CI_Telephone>
                                                        </gmd:phone>
                                                    </xsl:if>
                                                    <!-- *******************resource contact address*************** -->
                                                    <!-- address element must be present, if an e-mail address is
                                                                     included -->
                                                    <xsl:if
                                                            test="//wms:ContactAddress | //ContactAddress | //wms:ContactElectronicMailAddress | //ContactElectronicMailAddress">
                                                        <gmd:address>
                                                            <gmd:CI_Address>
                                                                <xsl:if
                                                                        test="//wms:ContactAddress/Address | //ContactAddress/Address">
                                                                    <gmd:deliveryPoint>
                                                                        <gco:CharacterString>
                                                                            <xsl:value-of
                                                                                    select="//wms:ContactAddress/Address | //ContactAddress/Address"/>
                                                                        </gco:CharacterString>
                                                                    </gmd:deliveryPoint>
                                                                </xsl:if>
                                                                <xsl:if
                                                                        test="//wms:ContactAddress/City | //ContactAddress/City">
                                                                    <gmd:city>
                                                                        <gco:CharacterString>
                                                                            <xsl:value-of
                                                                                    select="//wms:ContactAddress/City | //ContactAddress/City"/>
                                                                        </gco:CharacterString>
                                                                    </gmd:city>
                                                                </xsl:if>
                                                                <xsl:if
                                                                        test="//wms:ContactAddress/StateOrProvince | //ContactAddress/StateOrProvince">
                                                                    <gmd:administrativeArea>
                                                                        <gco:CharacterString>
                                                                            <xsl:value-of
                                                                                    select="//wms:ContactAddress/StateOrProvince | //ContactAddress/StateOrProvince"/>
                                                                        </gco:CharacterString>
                                                                    </gmd:administrativeArea>
                                                                </xsl:if>
                                                                <xsl:if
                                                                        test="//wms:ContactAddress/PostCode | //ContactAddress/PostCode">
                                                                    <gmd:postalCode>
                                                                        <gco:CharacterString>
                                                                            <xsl:value-of
                                                                                    select="//wms:ContactAddress/PostCode | //ContactAddress/PostCode"/>
                                                                        </gco:CharacterString>
                                                                    </gmd:postalCode>
                                                                </xsl:if>
                                                                <xsl:if
                                                                        test="//wms:ContactAddress/Country | //ContactAddress/Country">
                                                                    <gmd:country>
                                                                        <gco:CharacterString>
                                                                            <xsl:value-of
                                                                                    select="//wms:ContactAddress/Country | //ContactAddress/Country"/>
                                                                        </gco:CharacterString>
                                                                    </gmd:country>
                                                                </xsl:if>
                                                                <gmd:electronicMailAddress>
                                                                    <xsl:choose>
                                                                        <xsl:when
                                                                                test="//wms:ContactElectronicMailAddress | //ContactElectronicMailAddress">
                                                                            <gco:CharacterString>
                                                                                <xsl:value-of
                                                                                        select="//wms:ContactElectronicMailAddress | //ContactElectronicMailAddress"/>
                                                                            </gco:CharacterString>
                                                                        </xsl:when>
                                                                        <xsl:otherwise>
                                                                            <!-- at least an e-mail address is required -->
                                                                            <gco:CharacterString>metadata@usgin.org
                                                                            </gco:CharacterString>
                                                                        </xsl:otherwise>
                                                                    </xsl:choose>
                                                                </gmd:electronicMailAddress>
                                                            </gmd:CI_Address>
                                                        </gmd:address>
                                                    </xsl:if>
                                                    <!-- test if have e-mail -->
                                                </gmd:CI_Contact>
                                            </gmd:contactInfo>
                                            <!-- (M-M) ISO 19139 Mandatory: contact role - Guidance on use
                                                           of role codes would be helpful for consistency, but has not been developed
                                                           as yet. -->
                                            <gmd:role>
                                                <!-- CI_RoleCode names: {resourceProvider, custodian, owner,
                                                                user, distributor, originator, pointOfContact, principalInvestigator, processor,
                                                                publisher, author} - NAP expands with {collaborator, editor, mediator, rightsHolder}. -->
                                                <gmd:CI_RoleCode
                                                        codeList="http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/Codelist/gmxCodelists.xml#CI_RoleCode"
                                                        codeListValue="resourceProvider">resource provider
                                                </gmd:CI_RoleCode>
                                            </gmd:role>
                                        </gmd:CI_ResponsibleParty>
                                    </gmd:citedResponsibleParty>
                                </xsl:when>
                                <xsl:otherwise>  <!-- these are required for conformance with USGIN profile -->
                                    <gmd:citedResponsibleParty
                                            gco:nilReason="missing">
                                        <gmd:CI_ResponsibleParty>
                                            <gmd:individualName gco:nilReason="missing">
                                                <gco:CharacterString>not reported</gco:CharacterString>
                                            </gmd:individualName>
                                            <gmd:contactInfo>
                                                <gmd:CI_Contact>
                                                    <gmd:phone gco:nilReason="missing">888-888-8888</gmd:phone>
                                                </gmd:CI_Contact>
                                            </gmd:contactInfo>
                                            <gmd:role>
                                                <gmd:CI_RoleCode
                                                        codeList="http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/Codelist/gmxCodelists.xml#CI_RoleCode"
                                                        codeListValue="resourceProvider">resource provider
                                                </gmd:CI_RoleCode>
                                            </gmd:role>
                                        </gmd:CI_ResponsibleParty>
                                    </gmd:citedResponsibleParty>
                                </xsl:otherwise>
                            </xsl:choose>
                            <!-- (O-O) Resource Presentation Form - The form in which the service
                                       is available, which in the case of a service is only through the service
                                       implementation described by the metadata record, so the information here
                                       is not generally very useful. Note that the citation is to the original source
                                       of intellectual content in the described resource should be in MD_DataIdentification/citation/CI_Citation
                                       that describes the datasets operated on by the service. -->
                            <!-- <gmd:presentationForm gco:nilReason="not applicable"/> -->
                            <!-- (O-O) Resource series - Information about the series or collection
                                       of which the cited service is a part. NAP rule: (name + issueIdentification)
                                       > 0. At this point there is not much precedent for aggregating services into
                                       a formal series, so in general this element is probably not applicable to
                                       services. -->
                            <!-- <gmd:series/> -->
                            <!-- (O-O) Resource other citation details -->
                            <!-- <gmd:otherCitationDetails/> -->
                            <!-- (O-C) Resource collective title - At this point there is not
                                       much precedent for aggregating services into a collections, so in general
                                       this element is probably not applicable to services. -->
                            <!-- <gmd:collectiveTitle/> -->
                        </gmd:CI_Citation>
                    </gmd:citation>
                    <!-- (M-M) Resource Abstract - A free text summary of the content, significance,
                             purpose, scope, etc. of the resource. Exactly one value. -->
                    <gmd:abstract>
                        <xsl:choose>
                            <xsl:when test="string-length(//Abstract | //wms:Abstract)>0">
                                <gco:CharacterString>
                                    <xsl:value-of select="//Abstract | //wms:Abstract"/>
                                </gco:CharacterString>
                            </xsl:when>

                            <xsl:otherwise>
                                <gco:CharacterString>OGC WMS service, this metadata harvested from service capabilities.
                                    No abstract provided by service.
                                </gco:CharacterString>
                            </xsl:otherwise>
                        </xsl:choose>
                    </gmd:abstract>
                    <!-- (O-O) Resource purpose - Summary of the intentions for which the
                             service was developed, including objectives for creating the service and
                             use cases it is designed to support. -->
                    <!-- <gmd:purpose> <gco:CharacterString>This service delivers georeferenced
                             map images in a variety of formats for a requested bounding box. Details
                             not provided in OGC capabilties.</gco:CharacterString> </gmd:purpose> -->
                    <!-- (M-M) Resource Status - progress code required, assume if service
                             is online it is completed.... -->
                    <gmd:status>
                        <!-- MD_ProgressCode names: {completed, historicalArchive, obsolete,
                                  onGoing, planned, required, underDevelopment} - Obsolete is synonymous with
                                  deprecated. -->
                        <gmd:MD_ProgressCode
                                codeList="http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/Codelist/gmxCodelists.xml#MD_ProgressCode"
                                codeListValue="completed">completed
                        </gmd:MD_ProgressCode>
                    </gmd:status>
                    <!-- (O-C) Resource service point of contact (access contact) - CI_ResponsibleParty
                             element here would contain information for point of contact to access the
                             resource. OGC capabilities only provide one contact element, so this is used
                             for both the service identification Citation responsible party and the service
                             point of contact. -->
                    <gmd:pointOfContact>
                        <!-- CI_Responsible party has an id in order to allow reuse of this
                                  element later in the document by an internal href; see distributionInfo/../distributor
                                  near end of document -->
                        <xsl:choose>
                            <xsl:when test="//wms:ContactInformation | //ContactInformation">
                                <gmd:CI_ResponsibleParty id="R264537">
                                    <!-- (M-M) (individualName + organisationName + positionName) >
                                                     0 -->
                                    <gmd:individualName>
                                        <gco:CharacterString>
                                            <xsl:choose>
                                                <xsl:when
                                                        test="string-length(//wms:ContactPerson | //ContactPerson) > 0">
                                                    <xsl:value-of select="//wms:ContactPerson | //ContactPerson"/>
                                                </xsl:when>
                                                <xsl:otherwise>
                                                    <xsl:value-of select="'missing'"/>
                                                </xsl:otherwise>
                                            </xsl:choose>
                                        </gco:CharacterString>
                                    </gmd:individualName>
                                    <xsl:if test="//wms:ContactOrganization | //ContactOrganization">
                                        <gmd:organisationName>
                                            <gco:CharacterString>
                                                <xsl:value-of
                                                        select="//wms:ContactOrganization | //ContactOrganization"/>
                                            </gco:CharacterString>
                                        </gmd:organisationName>
                                    </xsl:if>
                                    <xsl:if test="//wms:ContactPosition | //ContactPosition">
                                        <gmd:positionName>
                                            <gco:CharacterString>
                                                <xsl:value-of select="//wms:ContactPosition | //ContactPosition"/>
                                            </gco:CharacterString>
                                        </gmd:positionName>
                                    </xsl:if>
                                    <!-- (O-C) Contact Information - (phone + deliveryPoint + electronicMailAddress
                                                     ) > 0. Best practice is to include at least an e-mail address -->
                                    <gmd:contactInfo>
                                        <gmd:CI_Contact>
                                            <xsl:if
                                                    test="//wms:ContactVoiceTelephone | ContactVoiceTelephone | wms:ContactFacsimileTelephone |
												ContactFacsimileTelephone">
                                                <gmd:phone>
                                                    <gmd:CI_Telephone>
                                                        <xsl:if
                                                                test="//wms:ContactVoiceTelephone | //ContactVoiceTelephone">
                                                            <gmd:voice>
                                                                <gco:CharacterString>
                                                                    <xsl:value-of
                                                                            select="//wms:ContactVoiceTelephone | //ContactVoiceTelephone"/>
                                                                </gco:CharacterString>
                                                            </gmd:voice>
                                                        </xsl:if>
                                                        <xsl:if
                                                                test="//wms:ContactFacsimileTelephone | //ContactFacsimileTelephone">
                                                            <gmd:facsimile>
                                                                <gco:CharacterString>
                                                                    <xsl:value-of
                                                                            select="//wms:ContactFacsimileTelephone | //ContactFacsimileTelephone"/>
                                                                </gco:CharacterString>
                                                            </gmd:facsimile>
                                                        </xsl:if>
                                                    </gmd:CI_Telephone>
                                                </gmd:phone>
                                            </xsl:if>
                                            <!-- *******************resource contact address*************** -->
                                            <!-- address element must be present, if an e-mail address is
                                                               included -->
                                            <xsl:if
                                                    test="//wms:ContactAddress | //ContactAddress | //wms:ContactElectronicMailAddress | //ContactElectronicMailAddress">
                                                <gmd:address>
                                                    <gmd:CI_Address>
                                                        <xsl:if
                                                                test="//wms:ContactAddress/Address | //ContactAddress/Address">
                                                            <gmd:deliveryPoint>
                                                                <gco:CharacterString>
                                                                    <xsl:value-of
                                                                            select="//wms:ContactAddress/Address | //ContactAddress/Address"/>
                                                                </gco:CharacterString>
                                                            </gmd:deliveryPoint>
                                                        </xsl:if>
                                                        <xsl:if
                                                                test="//wms:ContactAddress/City | //ContactAddress/City">
                                                            <gmd:city>
                                                                <gco:CharacterString>
                                                                    <xsl:value-of
                                                                            select="//wms:ContactAddress/City | //ContactAddress/City"/>
                                                                </gco:CharacterString>
                                                            </gmd:city>
                                                        </xsl:if>
                                                        <xsl:if
                                                                test="//wms:ContactAddress/StateOrProvince | //ContactAddress/StateOrProvince">
                                                            <gmd:administrativeArea>
                                                                <gco:CharacterString>
                                                                    <xsl:value-of
                                                                            select="//wms:ContactAddress/StateOrProvince | //ContactAddress/StateOrProvince"/>
                                                                </gco:CharacterString>
                                                            </gmd:administrativeArea>
                                                        </xsl:if>
                                                        <xsl:if
                                                                test="//wms:ContactAddress/PostCode | //ContactAddress/PostCode">
                                                            <gmd:postalCode>
                                                                <gco:CharacterString>
                                                                    <xsl:value-of
                                                                            select="//wms:ContactAddress/PostCode | //ContactAddress/PostCode"/>
                                                                </gco:CharacterString>
                                                            </gmd:postalCode>
                                                        </xsl:if>
                                                        <xsl:if
                                                                test="//wms:ContactAddress/Country | //ContactAddress/Country">
                                                            <gmd:country>
                                                                <gco:CharacterString>
                                                                    <xsl:value-of
                                                                            select="//wms:ContactAddress/Country | //ContactAddress/Country"/>
                                                                </gco:CharacterString>
                                                            </gmd:country>
                                                        </xsl:if>
                                                        <gmd:electronicMailAddress>
                                                            <xsl:choose>
                                                                <xsl:when
                                                                        test="//wms:ContactElectronicMailAddress | //ContactElectronicMailAddress">
                                                                    <gco:CharacterString>
                                                                        <xsl:value-of
                                                                                select="//wms:ContactElectronicMailAddress | //ContactElectronicMailAddress"/>
                                                                    </gco:CharacterString>
                                                                </xsl:when>
                                                                <xsl:otherwise>
                                                                    <!-- at least an e-mail address is required -->
                                                                    <gco:CharacterString>metadata@usgin.org
                                                                    </gco:CharacterString>
                                                                </xsl:otherwise>
                                                            </xsl:choose>
                                                        </gmd:electronicMailAddress>
                                                    </gmd:CI_Address>
                                                </gmd:address>
                                            </xsl:if>
                                            <!-- test if have e-mail -->
                                        </gmd:CI_Contact>
                                    </gmd:contactInfo>
                                    <!-- (M-M) ISO 19139 Mandatory: contact role - Guidance on use
                                                     of role codes would be helpful for consistency, but has not been developed
                                                     as yet. -->
                                    <gmd:role>
                                        <!-- CI_RoleCode names: {resourceProvider, custodian, owner, user,
                                                          distributor, originator, pointOfContact, principalInvestigator, processor,
                                                          publisher, author} - NAP expands with {collaborator, editor, mediator, rightsHolder}. -->
                                        <gmd:CI_RoleCode
                                                codeList="http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/Codelist/gmxCodelists.xml#CI_RoleCode"
                                                codeListValue="resourceProvider">resource provider
                                        </gmd:CI_RoleCode>
                                    </gmd:role>
                                </gmd:CI_ResponsibleParty>
                            </xsl:when>
                            <xsl:otherwise>  <!-- these are required for conformance with USGIN profile -->
                                <gmd:CI_ResponsibleParty>
                                    <gmd:individualName gco:nilReason="missing">
                                        <gco:CharacterString>not reported</gco:CharacterString>
                                    </gmd:individualName>
                                    <gmd:contactInfo>
                                        <gmd:CI_Contact>
                                            <gmd:phone gco:nilReason="missing">888-888-8888</gmd:phone>
                                        </gmd:CI_Contact>
                                    </gmd:contactInfo>
                                    <gmd:role>
                                        <gmd:CI_RoleCode
                                                codeList="http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/Codelist/gmxCodelists.xml#CI_RoleCode"
                                                codeListValue="resourceProvider">resource provider
                                        </gmd:CI_RoleCode>
                                    </gmd:role>
                                </gmd:CI_ResponsibleParty>
                            </xsl:otherwise>
                        </xsl:choose>

                    </gmd:pointOfContact>
                    <!-- (O-O) Resource Maintenance - This element provides information
                             about the maintenance schedule or history of the service described by the
                             metadata record. For a service, only one MD_MaintenanceInformation elements
                             may be included; for which the MD_ScopeDescription will be ‘service’. If
                             MD_MaintenanceInformation is present, then maintenanceAndUpdateFrequency
                             is mandatory. -->
                    <!-- <gmd:resourceMaintenance/> -->

                    <!-- (O-O) Graphic overview of resource - Highly recommended to include
                             a small image visual representation of the resource provided by a map or
                             image service. For geographic feature or data services, a graphic overview
                             might show the geographic distribution of available data. If MD_BrowseGraphic
                             is included, MD_BrowseGraphic/filename character string is mandatory. USGIN
                             Recommended practice is to provide a complete URL as a gco:characterString
                             value for the filename property. -->
                    <!-- <gmd:graphicOverview/> -->
                    <!-- (O-X) Resource Format - This element is not used by USGIN; this
                             information is encoded in MD_Metadata/distributionInfo/MD_Distribution/ in
                             USGIN metadata. -->
                    <!-- <gmd:resourceFormat> -->
                    <!-- (O-O) Resource keywords - Best Practice for USGIN profile metadata
                             is to supply keywords to facilitate the discovery of metadata records relevant
                             to the user. USGIN requires that MD_Keyword/keyword contain a CharacterString.
                             USGIN best practice is to include keywords in English -->
                    <!-- Theme keywords -->
                    <gmd:descriptiveKeywords>
                        <gmd:MD_Keywords>
                            <gmd:keyword>
                                <gco:CharacterString>WMS</gco:CharacterString>
                            </gmd:keyword>

                            <xsl:for-each select="tokenize(//Keywords, '\s+')">
                                <gmd:keyword>
                                    <gco:CharacterString>
                                        <xsl:value-of select="."/>
                                    </gco:CharacterString>
                                </gmd:keyword>
                            </xsl:for-each>
                            <xsl:for-each select="//wms:Keyword | //Keyword">
                                <gmd:keyword>
                                    <gco:CharacterString>
                                        <xsl:value-of select="."/>
                                    </gco:CharacterString>
                                </gmd:keyword>
                            </xsl:for-each>
                            <!-- Keyword Type - allowed values from MD_KeywordTypeCode names:
                                       {discipline, place, stratum, temporal, theme} -->
                            <!-- Of course OGC capabilities don't provide a keyword type category,
                                       so just use 'theme' as a default value -->
                            <gmd:type>
                                <gmd:MD_KeywordTypeCode
                                        codeList="http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/Codelist/gmxCodelists.xml#MD_KeywordTypeCode"
                                        codeListValue="theme">theme
                                </gmd:MD_KeywordTypeCode>
                            </gmd:type>
                            <!-- although OGC capabilities allow a vocabulary attribute that broadly
                                       corresponds to a Thesaurus name, its too much of a pain to fool around -->
                            <!-- extracting, especially since I don't see it used very often -->
                        </gmd:MD_Keywords>
                    </gmd:descriptiveKeywords>

                    <!-- (O-X) Resource specific usage - Property not USED by USGIN. -->
                    <!-- <gmd:resourceSpecificUsage/> -->
                    <!-- -->
                    <!-- (O-O) Condition applying to access and use of resource - Restrictions
                             on the access and use of a service. Follow NAP for specification of resourceConstraints.
                             This attribute provides information for access control to the described service.
                             In some situations, the metadataConstraints may allow a user to learn of
                             the existence of a resource that they may not actually be able to access
                             without further clearance. Follow NAP for specification of resourceConstraints. -->
                    <!-- <xsl:when test="//wms:AccessConstraints | //AccessConstraints"> -->
                    <xsl:if test="//wms:AccessConstraints | //AccessConstraints">
                        <gmd:resourceConstraints>
                            <gmd:MD_Constraints>
                                <gmd:useLimitation>
                                    <gco:CharacterString>
                                        <xsl:value-of select="//wms:AccessConstraints | //AccessConstraints"/>
                                    </gco:CharacterString>
                                </gmd:useLimitation>

                            </gmd:MD_Constraints>
                        </gmd:resourceConstraints>
                    </xsl:if>
                    <!-- (O-X) Aggregation information - For USGIN profile, this property,
                             rather than MD_Metadata/parentIdentifier, should be used to indicate relationships
                             between described resources. This might be the best place to put links to
                             dataset metadata for data offered by the service, but there is no binding
                             between layers and the offered data... -->
                    <!-- <gmd:aggregationInfo/> -->
                    <!-- -->
                    <!-- (M-M) Service type - Choose a service type name from a registry
                             of services. USGIN mandates use of a LocalName value from the service type
                             listing in the ServiceType section of the USGIN ISO19139 profile document,
                             with the codespace http://resources.usgin.org/uri-gin/usgin/vocabulary/serviceType -->
                    <srv:serviceType>
                        <!-- Valid values for OGC services would be then {<WMS, WFS, WVS, CSW,
                                  …} -->
                        <gco:LocalName
                                codeSpace="http://resources.usgin.org/uri-gin/usgin/vocabulary/serviceType">WMS
                        </gco:LocalName>
                    </srv:serviceType>
                    <!-- (O-C) Resource service type version - Multiple serviceTypeVersion
                             tags may not be implemented in applications. USGIN recommends a reverse chronological
                             order for supported versions. Constraint: if various versions are available,
                             mandatory to list versions that are supported. Default is oldest version
                             of service. -->
                    <srv:serviceTypeVersion>
                        <gco:CharacterString>1.3.0</gco:CharacterString>
                    </srv:serviceTypeVersion>
                    <srv:serviceTypeVersion>
                        <gco:CharacterString>1.1.3</gco:CharacterString>
                    </srv:serviceTypeVersion>
                    <srv:serviceTypeVersion>
                        <gco:CharacterString>1.1.1</gco:CharacterString>
                    </srv:serviceTypeVersion>
                    <!-- (O-O) Resource service access properties - Information on the availability
                             of the service which includes attributes from Standard Order Process. Applicable
                             sub elements for service are: fees, and available date and time. -->
                    <!-- <srv:accessProperties/> -->
                    <!-- (O-X) Resource service restrictions - Not used by USGIN; use resourceConstraints
                             as per NAP. -->
                    <!-- <srv:restrictions/> -->
                    <!-- (O-X) Keywords - Not used by USGIN; use descriptiveKeywords as
                             per NAP -->
                    <!-- <srv:keywords/> -->
                    <!-- (C-C) Service Extent - Defines the spatial (horizontal and vertical)
                             and temporal region to which the content of the resource applies. For USGIN,
                             the spatial extent is a rectangle that bounds the geographic extent to which
                             resource content applies. Best Practice for USGIN is to include an extent
                             for any resource with content related to some geographic or temporal location.
                             For geoscience resources, the temporal extent may be expressed using time
                             ordinal eras from a geologic time scale if the resource is related to some
                             particular geologic time. USGIN specifies count(description + geographicElement
                             + temporalElement) >0 -->
                    <srv:extent>
                        <gmd:EX_Extent>
                            <gmd:geographicElement>
                                <xsl:choose>
                                    <xsl:when
                                            test="//wms:LatLonBoundingBox |
									  //LatLonBoundingBox |
									  //LatLonBoundingBox | 	
									  //wms:BoundingBox[@CRS='EPSG:4326']
									  ">
                                        <xsl:call-template name="WMS_BoundingBox"/>
                                    </xsl:when>
                                    <xsl:when test="//wms:EX_GeographicBoundingBox">
                                        <xsl:call-template name="WMS_EX_GeographicBoundingBox"/>
                                    </xsl:when>
                                    <xsl:when
                                            test=" //ows:LowerCorner | //ows11:LowerCorner | //gml:LowerCorner | //gml:pos[1] | //gml:coord[1] | //gml:lowerCorner | //gml:Envelope[@srsName='EPSG:4326'] ">
                                        <xsl:call-template name="OWS_WGS84BoundingBox"/>
                                    </xsl:when>
                                </xsl:choose>
                            </gmd:geographicElement>
                        </gmd:EX_Extent>
                    </srv:extent>
                    <!-- (M-M) Service coupling type - Type of coupling between service
                             and associated data (if exists) - "Qualitative information on the tightness
                             with which the service and the associated data are coupled." NAP. -->
                    <!-- According to ISO: -->
                    <!-- 1) loose - service instance is loosely coupled with a data instance,
                             i.e. no MD_DataIdentification class has to be described (ISO 19119). -->
                    <!-- 2) mixed - service instance is mixed coupled with a data instance,
                             i.e. MD_DataIdentification describes the associated data instance and additionally
                             the service instance might work with other external data instances (ISO 19119
                             / ISO 19115). -->
                    <!-- 3) tight - service instance is tightly coupled with a data instance,
                             i.e. MD_DataIdentification class MUST be described. (ISO 19119 / ISO 19115) -->
                    <!-- According to OGC: -->
                    <!-- 1) loose - A service instance that is not associated with a specific
                             dataset or dataset collection. Loosely coupled services may have an association
                             with data types through the service type definition. Dataset metadata need
                             not be provided in the service metadata. -->
                    <!-- 2) mixed - A service that is associated with a specific dataset
                             or dataset collection. Service metadata shall describe both the service and
                             the geographic dataset, the latter being defined in accordance with ISO 19115.
                             But this service instance can also be used with external data (i.e. data
                             that is not described by the operatesOn association). -->
                    <!-- 3) tight - An information resource that is hosted on a specific
                             set of hardware and accessible over a network. -->
                    <srv:couplingType>
                        <!-- SV_CouplingType names: {loose, mixed, tight} -->
                        <!-- NAP Example -->
                        <!-- <srv:SV_CouplingType codeList="http://www.fgdc.gov/nap/metadata/register/codelists.html#IC_114"
                                  codeListValue="RI_685">tight</srv:SV_CouplingType> -->
                        <!-- ISO Example -->
                        <srv:SV_CouplingType
                                codeList="http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/Codelist/gmxCodelists.xml#SV_CouplingType"
                                codeListValue="tight">tight
                        </srv:SV_CouplingType>
                    </srv:couplingType>
                    <!--*** -->
                    <!-- (M-M) Service operation - "Operations performed by the service"
                             NAP. Each SV_OperationMetadata element describes the signature of one and
                             only one method provided by the service. Not used by USGIN, populate with
                             gco:nilReason = ’Missing' -->
                    <!-- See WMS GetCapabilities for operation metadata -->
                    <srv:containsOperations>
                        <srv:SV_OperationMetadata>
                            <srv:operationName>
                                <gco:CharacterString>GetCapabilities</gco:CharacterString>
                            </srv:operationName>
                            <srv:DCP>
                                <srv:DCPList codeList="#DCPList" codeListValue="WebServices">WebServices</srv:DCPList>
                            </srv:DCP>
                            <!-- should be called only on nonempty WMS 1.0.0 -->
                            <xsl:apply-templates select="//Service/OnlineResource" mode="connectPoint"/>
                            <!-- should be called only on other WMS -->
                            <xsl:apply-templates
                                    select="//wms:Service/wms:OnlineResource/@xlink:href | //Service/OnlineResource/@xlink:href"
                                    mode="connectPoint"/>
                        </srv:SV_OperationMetadata>
                        <xsl:apply-templates select="//wms:Capability/wms:Request | //Capability/Request"
                                             mode="connectPoint"/>
                    </srv:containsOperations>
                </srv:SV_ServiceIdentification>
            </gmd:identificationInfo>
            <!--******************* -->
            <!-- (O-O) Content information - Characteristics describing the feature
                   cataloguecatalog, coverage, or image data. USGIN currently makes no recommendation
                   for use of contentInfo; follow NAP recommendations (see INCITS 453). -->
            <!-- <gmd:contentInfo gco:nilReason="missing"/> -->
            <!-- (O-O) Resource distribution information - This element provides information
                   to inform users how to obtain or access the described resource. For service
                   metadata, the only distribution is the interface offered by the described
                   service. The distributionFormat is nil because the format depends on the
                   operation and request. TransferOptions is used to provide the URL’s for accessing
                   the service and a serviceDescription resource (WSDL, getCapabilities, web
                   page..). Distributor is used to identify the agent that is responsible for
                   hosting the service. -->
            <gmd:distributionInfo>
                <gmd:MD_Distribution>
                    <gmd:distributor>
                        <gmd:MD_Distributor>
                            <gmd:distributorContact xlink:href="#R264537"/>
                        </gmd:MD_Distributor>
                    </gmd:distributor>
                    <!-- (C-C) Resource distribution transfer options - MD_DigitalTransferOptions
                             provides information on digital distribution of resource. See USGIN Profile
                             ‘Use of MD_Distribution and MD_Distributor’ for instructions on use of this
                             element. Details on encoding for MD_DigitalTransferOptions are above in the
                             distributorTransferOptions elements description. -->
                    <gmd:transferOptions>
                        <gmd:MD_DigitalTransferOptions>
                            <!-- Two online elements are included, one for the serviceDescription
                                       and one for the baseURL, which in this case is the full URL for the OGC getCapabilities
                                       document -->
                            <gmd:onLine>
                                <gmd:CI_OnlineResource>
                                    <gmd:linkage>
                                        <gmd:URL>
                                            <!-- should be called only on nonempty WMS 1.0.0 -->
                                            <xsl:apply-templates select="//Service/OnlineResource"
                                                                 mode="transferOptions"/>
                                            <!-- should be called only on other WMS -->
                                            <xsl:apply-templates
                                                    select="//wms:Service/wms:OnlineResource/@xlink:href | //Service/OnlineResource/@xlink:href"
                                                    mode="transferOptions"/>
                                        </gmd:URL>
                                    </gmd:linkage>
                                    <!-- The protocol element defines a valid internet protocol used
                                                 to access the resource. NAP recommended best practice is that the protocol
                                                 should be taken from an official controlled list such as the Official Internet
                                                 Protocol Standards published on the Web at http://www.rfc-editor.org/rfcxx00.html
                                                 or the Internet Assigned Numbers Authority (IANA) at http://www.iana.org/numbers.html.
                                                 ‘ftp’ or ‘http’ are common values. -->
                                    <gmd:name>
                                        <gco:CharacterString>GetCapabilities</gco:CharacterString>
                                    </gmd:name>
                                    <!-- Service Description -->
                                </gmd:CI_OnlineResource>
                            </gmd:onLine>
                        </gmd:MD_DigitalTransferOptions>
                    </gmd:transferOptions>
                    <xsl:apply-templates select="//wms:Capability/wms:Request | //Capability/Request"
                                         mode="transferOptions"/>
                </gmd:MD_Distribution>
            </gmd:distributionInfo>
            <gmd:dataQualityInfo>
                <gmd:DQ_DataQuality>
                    <gmd:scope>
                        <gmd:DQ_Scope>
                            <gmd:level>
                                <gmd:MD_ScopeCode
                                        codeList="http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/Codelist/gmxCodelists.xml#MD_ScopeCode"
                                        codeListValue="dataset">dataset
                                </gmd:MD_ScopeCode>
                            </gmd:level>
                        </gmd:DQ_Scope>
                    </gmd:scope>
                    <gmd:lineage>
                        <gmd:LI_Lineage>
                            <gmd:statement>
                                <gco:CharacterString>
                                    <xsl:value-of
                                            select="concat('This metadata record harvested from ', $sourceUrl, '. and transformed to USGIN ISO19139 profile using ogcWMS-toUSGIN_ISO19139.xslt version 1.0')"/>
                                </gco:CharacterString>
                            </gmd:statement>
                        </gmd:LI_Lineage>
                    </gmd:lineage>
                </gmd:DQ_DataQuality>
            </gmd:dataQualityInfo>
        </gmd:MD_Metadata>
    </xsl:template>

    <!-- OWS Bounding Box -->
    <xsl:template name="OWS_WGS84BoundingBox">
        <EX_GeographicBoundingBox
                xsl:exclude-result-prefixes="wms wps100 swe myorg tml sml sps sos10 wfs wcs wcs11 wcs111 csw csw202 gml">
            <westBoundLongitude>
                <gco:Decimal>
                    <xsl:call-template name="getLCMinx"/>
                </gco:Decimal>
            </westBoundLongitude>
            <southBoundLatitude>
                <gco:Decimal>
                    <xsl:call-template name="getLCMiny"/>
                </gco:Decimal>
            </southBoundLatitude>
            <eastBoundLongitude>
                <gco:Decimal>
                    <xsl:call-template name="getUCMaxx"/>
                </gco:Decimal>
            </eastBoundLongitude>
            <northBoundLatitude>
                <gco:Decimal>
                    <xsl:call-template name="getUCMaxy"/>
                </gco:Decimal>
            </northBoundLatitude>
        </EX_GeographicBoundingBox>
    </xsl:template>
    <xsl:template name="getLCMinx">
        <xsl:for-each
                select="//ows:LowerCorner | //ows11:LowerCorner | //gml:LowerCorner | //gml:pos[1] | //gml:coord[1] | //gml:lowerCorner">
            <xsl:sort
                    select="number(normalize-space(substring-before(normalize-space(.),' ')))"
                    data-type="number" order="ascending"/>
            <xsl:if test="position() = 1">
                <xsl:value-of
                        select="number(normalize-space(substring-before(normalize-space(.),' ')))"/>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
    <xsl:template name="getLCMiny">
        <xsl:for-each
                select="//ows:LowerCorner | //ows11:LowerCorner | //gml:LowerCorner | //gml:pos[1] | //gml:coord[1] | //gml:lowerCorner">
            <xsl:sort select="substring-after(.,' ') " data-type="number"
                      order="ascending"/>
            <xsl:if test="position() = 1">
                <xsl:value-of select="substring-after(.,' ') "/>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
    <xsl:template name="getUCMaxx">
        <xsl:for-each
                select="//ows:UpperCorner | //ows11:UpperCorner | //gml:UpperCorner | //gml:pos[2] | //gml:coord[2] | //gml:upperCorner">
            <xsl:sort select="substring-before(. ,' ')" data-type="number"
                      order="descending"/>
            <xsl:if test="position() = 1">
                <xsl:value-of select="substring-before( . ,' ')"/>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
    <xsl:template name="getUCMaxy">
        <xsl:for-each
                select="//ows:UpperCorner | //ows11:UpperCorner | //gml:UpperCorner | //gml:pos[2] | //gml:coord[2] | //gml:upperCorner">
            <xsl:sort select="substring-after( . ,' ') " data-type="number"
                      order="descending"/>
            <xsl:if test="position() = 1">
                <xsl:value-of select="substring-after( . ,' ') "/>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
    <!-- WMS Bounding Box -->
    <xsl:template name="WMS_SummaryBoundingBox">
        <xsl:param name="box"/>
        <EX_GeographicBoundingBox
                xsl:exclude-result-prefixes="wps100 swe myorg tml sml sps sos10 wfs wcs wcs11 wcs111 csw csw202 gml">
            <westBoundLongitude>
                <gco:Decimal>
                    <xsl:value-of select="$box/@minx"/>
                </gco:Decimal>
            </westBoundLongitude>
            <southBoundLatitude>
                <gco:Decimal>
                    <xsl:value-of select="$box/@miny"/>
                </gco:Decimal>
            </southBoundLatitude>
            <eastBoundLongitude>
                <gco:Decimal>
                    <xsl:value-of select="$box/@maxx"/>
                </gco:Decimal>
            </eastBoundLongitude>
            <northBoundLatitude>
                <gco:Decimal>
                    <xsl:value-of select="$box/@maxy"/>
                </gco:Decimal>
            </northBoundLatitude>
        </EX_GeographicBoundingBox>
    </xsl:template>
    <xsl:template name="WMS_BoundingBox">
        <gmd:EX_GeographicBoundingBox
                xsl:exclude-result-prefixes="wps100 swe myorg tml sml sps sos10 wfs wcs wcs11 wcs111 csw csw202 gml">
            <gmd:westBoundLongitude>
                <gco:Decimal>
                    <xsl:call-template name="getMinx"/>
                </gco:Decimal>
            </gmd:westBoundLongitude>
            <gmd:eastBoundLongitude>
                <gco:Decimal>
                    <xsl:call-template name="getMaxx"/>
                </gco:Decimal>
            </gmd:eastBoundLongitude>
            <gmd:southBoundLatitude>
                <gco:Decimal>
                    <xsl:call-template name="getMiny"/>
                </gco:Decimal>
            </gmd:southBoundLatitude>
            <gmd:northBoundLatitude>
                <gco:Decimal>
                    <xsl:call-template name="getMaxy"/>
                </gco:Decimal>
            </gmd:northBoundLatitude>
        </gmd:EX_GeographicBoundingBox>
    </xsl:template>
    <xsl:template name="WMS_EX_GeographicBoundingBox">
        <gmd:EX_GeographicBoundingBox
                xsl:exclude-result-prefixes="wps100 swe myorg tml sml sps sos10 wfs wcs wcs11 wcs111 csw csw202 gml">
            <gmd:westBoundLongitude>
                <gco:Decimal>
                    <xsl:call-template name="getWestBound"/>
                </gco:Decimal>
            </gmd:westBoundLongitude>
            <gmd:eastBoundLongitude>
                <gco:Decimal>
                    <xsl:call-template name="getEastBound"/>
                </gco:Decimal>
            </gmd:eastBoundLongitude>
            <gmd:southBoundLatitude>
                <gco:Decimal>
                    <xsl:call-template name="getSouthBound"/>
                </gco:Decimal>
            </gmd:southBoundLatitude>
            <gmd:northBoundLatitude>
                <gco:Decimal>
                    <xsl:call-template name="getNorthBound"/>
                </gco:Decimal>
            </gmd:northBoundLatitude>
        </gmd:EX_GeographicBoundingBox>
    </xsl:template>
    <xsl:template name="getMinx">
        <xsl:for-each
                select="//wms:LatLonBoundingBox |
									  //LatLonBoundingBox |
									  //LatLonBoundingBox | 	
									  //wms:BoundingBox[@CRS='EPSG:4326']">
            <xsl:sort select="./@minx" data-type="number" order="ascending"/>
            <xsl:if test="position() = 1">
                <xsl:value-of select="./@minx"/>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
    <xsl:template name="getMiny">
        <xsl:for-each
                select="//wms:LatLonBoundingBox |
									  //LatLonBoundingBox |
									  //LatLonBoundingBox | 	
									  //wms:BoundingBox[@CRS='EPSG:4326']">
            <xsl:sort select="./@miny" data-type="number" order="ascending"/>
            <xsl:if test="position() = 1">
                <xsl:value-of select="./@miny"/>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
    <xsl:template name="getMaxy">
        <xsl:for-each
                select="//wms:LatLonBoundingBox |
									  //LatLonBoundingBox |
									  //LatLonBoundingBox | 	
									  //wms:BoundingBox[@CRS='EPSG:4326']">
            <xsl:sort select="./@maxy" data-type="number" order="descending"/>
            <xsl:if test="position() = 1">
                <xsl:value-of select="./@maxy"/>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
    <xsl:template name="getMaxx">
        <xsl:for-each
                select="//wms:LatLonBoundingBox |
									  //LatLonBoundingBox |
									  //LatLonBoundingBox | 	
									  //wms:BoundingBox[@CRS='EPSG:4326']">
            <xsl:sort select="./@maxx" data-type="number" order="descending"/>
            <xsl:if test="position() = 1">
                <xsl:value-of select="./@maxx"/>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
    <xsl:template name="getWestBound">
        <xsl:for-each select="//wms:westBoundLongitude">
            <xsl:sort select="." data-type="number" order="ascending"/>
            <xsl:if test="position() = 1">
                <xsl:value-of select="."/>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
    <xsl:template name="getSouthBound">
        <xsl:for-each select="//wms:southBoundLatitude">
            <xsl:sort select="." data-type="number" order="ascending"/>
            <xsl:if test="position() = 1">
                <xsl:value-of select="."/>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
    <xsl:template name="getNorthBound">
        <xsl:for-each select="//wms:northBoundLatitude">
            <xsl:sort select="." data-type="number" order="descending"/>
            <xsl:if test="position() = 1">
                <xsl:value-of select="."/>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
    <xsl:template name="getEastBound">
        <xsl:for-each select="//wms:eastBoundLongitude">
            <xsl:sort select="." data-type="number" order="descending"/>
            <xsl:if test="position() = 1">
                <xsl:value-of select="."/>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>

    <xsl:template match="//wms:Capability/wms:Request | //Capability/Request" mode="connectPoint">
        <!-- operation names are stored as element names and vary between wms versions -->
        <xsl:for-each select="child::*">
            <srv:SV_OperationMetadata
                    xsl:exclude-result-prefixes="ows ows11 wms wps100 swe myorg tml sml sps sos10 wfs wcs wcs11 wcs111 csw csw202 gml">
                <srv:operationName>
                    <gco:CharacterString>
                        <xsl:value-of select="local-name()"/>
                    </gco:CharacterString>
                </srv:operationName>
                <srv:DCP>
                    <srv:DCPList codeList="#DCPList" codeListValue="WebServices">WebServices</srv:DCPList>
                </srv:DCP>
                <xsl:apply-templates
                        select="wms:DCPType/wms:HTTP//wms:OnlineResource/@xlink:href | DCPType/HTTP//OnlineResource/@xlink:href | DCPType/HTTP//@onlineResource"
                        mode="connectPoint"/>
            </srv:SV_OperationMetadata>
        </xsl:for-each>
    </xsl:template>

    <xsl:template match="wms:DCPType/wms:HTTP//wms:OnlineResource/@xlink:href | DCPType/HTTP//OnlineResource/@xlink:href | DCPType/HTTP//@onlineResource
	| //wms:Service/wms:OnlineResource/@xlink:href | //Service/OnlineResource/@xlink:href" mode="connectPoint">
        <srv:connectPoint
                xsl:exclude-result-prefixes="ows ows11 wms wps100 swe myorg tml sml sps sos10 wfs wcs wcs11 wcs111 csw csw202 gml">
            <CI_OnlineResource>
                <linkage>
                    <URL>
                        <xsl:value-of select="."/>
                    </URL>
                </linkage>
            </CI_OnlineResource>
        </srv:connectPoint>
    </xsl:template>

    <!-- should be called only on nonempty string WMS 1.0.0 -->
    <xsl:template match="//Service/OnlineResource[normalize-space()]" mode="connectPoint">
        <srv:connectPoint
                xsl:exclude-result-prefixes="ows ows11 wms wps100 swe myorg tml sml sps sos10 wfs wcs wcs11 wcs111 csw csw202 gml">
            <CI_OnlineResource>
                <linkage>
                    <URL>
                        <xsl:value-of select="."/>
                    </URL>
                </linkage>
            </CI_OnlineResource>
        </srv:connectPoint>
    </xsl:template>

    <xsl:template match="//wms:Capability/wms:Request | //Capability/Request" mode="transferOptions">
        <!-- operation names are stored as element names and vary between wms versions -->
        <xsl:for-each select="child::*">
            <xsl:variable name="operationName">
                <xsl:value-of select="local-name()"/>
            </xsl:variable>
            <xsl:for-each
                    select="wms:DCPType/wms:HTTP//wms:OnlineResource/@xlink:href | DCPType/HTTP//OnlineResource/@xlink:href | DCPType/HTTP//@onlineResource">
                <gmd:transferOptions
                        xsl:exclude-result-prefixes="ows ows11 wms wps100 swe myorg tml sml sps sos10 wfs wcs wcs11 wcs111 csw csw202 gml">
                    <gmd:MD_DigitalTransferOptions>
                        <gmd:onLine>
                            <gmd:CI_OnlineResource>
                                <gmd:linkage>
                                    <gmd:URL>
                                        <xsl:value-of select="."/>
                                    </gmd:URL>
                                </gmd:linkage>
                                <gmd:name>
                                    <gco:CharacterString>
                                        <xsl:value-of select="$operationName"/>
                                    </gco:CharacterString>
                                </gmd:name>
                            </gmd:CI_OnlineResource>
                        </gmd:onLine>
                    </gmd:MD_DigitalTransferOptions>
                </gmd:transferOptions>
            </xsl:for-each>
        </xsl:for-each>
    </xsl:template>

    <!-- should be called only on nonempty string WMS 1.0.0 -->
    <xsl:template match="//Service/OnlineResource[normalize-space()]" mode="transferOptions">
        <xsl:value-of select="."/>
    </xsl:template>

    <xsl:template match="wms:DCPType/wms:HTTP//wms:OnlineResource/@xlink:href | DCPType/HTTP//OnlineResource/@xlink:href | DCPType/HTTP//@onlineResource
	| //wms:Service/wms:OnlineResource/@xlink:href | //Service/OnlineResource/@xlink:href" mode="transferOptions">
        <xsl:value-of select="."/>
    </xsl:template>

</xsl:stylesheet>
