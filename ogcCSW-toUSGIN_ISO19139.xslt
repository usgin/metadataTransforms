<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:fo="http://www.w3.org/1999/XSL/Format"
	xmlns:ows="http://www.opengis.net/ows" xmlns:ows11="http://www.opengis.net/ows/1.1"
	xmlns:gml="http://www.opengis.net/gml" xmlns:csw="http://www.opengis.net/cat/csw"
	xmlns:csw202="http://www.opengis.net/cat/csw/2.0.2" xmlns:wcs="http://www.opengis.net/wcs"
	xmlns:wcs11="http://www.opengis.net/wcs/1.1" xmlns:wcs111="http://www.opengis.net/wcs/1.1.1"
	xmlns:wfs="http://www.opengis.net/wfs" xmlns:gmd="http://www.isotc211.org/2005/gmd"
	xmlns:wms="http://www.opengis.net/wms" xmlns:wps100="http://www.opengis.net/wps/1.0.0"
	xmlns:sos10="http://www.opengis.net/sos/1.0" xmlns:sps="http://www.opengis.net/sps"
	xmlns:tml="http://www.opengis.net/tml" xmlns:sml="http://www.opengis.net/sensorML/1.0.1"
	xmlns:gco="http://www.isotc211.org/2005/gco" xmlns:myorg="http://www.myorg.org/features"
	xmlns:swe="http://www.opengis.net/swe/1.0.1" xmlns:exslt="http://exslt.org/common">
	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
	<xsl:param name="sourceUrl"/>
	<xsl:param name="serviceType"/>
	<xsl:param name="currentDate"/>
	<xsl:param name="generatedUUID"/>
	<!-- *********** -->
	<!-- This style sheet converts OGC CSW capabilities response document (versions 2.0.0, 2.0.1 or 2.0.2 to 
		ISO (19115(2006), 19119, 19139 metadata that conforms with the USGIN metadata profile.
		See http://lab.usgin.org/profiles/usgin-iso-metadata-profile (http://lab.usgin.org/node/235) -->
	<!-- Stephen M Richard, steve.richard@azgs.az.gov -->
	<!-- provided as-is, use at your own risk! -->
	<!-- this program based on ogc-toISO19139.xslt provided with ESRI geoportal software package
 and USGIN service metadata example xml document -->
	<!-- version 1.0 2010-12-27 -->
	<xsl:template match="/">
		<xsl:call-template name="main"/>
	</xsl:template>
	<xsl:template name="main">
		<!-- Core gmd based instance document -->
		<xsl:variable name="cDate">
			<xsl:choose>
				<xsl:when test="string-length($currentDate) = 0">
					<xsl:value-of select="concat('1900', '-', '01', '-', '01')"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$currentDate"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<gmd:MD_Metadata xmlns="http://www.isotc211.org/2005/gmd"
			xmlns:gmd="http://www.isotc211.org/2005/gmd"
			xmlns:srv="http://www.isotc211.org/2005/srv"
			xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
			xsi:schemaLocation="http://www.isotc211.org/2005/gmd http://schemas.opengis.net/iso/19139/20060504/gmd/gmd.xsd
	http://www.isotc211.org/2005/srv http://schemas.opengis.net/iso/19139/20060504/srv/srv.xsd"
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
					codeListValue="utf8">UTF-8</gmd:MD_CharacterSetCode>
			</gmd:characterSet>
			<!-- (M-M) Resource type - this is specific to WMS, so define as service -->
			<gmd:hierarchyLevel>
				<gmd:MD_ScopeCode
					codeList="http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/Codelist/gmxCodelists.xml#MD_ScopeCode"
					codeListValue="service">service</gmd:MD_ScopeCode>
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
						<gco:CharacterString>US Geoscience Information Network, Arizona Geological
							Survey</gco:CharacterString>
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
										<gco:CharacterString>416 W. Congress St., Suite
											100</gco:CharacterString>
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
										<gco:CharacterString>Arizona Geological Survey Web
											Site</gco:CharacterString>
									</gmd:description>
								</gmd:CI_OnlineResource>
							</gmd:onlineResource>
							<!-- (O-O) hours of service -->
							<gmd:hoursOfService>
								<gco:CharacterString>8 AM to 5 PM Mountain Standard time (no
									daylight savings)</gco:CharacterString>
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
						<gmd:CI_RoleCode
							codeList="http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/Codelist/gmxCodelists.xml#CI_RoleCode"
							codeListValue="pointOfContact">point of contact</gmd:CI_RoleCode>
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
						<gco:CharacterString>Arizona Geological Survey </gco:CharacterString>
					</gmd:organisationName>
					<gmd:contactInfo>
						<gmd:CI_Contact>
							<gmd:onlineResource>
								<gmd:CI_OnlineResource>
									<!-- Icon image file (e.g. tif, png, jpg) for the metadata originator. 
										This Icon will be displayed in search results to credit the metadata originator. -->
									<gmd:linkage>
										<gmd:URL>http://resources.usgin.org/uri-gin/usgin/organization/azgs/logo/50x50.png
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
							codeListValue="originator">originator</gmd:CI_RoleCode>
					</gmd:role>
				</gmd:CI_ResponsibleParty>
			</gmd:contact>
			<!-- (M-M) Metadata date stamp - USGIN profile requires use of dateStamp/gco:DateTime 
				(Note this contrasts with INSPIRE mandate to use dateStamp/gco:Date). This 
				is the date and time when the metadata record was created or updated (following 
				NAP). -->
			<gmd:dateStamp>
				<gco:DateTime>
					<xsl:value-of select="concat($cDate, 'T12:00:00')"/>
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
			<!-- none for CSW  -->
			<referenceSystemInfo>
				<MD_ReferenceSystem>
					<referenceSystemIdentifier>
						<RS_Identifier>
							<code>
								<gco:CharacterString>urn:ogc:def:nil:OGC:1.0:inapplicable</gco:CharacterString>
							</code>
							<codeSpace>
								<gco:CharacterString>urn:ogc:def:nil:OGC:1.0:inapplicable</gco:CharacterString>
							</codeSpace>
						</RS_Identifier>
					</referenceSystemIdentifier>
				</MD_ReferenceSystem>
			</referenceSystemInfo>
			<!--                                                                     -->
			<!--                                                                      -->
			<gmd:identificationInfo>
				<srv:SV_ServiceIdentification>
					<citation>
						<CI_Citation>
							<title>
								<xsl:choose>
									<xsl:when
										test="string-length(//ows:ServiceIdentification/ows:Title) > 0 or string-length(//ows11:ServiceIdentification/ows11:Title) > 0">
										<gco:CharacterString>
											<xsl:value-of
												select="
													//ows:ServiceIdentification/ows:Title |
													//ows11:ServiceIdentification/ows11:Title"
											/>
										</gco:CharacterString>
									</xsl:when>
									<xsl:otherwise>
										<gco:CharacterString>
											<xsl:value-of
												select="concat('CSW catalog service hosted at ', $sourceUrl)"
											/>
										</gco:CharacterString>
									</xsl:otherwise>
								</xsl:choose>
							</title>
							<date>
								<CI_Date>
									<date gco:nilReason="notApplicable">
										<gco:Date>
											<xsl:value-of select="$cDate"/>
										</gco:Date>
									</date>
									<dateType>
										<CI_DateTypeCode
											codeList="http://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#CI_DateTypeCode"
											codeListValue="publication"/>
									</dateType>
								</CI_Date>
							</date>
							<!-- (C-O) Unique resource identifier - For USGIN, because the Citation 
								is for the service, this identifier should be identical to MD_Metadata/dataSetURI, 
								and is therefore optional. For USGIN purposes, this element content value 
								is only an identifier for the citation; it is not a URL for accessing the 
								service -->
							<!-- <gmd:identifier/> -->
							<!-- (M-M) Resource responsible party - The citation attribute provides 
								information for citing the described service. -->
							<!--use to test if there is any contact information -->
							<xsl:variable name="hasContactInfo"
								select="//ows:ServiceContact//text()"/>
							<xsl:choose>
								<xsl:when test="//ows:ServiceProvider">
									<gmd:citedResponsibleParty>
										<gmd:CI_ResponsibleParty>
											<!-- (M-M) (individualName + organisationName + positionName) 
												> 0 -->
											<xsl:if test="string-length(//ows:IndividualName) > 0">
												<gmd:individualName>
												<gco:CharacterString>
												<xsl:value-of select="/ows:IndividuatlName"/>
												</gco:CharacterString>
												</gmd:individualName>
											</xsl:if>
											<!-- provider name is required if an ows:ServiceProvider element is included, but the element may be empty... -->
											<gmd:organisationName>
												<gco:CharacterString>
												<xsl:choose>
												<xsl:when
												test="string-length(//ows:ProviderName) > 0">
												<xsl:value-of select="//ows:ProviderName"/>
												</xsl:when>
												<xsl:otherwise>
												<xsl:value-of select="'Missing'"/>
												</xsl:otherwise>
												</xsl:choose>
												</gco:CharacterString>
											</gmd:organisationName>
											<xsl:if test="string-length(//ows:PositionName) > 0">
												<gmd:positionName>
												<gco:CharacterString>
												<xsl:value-of select="//ows:PositionName"/>
												</gco:CharacterString>
												</gmd:positionName>
											</xsl:if>
											<!-- (O-C) Contact Information - (phone + deliveryPoint + electronicMailAddress 
												) > 0. Best practice is to include at least an e-mail address -->
											<gmd:contactInfo>
												<gmd:CI_Contact>
												<xsl:if test="//ows:Phone//text()">
												<gmd:phone>
												<gmd:CI_Telephone>
												<xsl:if test="string-length(//ows:Voice) > 0">
												<gmd:voice>
												<gco:CharacterString>
												<xsl:value-of select="//ows:Voice"/>
												</gco:CharacterString>
												</gmd:voice>
												</xsl:if>
												<xsl:if test="string-length(//ows:Facsimile) > 0">
												<gmd:facsimile>
												<gco:CharacterString>
												<xsl:value-of select="//ows:Facsimile"/>
												</gco:CharacterString>
												</gmd:facsimile>
												</xsl:if>
												</gmd:CI_Telephone>
												</gmd:phone>
												</xsl:if>
												<!-- *******************resource contact address*************** -->
												<!-- include address element, so meet USGIN requirement at minimum with an e-mail address -->
												<gmd:address>
												<gmd:CI_Address>
												<xsl:if
												test="string-length(//ows:Address/ows:DeliveryPoint) > 0">
												<gmd:deliveryPoint>
												<gco:CharacterString>
												<xsl:value-of
												select="//ows:Address/ows:DeliveryPoint"/>
												</gco:CharacterString>
												</gmd:deliveryPoint>
												</xsl:if>
												<xsl:if
												test="string-length(//ows:Address/ows:City) > 0">
												<gmd:city>
												<gco:CharacterString>
												<xsl:value-of select="//ows:Address/ows:City"/>
												</gco:CharacterString>
												</gmd:city>
												</xsl:if>
												<xsl:if
												test="string-length(//ows:Address/ows:AdministrativeArea) > 0">
												<gmd:administrativeArea>
												<gco:CharacterString>
												<xsl:value-of
												select="//ows:Address/ows:AdministrativeArea"/>
												</gco:CharacterString>
												</gmd:administrativeArea>
												</xsl:if>
												<xsl:if
												test="string-length(//ows:Address/ows:PostalCode) > 0">
												<gmd:postalCode>
												<gco:CharacterString>
												<xsl:value-of
												select="//ows:Address/ows:PostalCode"/>
												</gco:CharacterString>
												</gmd:postalCode>
												</xsl:if>
												<xsl:if
												test="string-length(//ows:Address/ows:Country) > 0">
												<gmd:country>
												<gco:CharacterString>
												<xsl:value-of select="//ows:Address/ows:Country"/>
												</gco:CharacterString>
												</gmd:country>
												</xsl:if>
												<!-- test if have e-mail -->
												<gmd:electronicMailAddress>
												<xsl:choose>
												<xsl:when
												test="string-length(//ows:Address/ows:ElectronicMailAddress) > 0">
												<gco:CharacterString>
												<xsl:value-of
												select="//ows:Address/ows:ElectronicMailAddress"/>
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
												codeListValue="resourceProvider">resource
												provider</gmd:CI_RoleCode>
											</gmd:role>
										</gmd:CI_ResponsibleParty>
									</gmd:citedResponsibleParty>
								</xsl:when>
								<xsl:otherwise>
									<!-- these are required for conformance with USGIN profile -->
									<gmd:citedResponsibleParty gco:nilReason="missing">
										<gmd:CI_ResponsibleParty>
											<gmd:individualName gco:nilReason="missing">
												<gco:CharacterString>not
												reported</gco:CharacterString>
											</gmd:individualName>
											<gmd:contactInfo>
												<gmd:CI_Contact>
												<gmd:phone gco:nilReason="missing"/>
												<gmd:address>
												<gmd:CI_Address>
												<gmd:electronicMailAddress>
												<gco:CharacterString>metadata@usgin.org</gco:CharacterString>
												</gmd:electronicMailAddress>
												</gmd:CI_Address>
												</gmd:address>
												</gmd:CI_Contact>
											</gmd:contactInfo>
											<gmd:role>
												<gmd:CI_RoleCode
												codeList="http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/Codelist/gmxCodelists.xml#CI_RoleCode"
												codeListValue="resourceProvider">resource
												provider</gmd:CI_RoleCode>
											</gmd:role>
										</gmd:CI_ResponsibleParty>
									</gmd:citedResponsibleParty>
								</xsl:otherwise>
							</xsl:choose>
						</CI_Citation>
					</citation>
					<gmd:abstract>
						<xsl:choose>
							<xsl:when test="string-length(//ServiceIdentification/Abstract) > 0">
								<xsl:variable name="theAbstract"
									select="//ServiceIdentification/Abstract"/>
								<gco:CharacterString>
									<xsl:value-of
										select="concat($theAbstract, '. [This metadata was harvested from service GetCapabilities response by USGIN GeoPortal catalog.]')"
									/>
								</gco:CharacterString>
							</xsl:when>
							<xsl:otherwise>
								<gco:CharacterString>OGC CSW service, this metadata harvested from
									service capabilities. No abstract provided by service.
								</gco:CharacterString>
							</xsl:otherwise>
						</xsl:choose>
					</gmd:abstract>
					<!-- <gmd:status/> -->
					<gmd:status>
						<!-- MD_ProgressCode names: {completed, historicalArchive, obsolete, onGoing, planned, required, underDevelopment} - NAP expands with {proposed}. Obsolete is synonymous with deprecated. -->
						<gmd:MD_ProgressCode
							codeList="http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/Codelist/gmxCodelists.xml#MD_ProgressCode"
							codeListValue="onGoing">onGoing</gmd:MD_ProgressCode>
					</gmd:status>
					<!-- status not specified in CSW capabiltities; ideally would hame some knowledge about maintenance... -->
					<!-- (O-C) Resource service point of contact (access contact) - CI_ResponsibleParty 
						element here would contain information for point of contact to access the 
						resource. OGC capabilities only provide one contact element, so this is used 
						for both the service identification Citation responsible party and the service 
						point of contact. -->
					<xsl:choose>
						<xsl:when test="//ows:ServiceProvider">
							<gmd:pointOfContact>
								<gmd:CI_ResponsibleParty>
									<!-- (M-M) (individualName + organisationName + positionName) 
												> 0 -->

									<gmd:individualName>
										<gco:CharacterString>
											<xsl:choose>
												<xsl:when
												test="string-length(//ows:IndividualName) > 0">
												<xsl:value-of select="//ows:IndividualName"/>
												</xsl:when>
												<xsl:otherwise>urn:ogc:def:nil:OGC:1.0:missing</xsl:otherwise>
											</xsl:choose>
										</gco:CharacterString>
									</gmd:individualName>

									<!-- provider name is required if an ows:ServiceProvider element is included, but the element may be empty... -->
									<gmd:organisationName>
										<gco:CharacterString>
											<xsl:choose>
												<xsl:when
												test="string-length(//ows:ProviderName) > 0">
												<xsl:value-of select="//ows:ProviderName"/>
												</xsl:when>
												<xsl:otherwise>
												<xsl:value-of select="'missing'"/>
												</xsl:otherwise>
											</xsl:choose>
										</gco:CharacterString>
									</gmd:organisationName>
									<xsl:if test="string-length(//ows:PositionName) > 0">
										<gmd:positionName>
											<gco:CharacterString>
												<xsl:value-of select="//ows:PositionName"/>
											</gco:CharacterString>
										</gmd:positionName>
									</xsl:if>
									<!-- (O-C) Contact Information - (phone + deliveryPoint + electronicMailAddress 
												) > 0. Best practice is to include at least an e-mail address -->
									<gmd:contactInfo>
										<gmd:CI_Contact>
											<xsl:if test="//ows:Phone//text()">
												<gmd:phone>
												<gmd:CI_Telephone>
												<xsl:if test="string-length(//ows:Voice) > 0">
												<gmd:voice>
												<gco:CharacterString>
												<xsl:value-of select="//ows:Voice"/>
												</gco:CharacterString>
												</gmd:voice>
												</xsl:if>
												<xsl:if test="string-length(//ows:Facsimile) > 0">
												<gmd:facsimile>
												<gco:CharacterString>
												<xsl:value-of select="//ows:Facsimile"/>
												</gco:CharacterString>
												</gmd:facsimile>
												</xsl:if>
												</gmd:CI_Telephone>
												</gmd:phone>
											</xsl:if>
											<!-- *******************resource contact address*************** -->
											<!-- include address element, so meet USGIN requirement at minimum with an e-mail address -->
											<gmd:address>
												<gmd:CI_Address>
												<xsl:if
												test="string-length(//ows:Address/ows:DeliveryPoint) > 0">
												<gmd:deliveryPoint>
												<gco:CharacterString>
												<xsl:value-of
												select="//ows:Address/ows:DeliveryPoint"/>
												</gco:CharacterString>
												</gmd:deliveryPoint>
												</xsl:if>
												<xsl:if
												test="string-length(//ows:Address/ows:City) > 0">
												<gmd:city>
												<gco:CharacterString>
												<xsl:value-of select="//ows:Address/ows:City"/>
												</gco:CharacterString>
												</gmd:city>
												</xsl:if>
												<xsl:if
												test="string-length(//ows:Address/ows:AdministrativeArea) > 0">
												<gmd:administrativeArea>
												<gco:CharacterString>
												<xsl:value-of
												select="//ows:Address/ows:AdministrativeArea"/>
												</gco:CharacterString>
												</gmd:administrativeArea>
												</xsl:if>
												<xsl:if
												test="string-length(//ows:Address/ows:PostalCode) > 0">
												<gmd:postalCode>
												<gco:CharacterString>
												<xsl:value-of
												select="//ows:Address/ows:PostalCode"/>
												</gco:CharacterString>
												</gmd:postalCode>
												</xsl:if>
												<xsl:if
												test="string-length(//ows:Address/ows:Country) > 0">
												<gmd:country>
												<gco:CharacterString>
												<xsl:value-of select="//ows:Address/ows:Country"/>
												</gco:CharacterString>
												</gmd:country>
												</xsl:if>
												<!-- test if have e-mail -->
												<gmd:electronicMailAddress>
												<xsl:choose>
												<xsl:when
												test="string-length(//ows:Address/ows:ElectronicMailAddress) > 0">
												<gco:CharacterString>
												<xsl:value-of
												select="//ows:Address/ows:ElectronicMailAddress"/>
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
											codeListValue="pointOfContact">point of
											contact</gmd:CI_RoleCode>
									</gmd:role>
								</gmd:CI_ResponsibleParty>
							</gmd:pointOfContact>
						</xsl:when>
						<xsl:otherwise>
							<!-- these are required for conformance with USGIN profile -->
							<gmd:pointOfContact gco:nilReason="missing">
								<gmd:CI_ResponsibleParty>
									<gmd:individualName gco:nilReason="missing">
										<gco:CharacterString>not reported</gco:CharacterString>
									</gmd:individualName>
									<gmd:contactInfo>
										<gmd:CI_Contact>
											<gmd:phone gco:nilReason="missing"/>
											<gmd:address>
												<gmd:CI_Address>
												<gmd:electronicMailAddress>
												<gco:CharacterString>metadata@usgin.org</gco:CharacterString>
												</gmd:electronicMailAddress>
												</gmd:CI_Address>
											</gmd:address>
										</gmd:CI_Contact>
									</gmd:contactInfo>
									<gmd:role>
										<gmd:CI_RoleCode
											codeList="http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/Codelist/gmxCodelists.xml#CI_RoleCode"
											codeListValue="pointOfContact">point of
											contact</gmd:CI_RoleCode>
									</gmd:role>
								</gmd:CI_ResponsibleParty>
							</gmd:pointOfContact>
						</xsl:otherwise>
					</xsl:choose>
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
					<!-- keywords -->
					<xsl:for-each select="//ows:Keywords">
						<gmd:descriptiveKeywords>
							<gmd:MD_Keywords>
								<gmd:keyword>
									<gco:CharacterString>CSW</gco:CharacterString>
								</gmd:keyword>
								<gmd:keyword>
									<gco:CharacterString>Catalog Service</gco:CharacterString>
								</gmd:keyword>
								<!-- tokenize doesn't work in xslt v1 -->
								<!--			<xsl:for-each select="tokenize(//Keywords, '\s+')">
								<gmd:keyword>
									<gco:CharacterString>
										<xsl:value-of select="." />
									</gco:CharacterString>
								</gmd:keyword>
							</xsl:for-each>  -->
								<xsl:for-each
									select="//ows:Keyword[not(. = following::ows:Keyword)]">
									<gmd:keyword>
										<gco:CharacterString>
											<xsl:value-of select="."/>
										</gco:CharacterString>
									</gmd:keyword>
								</xsl:for-each>
								<!-- Keyword Type - allowed values from MD_KeywordTypeCode names: 
								{discipline, place, stratum, temporal, theme} -->
								<!-- CSW capabiltities include a keyword type with a codespace, but no standard codespace is specified.-->
								<xsl:if test="string-length(./ows:Type) > 0">
									<gmd:type>
										<gmd:MD_KeywordTypeCode>
											<xsl:choose>
												<xsl:when
												test="string-length(/ows:Type/@codeSpace) > 0">
												<xsl:attribute name="codeList">
												<xsl:value-of select="./ows:Type/@codeSpace"/>
												</xsl:attribute>
												<xsl:attribute name="codeListValue">
												<xsl:value-of select="./ows:Type"/>
												</xsl:attribute>
												</xsl:when>
												<xsl:otherwise>
												<xsl:attribute name="codeList"
												>http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/Codelist/gmxCodelists.xml#MD_KeywordTypeCode</xsl:attribute>
												<xsl:attribute name="codeListValue">
												<xsl:value-of select="./ows:Type"/>
												</xsl:attribute>

												</xsl:otherwise>
											</xsl:choose>
											<xsl:value-of select="./ows:Type"/>
										</gmd:MD_KeywordTypeCode>
									</gmd:type>
								</xsl:if>
								<!-- although OGC capabilities allow a vocabulary attribute that broadly 
								corresponds to a Thesaurus name, its too much of a pain to fool around -->
								<!-- extracting, especially since I don't see it used very often -->
							</gmd:MD_Keywords>
						</gmd:descriptiveKeywords>
					</xsl:for-each>
					<!-- (O-X) Resource specific usage - Property not USED by USGIN. -->
					<!-- <gmd:resourceSpecificUsage/> -->
					<!-- -->
					<!-- (O-O) Condition applying to access and use of resource - Restrictions 
						on the access and use of a service. -->
					<gmd:resourceConstraints>
						<gmd:MD_Constraints>
							<gmd:useLimitation>
								<gco:CharacterString>
									<xsl:choose>
										<xsl:when test="string-length(//ows:AccessConstraints) > 0">
											<xsl:value-of select="//ows:AccessConstraints"/>
										</xsl:when>
										<xsl:otherwise>
											<xsl:value-of select="'none specified'"/>
										</xsl:otherwise>
									</xsl:choose>
								</gco:CharacterString>
							</gmd:useLimitation>
						</gmd:MD_Constraints>
					</gmd:resourceConstraints>
					<!-- (M-M) Service type - Choose a service type name from a registry 
						of services. USGIN mandates use of a LocalName value from the service type 
						listing in the ServiceType section of the USGIN ISO19139 profile document, 
						with the codespace http://resources.usgin.org/uri-gin/usgin/vocabulary/serviceType -->
					<srv:serviceType>
						<!-- Valid values for OGC services would be then {<WMS, WFS, WVS, CSW, 
							…} -->
						<gco:LocalName
							codeSpace="http://resources.usgin.org/uri-gin/usgin/vocabulary/serviceType"
							>CSW</gco:LocalName>
					</srv:serviceType>
					<!-- (O-C) Resource service type version - Multiple serviceTypeVersion 
						tags may not be implemented in applications. USGIN recommends a reverse chronological 
						order for supported versions. Constraint: if various versions are available, 
						mandatory to list versions that are supported. Default is oldest version 
						of service. -->
					<srv:serviceTypeVersion>
						<gco:CharacterString>
							<xsl:value-of select="//ows:ServiceTypeVersion"/>
						</gco:CharacterString>
					</srv:serviceTypeVersion>
					<srv:extent>
						<!-- not specified in capabilities; default to world -->
						<EX_Extent>
							<gmd:geographicElement>
								<gmd:EX_GeographicBoundingBox>
									<gmd:westBoundLongitude>
										<gco:Decimal>-180</gco:Decimal>
									</gmd:westBoundLongitude>
									<gmd:eastBoundLongitude>
										<gco:Decimal>180</gco:Decimal>
									</gmd:eastBoundLongitude>
									<gmd:southBoundLatitude>
										<gco:Decimal>-90</gco:Decimal>
									</gmd:southBoundLatitude>
									<gmd:northBoundLatitude>
										<gco:Decimal>90</gco:Decimal>
									</gmd:northBoundLatitude>
								</gmd:EX_GeographicBoundingBox>
							</gmd:geographicElement>
						</EX_Extent>
					</srv:extent>
					<srv:couplingType>
						<srv:SV_CouplingType codeList="#SV_CouplingType" codeListValue="tight"
							>tight</srv:SV_CouplingType>
					</srv:couplingType>
					<srv:containsOperations>
						<xsl:choose>
							<xsl:when
								test="
									//ows:Operation[@name = 'GetCapabilities']/ows:DCP/ows:HTTP/ows:Get/@xlink:href |
									//ows:Operation[@name = 'GetCapabilities']/ows:DCP/ows:HTTP/ows:Post/@xlink:href |
									//ows11:Operation[@name = 'GetCapabilities']/ows11:DCP/ows11:HTTP/ows11:Get/@xlink:href |
									//ows11:Operation[@name = 'GetCapabilities']/ows11:DCP/ows11:HTTP/ows11:Post/@xlink:href">
								<srv:SV_OperationMetadata>
									<srv:operationName>
										<gco:CharacterString>GetCapabilities</gco:CharacterString>
									</srv:operationName>
									<srv:DCP>
										<srv:DCPList codeList="#DCPList" codeListValue="WebServices"
											>WebServices</srv:DCPList>
									</srv:DCP>
									<srv:connectPoint>
										<CI_OnlineResource>
											<linkage>
												<URL>
												<xsl:value-of
												select="
															//ows:Operation[@name = 'GetCapabilities']/ows:DCP/ows:HTTP/ows:Get/@xlink:href |
															//ows:Operation[@name = 'GetCapabilities']/ows:DCP/ows:HTTP/ows:Post/@xlink:href |
															//ows11:Operation[@name = 'GetCapabilities']/ows11:DCP/ows11:HTTP/ows11:Get/@xlink:href |
															//ows11:Operation[@name = 'GetCapabilities']/ows11:DCP/ows11:HTTP/ows11:Post/@xlink:href"
												/>
												</URL>
											</linkage>
										</CI_OnlineResource>
									</srv:connectPoint>
								</srv:SV_OperationMetadata>
							</xsl:when>
							<xsl:otherwise>
								<srv:SV_OperationMetadata>
									<srv:operationName>
										<gco:CharacterString>GetCapabilities</gco:CharacterString>
									</srv:operationName>
									<srv:DCP>
										<srv:DCPList codeList="#DCPList" codeListValue="WebServices"
											>WebServices</srv:DCPList>
									</srv:DCP>
									<srv:connectPoint>
										<CI_OnlineResource>
											<linkage>
												<URL>
												<xsl:value-of select="$sourceUrl"/>
												</URL>
											</linkage>
										</CI_OnlineResource>
									</srv:connectPoint>
								</srv:SV_OperationMetadata>
							</xsl:otherwise>
						</xsl:choose>
					</srv:containsOperations>
				</srv:SV_ServiceIdentification>
			</gmd:identificationInfo>
			<distributionInfo>
				<MD_Distribution>
					<!-- distribution format -->
					<xsl:for-each
						select="//ows:OperationsMetadata//ows:Operation[@name = 'GetRecords']//ows:Parameter[@name = 'outputFormat']//ows:Value">
						<distributionFormat>
							<MD_Format>
								<name>
									<gco:CharacterString>
										<xsl:value-of select="text()"/>
									</gco:CharacterString>
								</name>
								<version gco:nilReason="inapplicable"/>
							</MD_Format>
						</distributionFormat>
					</xsl:for-each>
					<!-- USGIN asks for online linkage info in distribution digital transfer options -->
					<gmd:transferOptions>
						<gmd:MD_DigitalTransferOptions>
							<gmd:onLine>
								<gmd:CI_OnlineResource>
									<!-- (M-M) Resource distributor on-line distribution linkage - Digital transfer options are “technical means and media by which a dataset is obtained from the distributor." . -->
									<gmd:linkage>
										<!-- This linkage element contains the complete URL to access the getCapabilities document directly. 
												Since the metadata is harvested from a capabiltities doc, the source URL should work fine...-->
										<gmd:URL>
											<xsl:value-of select="$sourceUrl"/>
										</gmd:URL>
									</gmd:linkage>
									<!-- The protocol element defines a valid internet protocol used to access the resource. NAP recommended best practice is that the protocol should be taken from an official controlled list such as the Official Internet Protocol Standards published on the Web at http://www.rfc-editor.org/rfcxx00.html or the Internet Assigned Numbers Authority (IANA) at http://www.iana.org/numbers.html.  ‘ftp’ or ‘http’ are common values. -->
									<gmd:protocol>
										<gco:CharacterString>http</gco:CharacterString>
									</gmd:protocol>
									<!-- Linkage names for service URL’s are from "Linkage name conventions" section in the USGIN ISO19139 profile document.  -->
									<gmd:name>
										<gco:CharacterString>serviceDescription</gco:CharacterString>
									</gmd:name>
									<!-- Service Description -->
									<gmd:description>
										<gco:CharacterString>Full URL to request the OGC
											getCapabilities document. This is the mechanism used to
											acquire detailed operation description for USGIN
											metadata.</gco:CharacterString>
									</gmd:description>
								</gmd:CI_OnlineResource>
							</gmd:onLine>
							<gmd:onLine>
								<gmd:CI_OnlineResource>
									<gmd:linkage>
										<gmd:URL>
											<xsl:value-of select="//ows:HTTP/ows:Get[1]/@xlink:href"
											/>
										</gmd:URL>
									</gmd:linkage>
									<!-- The protocol element defines a valid internet protocol used to access the resource.  -->
									<gmd:protocol>
										<gco:CharacterString>http</gco:CharacterString>
									</gmd:protocol>
									<gmd:name>
										<gco:CharacterString>baseURL</gco:CharacterString>
									</gmd:name>
									<!-- Service Description -->
									<gmd:description>
										<gco:CharacterString>Base URL for service access; append '?'
											and standard CSW request parameters to compose
											query.</gco:CharacterString>
									</gmd:description>
								</gmd:CI_OnlineResource>
							</gmd:onLine>
						</gmd:MD_DigitalTransferOptions>
					</gmd:transferOptions>
				</MD_Distribution>
			</distributionInfo>
			<gmd:dataQualityInfo>
				<gmd:DQ_DataQuality>
					<gmd:scope>
						<gmd:DQ_Scope>
							<gmd:level>
								<gmd:MD_ScopeCode
									codeList="http://standards.iso.org/ittf/PubliclyAvailableStandards/ISO_19139_Schemas/resources/Codelist/gmxCodelists.xml#MD_ScopeCode"
									codeListValue="dataset">dataset</gmd:MD_ScopeCode>
							</gmd:level>
						</gmd:DQ_Scope>
					</gmd:scope>
					<gmd:lineage>
						<gmd:LI_Lineage>
							<gmd:statement>
								<gco:CharacterString>
									<xsl:value-of
										select="concat('This metadata record harvested from ', $sourceUrl, '. and transformed to USGIN ISO19139 profile using ogcCSW-toUSGIN_ISO19139.xslt version 1.0')"
									/>
								</gco:CharacterString>
							</gmd:statement>
						</gmd:LI_Lineage>
					</gmd:lineage>
				</gmd:DQ_DataQuality>
			</gmd:dataQualityInfo>
		</gmd:MD_Metadata>
	</xsl:template>
</xsl:stylesheet>
