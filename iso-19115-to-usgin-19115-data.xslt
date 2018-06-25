<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" exclude-result-prefixes="fn azgs1 azgs2 ns2 xs xsi xsl usgin csw"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.isotc211.org/2005/gmd"
	xmlns:gmd="http://www.isotc211.org/2005/gmd" xmlns:gco="http://www.isotc211.org/2005/gco"
	xmlns:gml="http://www.opengis.net/gml" xmlns:gml32="http://www.opengis.net/gml/3.2"
	xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns:gts="http://www.isotc211.org/2005/gts" xmlns:csw="http://www.opengis.net/cat/csw/2.0.2"
	xmlns:srv="http://www.isotc211.org/2005/srv" xmlns:gmx="http://www.isotc211.org/2005/gmx"
	xmlns:gmi="http://www.isotc211.org/2005/gmi"
	xmlns:usgin="http://resources.usgin.org/xslt/ISO2USGINISO"
	xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:ns2="http://azgs.az.gov/2010/metadata/generator"
	xmlns:azgs1="http://azgs.az.gov/2010/metadata/template/v-1-2"
	xmlns:azgs2="http://azgs.az.gov/2010/metadata/source/v-1-3"
	xsi:schemaLocation="http://www.isotc211.org/2005/gmd http://schemas.opengis.net/csw/2.0.2/profiles/apiso/1.0.0/apiso.xsd">
	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>

	<!--*************************************************************************************************** 
*** This transform maps a generic ISO19139 XML metadata record to a record conforming 
	to the USGIN profile by adding appropriate missing values for required elements
	 This style sheet converts ISO 19139 XML to ISO 19139 XML metadata that conforms with the USGIN 
	 profile. See http://lab.usgin.org/profiles/usgin-iso-metadata-profile (http://lab.usgin.org/node/235)
	 also http://usgin.github.io/usginspecs/USGIN_ISO_Metadata.htm
	 
	*** by USGIN Standards and Protocols Drafting Team *** U.S. Geoscience 
	Information System (USGIN) - http://lab.usgin.org *** 
	
	Contributors:  Leah Musil and Stephen Richard
    2013-03-28  


   
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
	<xsl:param name="sourceUrl"/>
	<xsl:param name="serviceType"/>
	<xsl:param name="currentDate"/>
	<!-- maintenance note checks if metadata has been processed -->
	<xsl:param name="metadataMaintenanceNote"
		select="'This metadata record has been processed by the iso-19115-to-usgin-19115-data XSLT to ensure that all mandatory content for USGIN profile has been added.'"/>
	<!-- All to lower case -->
	<xsl:variable name="lowercase" select="'abcdefghijklmnopqrstuvwxyz'"/>
	<xsl:variable name="uppercase" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'"/>
	<xsl:variable name="USGIN-resourceTypes"
		select="'|collection|collection:dataset|collection:dataset:catalog|collection:physical artifact collection|document|document:image|document:image:stillimage|document:image:stillimage:human-generated image|document:image:stillimage:human-generated image:map|document:image:stillimage:photograph|document:image:stillimage:remote sensing earth image|document:image:moving image|document:sound|document:text|document:text:hypertext document|event|event:project|model|physical artifact|service|software|software:stand-alone-application|software:interactive resource|structured digital data item|sampling point|'"/>


	<!-- start main processing chain for XSLT -->
	<xsl:template match="gmd:MD_Metadata | gmi:MI_Metadata">
		<xsl:variable name="var_InputRootNode" select="."/>
		<xsl:variable name="var_TitleString"
			select="string(./gmd:identificationInfo[1]//gmd:citation//gmd:title/gco:CharacterString)"/>

		<gmd:MD_Metadata
			xsi:schemaLocation="http://www.isotc211.org/2005/gmd http://schemas.opengis.net/csw/2.0.2/profiles/apiso/1.0.0/apiso.xsd"
			xmlns:gco="http://www.isotc211.org/2005/gco" xmlns:gml="http://www.opengis.net/gml"
			xmlns:xlink="http://www.w3.org/1999/xlink"
			xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">

			<gmd:fileIdentifier>
				<gco:CharacterString>
					<xsl:choose>
						<xsl:when test="$var_InputRootNode/gmd:fileIdentifier">
							<xsl:value-of
								select="$var_InputRootNode/gmd:fileIdentifier/gco:CharacterString"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of
								select="concat('http://www.opengis.net/def/nil/OGC/0/missing/', '2013-04-04T12:00:00Z')"
							/>
						</xsl:otherwise>
					</xsl:choose>
				</gco:CharacterString>
			</gmd:fileIdentifier>
			<!-- metadata language-->
			<xsl:choose>
				<xsl:when test="$var_InputRootNode/gmd:language">
					<xsl:apply-templates select="$var_InputRootNode/gmd:language"
						mode="no-namespaces"/>
				</xsl:when>
				<xsl:otherwise>
					<gmd:language>
						<!--<xsl:comment>no language in source metadata, USGIN XSLT inserted default value</xsl:comment> -->
						<gmd:LanguageCode
							codeList="http://www.loc.gov/standards/iso639-2/php/code_list.php"
							codeListValue="eng">eng</gmd:LanguageCode>
					</gmd:language>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:choose>
				<xsl:when test="$var_InputRootNode/gmd:characterSet">
					<xsl:apply-templates select="$var_InputRootNode/gmd:characterSet"
						mode="no-namespaces"/>
				</xsl:when>
				<xsl:otherwise>
					<!-- characterSet defaults to UTF-8 if no character set is specified -->
					<gmd:characterSet>
						<xsl:comment>no character set element in source metadata, USGIN XSLT inserted default value</xsl:comment>
						<gmd:MD_CharacterSetCode
							codeList="http://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#MD_CharacterSetCode "
							codeListValue="utf8">UTF-8</gmd:MD_CharacterSetCode>
					</gmd:characterSet>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:choose>
				<xsl:when test="$var_InputRootNode/gmd:hierarchyLevel">
					<xsl:apply-templates select="$var_InputRootNode/gmd:hierarchyLevel"
						mode="no-namespaces"/>
				</xsl:when>
				<xsl:otherwise>
					<!-- hierarchyLevel defaults to dataset-->
					<gmd:hierarchyLevel>
						<xsl:comment>no hierarchyLevel in source metadata, USGIN XSLT inserted default value</xsl:comment>
						<gmd:MD_ScopeCode
							codeList="http://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#MD_ScopeCode"
							codeListValue="Dataset">dataset</gmd:MD_ScopeCode>
					</gmd:hierarchyLevel>
				</xsl:otherwise>
			</xsl:choose>

			<!-- Logic by handler for keywords in imported metadata that have resource category encoded in a keyword with 
			the prefix usginres:. These use the USGIN resource category hierarchy outlined in the USGIN metadata profile. -->

			<xsl:variable name="flag_hlnIsGood">
				<xsl:for-each select="./gmd:hierarchyLevelName">
					<xsl:if
						test="contains($USGIN-resourceTypes, concat('|', normalize-space(translate(string(./gco:CharacterString), $uppercase, $lowercase)), '|'))">
						<xsl:value-of select="'True'"/>
					</xsl:if>
				</xsl:for-each>
			</xsl:variable>

			<xsl:choose>
				<xsl:when test="string-length($flag_hlnIsGood) > 0">
					<xsl:apply-templates select="$var_InputRootNode/gmd:hierarchyLevelName"
						mode="no-namespaces"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:choose>
						<xsl:when
							test="//gmd:keyword[contains(string(gco:CharacterString), 'usginres:')]">
							<xsl:variable name="theUSGINres"
								select="string(//gmd:keyword[contains(string(gco:CharacterString), 'usginres:')]/gco:CharacterString)"/>
							<gmd:hierarchyLevelName>
								<gco:CharacterString>
									<xsl:value-of
										select="substring-after($theUSGINres, 'usginres:')"/>
								</gco:CharacterString>
							</gmd:hierarchyLevelName>
						</xsl:when>
						<xsl:otherwise>
							<!-- if there isn't anything else try to figure it out... -->
							<gmd:hierarchyLevelName>
								<!-- try to guess what kind of resource based on the online distribution URL
					strings. This will take the first one that matches, so order of tests matters...-->
								<xsl:choose>
									<xsl:when
										test="//gmd:transferOptions//gmd:linkage[contains(string(gmd:URL), '.xls')]">
										<gco:CharacterString>collection:dataset</gco:CharacterString>
									</xsl:when>
									<xsl:when
										test="//gmd:transferOptions//gmd:linkage[contains(string(gmd:URL), '.mdb')]">
										<gco:CharacterString>collection:dataset</gco:CharacterString>
									</xsl:when>
									<xsl:when
										test="//gmd:transferOptions//gmd:linkage[contains(string(gmd:URL), 'service=WFS')]">
										<gco:CharacterString>collection:dataset</gco:CharacterString>
									</xsl:when>

									<xsl:when
										test="contains(translate($var_TitleString, $uppercase, $lowercase), 'map of')">
										<gco:CharacterString>document:image:stillimage:human-generated
											image:map</gco:CharacterString>
									</xsl:when>

									<xsl:when
										test="//gmd:transferOptions//gmd:linkage[contains(string(gmd:URL), '.pdf')]">
										<gco:CharacterString>document:text</gco:CharacterString>
									</xsl:when>
									<xsl:when
										test="//gmd:transferOptions//gmd:linkage[contains(string(gmd:URL), '.tif')]">
										<gco:CharacterString>document:image:stillimage</gco:CharacterString>
									</xsl:when>
									<xsl:when
										test="//gmd:transferOptions//gmd:linkage[contains(string(gmd:URL), '.png')]">
										<gco:CharacterString>document:image:stillimage</gco:CharacterString>
									</xsl:when>
									<xsl:when
										test="//gmd:transferOptions//gmd:linkage[contains(string(gmd:URL), '.jpg')]">
										<gco:CharacterString>document:image:stillimage</gco:CharacterString>
									</xsl:when>
									<xsl:otherwise>
										<xsl:choose>
											<!-- if there is an existing hierarchy level name, pass it on -->
											<xsl:when
												test="$var_InputRootNode/gmd:hierarchyLevelName">
												<gco:CharacterString>
												<xsl:value-of
												select="string($var_InputRootNode/gmd:hierarchyLevelName[1]/gco:CharacterString)"
												/>
												</gco:CharacterString>
											</xsl:when>
											<xsl:otherwise>
												<xsl:attribute name="gco:nilReason">
												<xsl:value-of select="string('unknown')"/>
												</xsl:attribute>
												<xsl:comment>no hierarchyLevelName in source metadata, USGIN XSLT inserted default value</xsl:comment>
												<gco:CharacterString>Missing</gco:CharacterString>
											</xsl:otherwise>
										</xsl:choose>
									</xsl:otherwise>
								</xsl:choose>
							</gmd:hierarchyLevelName>
						</xsl:otherwise>
					</xsl:choose>

				</xsl:otherwise>
			</xsl:choose>
			<xsl:for-each select="$var_InputRootNode/gmd:contact">
				<!-- changing all role codes/contacts info -->
				<gmd:contact>
					<xsl:call-template name="usgin:ResponsibleParty">
						<xsl:with-param name="inputParty" select="gmd:CI_ResponsibleParty"/>
						<xsl:with-param name="defaultRole">
							<gmd:role>
								<gmd:CI_RoleCode
									codeList="http://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#CI_RoleCode"
									codeListValue="pointOfContact">pointOfContact</gmd:CI_RoleCode>
							</gmd:role>
						</xsl:with-param>
					</xsl:call-template>
				</gmd:contact>
			</xsl:for-each>
			<gmd:dateStamp>
				<gco:DateTime>
					<xsl:call-template name="usgin:dateFormat">
						<xsl:with-param name="inputDate" select="string(//gmd:dateStamp/*)"/>
					</xsl:call-template>
				</gco:DateTime>
			</gmd:dateStamp>
			<gmd:metadataStandardName>
				<gco:CharacterString>
					<xsl:value-of select="'ISO-USGIN'"/>
				</gco:CharacterString>
			</gmd:metadataStandardName>
			<gmd:metadataStandardVersion>
				<gco:CharacterString>
					<xsl:value-of select="'1.2'"/>
				</gco:CharacterString>
			</gmd:metadataStandardVersion>
			<gmd:dataSetURI>
				<gco:CharacterString>
					<xsl:choose>
						<xsl:when test="$var_InputRootNode/gmd:dataSetURI/gco:CharacterString">
							<xsl:value-of
								select="$var_InputRootNode/gmd:dataSetURI/gco:CharacterString"/>
						</xsl:when>
						<xsl:when
							test="$var_InputRootNode/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:ISBN">
							<xsl:comment>no resource identifier in source metadata, USGIN XSLT uses citation ISBN</xsl:comment>
							<xsl:value-of
								select="concat('ISBN:', normalize-space(string($var_InputRootNode/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:ISBN)))"
							/>
						</xsl:when>
						<xsl:when
							test="$var_InputRootNode/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:ISSN">
							<!--      <xsl:comment>no resource identifier in source metadata, USGIN XSLT uses citation ISSN</xsl:comment> -->
							<xsl:value-of
								select="concat('ISSN:', normalize-space(string($var_InputRootNode/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:ISSN)))"
							/>
						</xsl:when>
						<xsl:when
							test="$var_InputRootNode/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:identifier">
							<!--    <xsl:comment>no resource identifier in source metadata, USGIN XSLT uses citation identifier</xsl:comment>-->
							<xsl:value-of
								select="normalize-space(string($var_InputRootNode/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:identifier))"
							/>
						</xsl:when>
						<xsl:otherwise>
							<!--  <xsl:comment>no resource identifier in source metadata, USGIN XSLT inserted nil value</xsl:comment>-->
							<xsl:value-of
								select="concat('http://www.opengis.net/def/nil/OGC/0/missing/', '2013-04-04T12:00:00Z')"
							/>
						</xsl:otherwise>
					</xsl:choose>
				</gco:CharacterString>
			</gmd:dataSetURI>
			<xsl:apply-templates select="$var_InputRootNode/gmd:locale" mode="no-namespaces"/>

			<xsl:apply-templates select="$var_InputRootNode/gmd:spatialRepresentationInfo"
				mode="no-namespaces"/>

			<xsl:apply-templates select="$var_InputRootNode/gmd:referenceSystemInfo"
				mode="no-namespaces"/>
			<!-- There may be multiple identificationInfo elements. Several metadata profiles put service distribution
                information in sv_serviceIdentification elements in the same records as MD_DataIdentification
              The USGIN profile used MD_DataIdentification and puts service-based distribution information in 
              the distributionInformation section.  If there are multiple MD_DataIdentification elements, only
              the first will be processed. SV_ServiceIdentification elements will be parsed in the distributionInfo
            template -->
			<xsl:call-template name="usgin:identificationSection">
				<xsl:with-param name="inputInfo"
					select="$var_InputRootNode/gmd:identificationInfo/gmd:MD_DataIdentification[1]"
				/>
			</xsl:call-template>
			<!--  handle content information section with MI parts -->
			<xsl:for-each select="$var_InputRootNode/gmd:contentInfo">
				<xsl:call-template name="usgin:contentInformationSection">
					<xsl:with-param name="contentInfo" select="."/>
				</xsl:call-template>
			</xsl:for-each>

			<!-- handle distributions -->
			<xsl:for-each select="$var_InputRootNode/gmd:distributionInfo">
				<xsl:call-template name="usgin:distributionSection">
					<xsl:with-param name="inputDistro" select="."/>
				</xsl:call-template>
			</xsl:for-each>
			<!-- end distribution handler-->
			<!-- handle 19115-2 elements in data quality section... -->
			<!-- check if there is a dataquality section and make that the context node to keep paths shorter -->
			<xsl:for-each select="$var_InputRootNode/gmd:dataQualityInfo/gmd:DQ_DataQuality">
				<gmd:dataQualityInfo>
					<gmd:DQ_DataQuality>
						<!-- copy the scope -->
						<xsl:apply-templates select="gmd:scope" mode="no-namespaces"/>
						<!-- next handle the quality reports; these may have some gmi stuff-->
						<xsl:for-each select="gmd:report">
							<!-- check if it has a gmi type of DQ_Element -->
							<xsl:choose>
								<xsl:when
									test="namespace-uri(./child::node()[2]) = 'http://www.isotc211.org/2005/gmi'">
									<!-- copy the content into a gmd DQ_Element -->
									<gmd:DQ_ConceptualConsistency>
										<gmd:nameOfMeasure>
											<gco:CharacterString>
												<xsl:value-of
												select="concat('gmi:', local-name(./child::node()[2]))"
												/>
											</gco:CharacterString>
										</gmd:nameOfMeasure>
										<gmd:evaluationMethodDescription>
											<!-- make the content of the element into key-value pairs -->
											<gco:CharacterString>
												<xsl:for-each
												select="./descendant::gmd:nameOfMeasure/following-sibling::node()">
												<xsl:if test="string-length(local-name()) > 0">
												<xsl:value-of
												select="concat(local-name(), ':', string(.))"/>
												</xsl:if>
												<!-- get all the descendent content for each sibling... -->
												<xsl:for-each select="descendant::node()">
												<xsl:if test="string-length(local-name()) > 0">
												<xsl:value-of
												select="concat(local-name(), ':', string(.))"/>
												</xsl:if>
												</xsl:for-each>
												</xsl:for-each>
											</gco:CharacterString>
										</gmd:evaluationMethodDescription>
										<gmd:result gco:nilReason="missing"/>
									</gmd:DQ_ConceptualConsistency>
								</xsl:when>
								<xsl:otherwise>
									<xsl:apply-templates select="." mode="no-namespaces"/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:for-each>
						<!-- end for each report -->

						<!-- handle the lineage -->
						<gmd:lineage>
							<gmd:LI_Lineage>
								<xsl:if test="gmd:lineage/gmd:LI_Lineage/gmd:statement">
									<gmd:statement>
										<gco:CharacterString>
											<xsl:value-of
												select="gmd:lineage/gmd:LI_Lineage/gmd:statement/gco:CharacterString"
											/>
										</gco:CharacterString>
									</gmd:statement>
								</xsl:if>
								<xsl:for-each select="gmd:lineage/gmd:LI_Lineage/gmd:processStep">
									<gmd:processStep>
										<xsl:choose>
											<xsl:when test="gmi:LE_ProcessStep">
												<gmd:LI_ProcessStep>
												<!-- get the gmd content -->
												<!-- copy the gmi items as key value pairs into a variable-->
												<xsl:variable name="gmiProcessStepStuff">
												<!-- pick up all the sibling elements after gmd:Processor -->
												<xsl:for-each
												select="./gmi:LE_ProcessStep/gmd:description/following-sibling::node()">
												<!--  3 optional properties after required
													description that are in gmd namespace...-->
												<xsl:if
												test="
																	string-length(local-name()) > 0
																	and local-name() != 'rationale' and local-name() != 'dateTime'
																	and local-name() != 'processor'">
												<!-- this is all on one line to avoid extra whitespace in output -->
												<xsl:value-of
												select="concat(local-name(), ':', string(.))"/>
												<!-- get the descendent nodes -->
												<xsl:for-each select="descendant::node()">
												<xsl:if test="string-length(local-name()) > 0">
												<xsl:value-of
												select="concat(local-name(), ':', string(.))"/>
												</xsl:if>
												</xsl:for-each>
												</xsl:if>
												<!-- if have a node name then process -->
												</xsl:for-each>
												</xsl:variable>
												<!-- defintion of gmiProcessStepStuff -->

												<gmd:description>
												<gco:CharacterString>

												<xsl:value-of
												select="concat(string(gmi:LE_ProcessStep/gmd:description/gco:CharacterString), '. ', $gmiProcessStepStuff)"
												/>
												</gco:CharacterString>
												</gmd:description>
												<xsl:apply-templates
												select="gmi:LE_ProcessStep/gmd:rationale"
												mode="no-namespaces"/>
												<xsl:apply-templates
												select="gmi:LE_ProcessStep/gmd:dateTime"
												mode="no-namespaces"/>
												<xsl:apply-templates
												select="gmi:LE_ProcessStep/gmd:processor"
												mode="no-namespaces"/>
												</gmd:LI_ProcessStep>
											</xsl:when>
											<xsl:otherwise>
												<!-- copy the ProcessStep -->
												<xsl:apply-templates select="gmd:LI_ProcessStep"
												mode="no-namespaces"/>
											</xsl:otherwise>
										</xsl:choose>
									</gmd:processStep>
								</xsl:for-each>
								<!-- processStep -->
								<!--sources have an extent that might be temporal 
						also handle gmi:LE_source...-->
								<xsl:for-each
									select="
										gmd:lineage/gmd:LI_Lineage/gmd:source/gmi:LE_Source
										| gmd:lineage/gmd:LI_Lineage/gmd:source/gmd:LI_Source">
									<gmd:source>
										<gmd:LI_Source>
											<gmd:description>
												<gco:CharacterString>
												<!-- start with the LI_SourceDescription, then concat text from  
												gmi elements if present -->
												<xsl:value-of
												select="gmd:description/gco:CharacterString"/>
												<xsl:for-each
												select="gmi:processedLevel/descendant::node()">
												<xsl:if test="string-length(local-name()) > 0">
												<xsl:value-of
												select="concat(local-name(), ':', string(.))"/>
												</xsl:if>
												</xsl:for-each>
												<xsl:for-each
												select="gmi:resolution/descendant::node()">
												<xsl:if test="string-length(local-name()) > 0">
												<xsl:value-of
												select="concat(local-name(), ':', string(.))"/>
												</xsl:if>
												</xsl:for-each>

												</gco:CharacterString>
											</gmd:description>
											<xsl:apply-templates
												select="gmd:MD_RepresentativeFraction"
												mode="no-namespaces"/>
											<xsl:apply-templates select="gmd:MD_ReferenceSystem"
												mode="no-namespaces"/>

											<!-- use USGIN Citation Handler -->
											<xsl:if test="gmd:sourceCitation">
												<gmd:sourceCitation>
												<xsl:call-template name="usgin:citationHandler">
												<xsl:with-param name="inputCit"
												select="gmd:sourceCitation/gmd:CI_Citation"/>
												</xsl:call-template>
												</gmd:sourceCitation>
											</xsl:if>
											<!-- end citation section -->
											<!-- use usgin extent handler -->
											<xsl:if test="gmd:sourceExtent">
												<gmd:sourceExtent>
												<gmd:EX_Extent>
												<xsl:call-template name="usgin:extentHandler">
												<xsl:with-param name="inputExtent"
												select="gmd:sourceExtent/gmd:EX_Extent"/>
												</xsl:call-template>
												</gmd:EX_Extent>
												</gmd:sourceExtent>
											</xsl:if>
											<!-- end extent section -->
										</gmd:LI_Source>
									</gmd:source>
								</xsl:for-each>
								<!-- end for each source-->

							</gmd:LI_Lineage>
						</gmd:lineage>
					</gmd:DQ_DataQuality>
				</gmd:dataQualityInfo>
			</xsl:for-each>
			<!-- end for each data quality (0 or 1 will be present -->

			<xsl:apply-templates select="$var_InputRootNode/gmd:portrayalCatalogueInfo"
				mode="no-namespaces"/>
			<!--    <xsl:copy-of select="$var_InputRootNode/gmd:metadataConstraints"/>-->
			<xsl:apply-templates select="$var_InputRootNode/gmd:metadataConstraints"
				mode="no-namespaces"/>
			<!--  <xsl:copy-of select="$var_InputRootNode/gmd:applicationSchemaInfo"/>-->
			<xsl:apply-templates select="$var_InputRootNode/gmd:applicationSchemaInfo"
				mode="no-namespaces"/>
			<!--           <xsl:for-each select="$var_InputRootNode/gmd:metadataMaintenance">  -->
			<gmd:metadataMaintenance>
				<gmd:MD_MaintenanceInformation>
					<xsl:choose>
						<xsl:when
							test="$var_InputRootNode/gmd:metadataMaintenance/gmd:MD_MaintenanceInformation/gmd:maintenanceAndUpdateFrequency">
							<!--   <xsl:copy-of select="$var_InputRootNode/gmd:metadataMaintenance/gmd:MD_MaintenanceInformation/gmd:maintenanceAndUpdateFrequency"/>-->
							<xsl:apply-templates
								select="$var_InputRootNode/gmd:metadataMaintenance/gmd:MD_MaintenanceInformation/gmd:maintenanceAndUpdateFrequency"
								mode="no-namespaces"/>
						</xsl:when>
						<xsl:otherwise>
							<gmd:maintenanceAndUpdateFrequency>
								<!--no update frequency in source metadata, USGIN XSLT inserted 'irregular' as a default -->
								<gmd:MD_MaintenanceFrequencyCode
									codeList="http://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#MD_MaintenanceFrequencyCode"
									codeListValue="IRREGULAR">irregular
								</gmd:MD_MaintenanceFrequencyCode>
							</gmd:maintenanceAndUpdateFrequency>
						</xsl:otherwise>
					</xsl:choose>

					<xsl:apply-templates
						select="$var_InputRootNode/gmd:metadataMaintenance/gmd:MD_MaintenanceInformation/gmd:dateOfNextUpdate"
						mode="no-namespaces"/>

					<xsl:apply-templates
						select="$var_InputRootNode/gmd:metadataMaintenance/gmd:MD_MaintenanceInformation/gmd:userDefinedMaintenanceFrequency"
						mode="no-namespaces"/>

					<xsl:apply-templates
						select="$var_InputRootNode/gmd:metadataMaintenance/gmd:MD_MaintenanceInformation/gmd:updateScope"
						mode="no-namespaces"/>

					<xsl:apply-templates
						select="$var_InputRootNode/gmd:metadataMaintenance/gmd:MD_MaintenanceInformation/gmd:updateScopeDescription"
						mode="no-namespaces"/>

					<xsl:apply-templates
						select="$var_InputRootNode/gmd:metadataMaintenance/gmd:MD_MaintenanceInformation/gmd:maintenanceNote"
						mode="no-namespaces"/>
					<!-- add a note that the record has been processed by this xslt -->
					<gmd:maintenanceNote>
						<gco:CharacterString>
							<xsl:value-of
								select="concat($metadataMaintenanceNote, '2013-11-04T12:00:00')"/>
						</gco:CharacterString>
					</gmd:maintenanceNote>

					<xsl:apply-templates
						select="$var_InputRootNode/gmd:metadataMaintenance/gmd:MD_MaintenanceInformation/gmd:contact"
						mode="no-namespaces"/>
				</gmd:MD_MaintenanceInformation>
			</gmd:metadataMaintenance>

		</gmd:MD_Metadata>
	</xsl:template>



	<!-- Templates For Processing -->
	<!--- contact information CI_ResponsibleParty handler -->
	<xsl:template name="usgin:ResponsibleParty">
		<!-- parameter should be a CI_ResponsibleParty node -->
		<xsl:param name="inputParty" select="."/>
		<!--		<xsl:param name="defaultRoleMD" select="/gmd:MD_Metadata/gmd:contact/gmd:CI_ResponsibleParty"/>
        <xsl:param name="defaultRoleCI" select="/gmd:MD_Metadata/gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:citedResponsibleParty/gmd:CI_ResponsibleParty"/>
      <xsl:param name="defaultRoleDI" select="/gmd:MD_Metadata/gmd:distributionInfo/gmd:MD_Distribution/gmd:distributor/gmd:MD_Distributor/gmd:distributorContact/gmd:CI_ResponsibleParty"/>
-->
		<xsl:param name="defaultRole"/>



		<gmd:CI_ResponsibleParty>
			<gmd:individualName>
				<gco:CharacterString>
					<xsl:choose>
						<xsl:when
							test="string-length($inputParty/gmd:individualName/gco:CharacterString) > 0">
							<xsl:value-of
								select="$inputParty/gmd:individualName/gco:CharacterString"/>
						</xsl:when>
						<xsl:otherwise>missing</xsl:otherwise>
					</xsl:choose>
					<xsl:apply-templates
						select="$inputParty/gmd:individualName/gco:CharacterString/@*"
						mode="no-namespaces"/>
				</gco:CharacterString>
			</gmd:individualName>
			<gmd:organisationName>
				<gco:CharacterString>
					<xsl:choose>
						<xsl:when
							test="string-length($inputParty/gmd:organisationName/gco:CharacterString) > 0">
							<xsl:value-of
								select="$inputParty/gmd:organisationName/gco:CharacterString"/>
						</xsl:when>
						<xsl:otherwise>missing</xsl:otherwise>
					</xsl:choose>
					<xsl:apply-templates
						select="$inputParty/gmd:organisationName/gco:CharacterString/@*"
						mode="no-namespaces"/>
				</gco:CharacterString>
			</gmd:organisationName>
			<gmd:positionName>
				<gco:CharacterString>
					<xsl:choose>
						<xsl:when
							test="string-length($inputParty/gmd:positionName/gco:CharacterString) > 0">
							<xsl:value-of select="$inputParty/gmd:positionName/gco:CharacterString"
							/>
						</xsl:when>
						<xsl:otherwise>missing</xsl:otherwise>
					</xsl:choose>
					<xsl:apply-templates
						select="$inputParty/gmd:positionName/gco:CharacterString/@*"
						mode="no-namespaces"/>
				</gco:CharacterString>
			</gmd:positionName>
			<gmd:contactInfo>
				<gmd:CI_Contact>
					<xsl:if
						test="$inputParty/gmd:contactInfo/gmd:CI_Contact/gmd:phone/gmd:CI_Telephone">
						<gmd:phone>
							<gmd:CI_Telephone>
								<xsl:choose>
									<xsl:when
										test="$inputParty/gmd:contactInfo/gmd:CI_Contact/gmd:phone/gmd:CI_Telephone/gmd:voice/gco:CharacterString">
										<xsl:for-each
											select="$inputParty/gmd:contactInfo/gmd:CI_Contact/gmd:phone/gmd:CI_Telephone/gmd:voice">
											<gmd:voice>
												<gco:CharacterString>
												<xsl:choose>
												<xsl:when
												test="string-length(gco:CharacterString) > 0">
												<xsl:value-of select="gco:CharacterString"/>
												</xsl:when>
												<xsl:otherwise>999-999-9999</xsl:otherwise>
												</xsl:choose>
												</gco:CharacterString>
											</gmd:voice>
										</xsl:for-each>
									</xsl:when>
									<xsl:otherwise>
										<gmd:voice>
											<gco:CharacterString>999-999-9999</gco:CharacterString>
										</gmd:voice>
									</xsl:otherwise>
								</xsl:choose>
								<!-- if there is a voice phone -->
								<xsl:apply-templates
									select="$inputParty/gmd:contactInfo/gmd:CI_Contact/gmd:phone/gmd:CI_Telephone/gmd:facsimile"
									mode="no-namespaces"/>
							</gmd:CI_Telephone>
						</gmd:phone>
					</xsl:if>
					<!-- if there is a phone number -->
					<gmd:address>
						<gmd:CI_Address>
							<xsl:if
								test="$inputParty/gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:deliveryPoint/gco:CharacterString">
								<gmd:deliveryPoint>
									<gco:CharacterString>
										<xsl:value-of
											select="$inputParty/gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:deliveryPoint/gco:CharacterString"
										/>
									</gco:CharacterString>
								</gmd:deliveryPoint>
							</xsl:if>
							<xsl:if
								test="$inputParty/gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:city/gco:CharacterString">
								<gmd:city>
									<gco:CharacterString>
										<xsl:value-of
											select="$inputParty/gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:city/gco:CharacterString"
										/>
									</gco:CharacterString>
								</gmd:city>
							</xsl:if>
							<xsl:if
								test="$inputParty/gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:administrativeArea/gco:CharacterString">
								<gmd:administrativeArea>
									<gco:CharacterString>
										<xsl:value-of
											select="$inputParty/gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:administrativeArea/gco:CharacterString"
										/>
									</gco:CharacterString>
								</gmd:administrativeArea>
							</xsl:if>
							<xsl:if
								test="$inputParty/gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:postalCode/gco:CharacterString">
								<gmd:postalCode>
									<gco:CharacterString>
										<xsl:value-of
											select="$inputParty/gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:postalCode/gco:CharacterString"
										/>
									</gco:CharacterString>
								</gmd:postalCode>
							</xsl:if>
							<xsl:if
								test="$inputParty/gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:country/gco:CharacterString">
								<gmd:country>
									<gco:CharacterString>
										<xsl:value-of
											select="$inputParty/gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:country/gco:CharacterString"
										/>
									</gco:CharacterString>
								</gmd:country>
							</xsl:if>
							<!-- there will be an e-mail address -->
							<xsl:choose>
								<xsl:when
									test="$inputParty/gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:electronicMailAddress">
									<xsl:for-each
										select="$inputParty/gmd:contactInfo/gmd:CI_Contact/gmd:address/gmd:CI_Address/gmd:electronicMailAddress">
										<gmd:electronicMailAddress>
											<gco:CharacterString>
												<xsl:choose>
												<xsl:when test="gco:CharacterString">
												<xsl:value-of select="gco:CharacterString"/>
												</xsl:when>
												<xsl:otherwise>metadata@usgin.org</xsl:otherwise>
												</xsl:choose>
											</gco:CharacterString>
										</gmd:electronicMailAddress>
									</xsl:for-each>
								</xsl:when>
								<xsl:otherwise>
									<!-- no e-mail address in the source doc -->
									<gmd:electronicMailAddress gco:nilReason="missing">
										<!--   <xsl:comment>no e-mail address for contact in source metadata, USGIN XSLT inserted nil value</xsl:comment> -->
										<gco:CharacterString>metadata@usgin.org</gco:CharacterString>
									</gmd:electronicMailAddress>
								</xsl:otherwise>
							</xsl:choose>

						</gmd:CI_Address>
					</gmd:address>
					<!-- check if there is an online resource for the contact -->
					<xsl:apply-templates
						select="$inputParty/gmd:contactInfo/gmd:CI_Contact/gmd:onlineResource"
						mode="no-namespaces"/>

					<xsl:apply-templates
						select="$inputParty/gmd:contactInfo/gmd:CI_Contact/gmd:hoursOfService"
						mode="no-namespaces"/>
					<!--   <xsl:copy-of
                        select="$inputParty/gmd:contactInfo/gmd:CI_Contact/gmd:contactInstructions"
                    />-->
					<xsl:apply-templates
						select="$inputParty/gmd:contactInfo/gmd:CI_Contact/gmd:contactInstructions"
						mode="no-namespaces"/>
				</gmd:CI_Contact>
			</gmd:contactInfo>
			<xsl:apply-templates select="$inputParty/gmd:role" mode="no-namespaces"/>
		</gmd:CI_ResponsibleParty>
	</xsl:template>
	<!-- end of ResponsibleParty handler -->

	<!--Identification info - required regardless of repository output-->
	<xsl:template name="usgin:identificationSection">
		<xsl:param name="inputInfo"/>
		<gmd:identificationInfo>
			<gmd:MD_DataIdentification>
				<!-- elements from abstract MD_Identification -->
				<gmd:citation>
					<xsl:call-template name="usgin:citationHandler">
						<xsl:with-param name="inputCit"
							select="$inputInfo/gmd:citation/gmd:CI_Citation"/>
					</xsl:call-template>
				</gmd:citation>
				<xsl:apply-templates select="$inputInfo/gmd:abstract" mode="no-namespaces"/>
				<xsl:apply-templates select="$inputInfo/gmd:purpose" mode="no-namespaces"/>
				<xsl:apply-templates select="$inputInfo/gmd:credit" mode="no-namespaces"/>
				<xsl:apply-templates select="$inputInfo/gmd:status" mode="no-namespaces"/>
				<!--				<xsl:apply-templates select="$inputInfo/gmd:pointOfContact" mode="no-namespaces"/> -->
				<xsl:for-each
					select="$inputInfo//gmd:pointOfContact[descendant::gmd:CI_RoleCode[string-length(@codeListValue) > 0]]">
					<gmd:pointOfContact>
						<xsl:call-template name="usgin:ResponsibleParty">
							<xsl:with-param name="inputParty" select="gmd:CI_ResponsibleParty"/>
							<xsl:with-param name="defaultRole">
								<gmd:role>
									<gmd:CI_RoleCode
										codeList="http://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#CI_RoleCode"
										codeListValue="pointOfContact"
										>pointOfContact</gmd:CI_RoleCode>
								</gmd:role>
							</xsl:with-param>
						</xsl:call-template>
					</gmd:pointOfContact>
				</xsl:for-each>
				<xsl:apply-templates select="$inputInfo/gmd:resourceMaintenance"
					mode="no-namespaces"/>
				<!--          USGIN puts format information in distributionFormat 
         <xsl:copy-of select="$inputInfo/gmd:resourceFormat" copy-namespaces="no"/>  -->
				<!--	<xsl:copy-of select="$inputInfo/gmd:descriptiveKeywords"/>  -->
				<xsl:apply-templates select="$inputInfo/gmd:descriptiveKeywords"
					mode="no-namespaces"/>
				<xsl:apply-templates select="$inputInfo/gmd:resourceSpecificUsage"
					mode="no-namespaces"/>
				<xsl:apply-templates select="$inputInfo/gmd:resourceConstraints"
					mode="no-namespaces"/>
				<xsl:apply-templates select="$inputInfo/gmd:aggregationInfo" mode="no-namespaces"/>
				<!-- elements from MD_DataIdentification -->
				<xsl:apply-templates select="$inputInfo/gmd:spatialRepresentationType"
					mode="no-namespaces"/>
				<xsl:apply-templates select="$inputInfo/gmd:spatialResolution" mode="no-namespaces"/>
				<xsl:apply-templates select="$inputInfo/gmd:language" mode="no-namespaces"/>
				<!-- characterSet defaults to UTF-8 if no character set is specified -->
				<xsl:choose>
					<xsl:when test="$inputInfo/gmd:characterSet">
						<xsl:apply-templates select="$inputInfo/gmd:characterSet"
							mode="no-namespaces"/>
					</xsl:when>
					<xsl:otherwise>
						<gmd:characterSet>
							<!-- <xsl:comment>no character set element in source metadata, USGIN XSLT inserted default value</xsl:comment> -->
							<gmd:MD_CharacterSetCode
								codeList="http://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#MD_CharacterSetCode "
								codeListValue="utf8">UTF-8</gmd:MD_CharacterSetCode>
						</gmd:characterSet>
					</xsl:otherwise>
				</xsl:choose>
				<xsl:choose>
					<xsl:when test="$inputInfo/gmd:topicCategory/gmd:MD_TopicCategoryCode">
						<xsl:apply-templates select="$inputInfo/gmd:topicCategory"
							mode="no-namespaces"/>
					</xsl:when>
					<xsl:when test="//*[local-name() = 'keyword']/*[contains('farming, biota, boundaries, climatologyMeteorologyAtmosphere, economy, elevation, environment, geoscientificInformation, health, imageryBaseMapsEarthCover, intelligenceMilitary, inlandWaters, location, oceans, planningCadastre, society, structure, transportation, utilitiesCommunication, ', 
						concat(normalize-space(string(.)),', '))]">
						<xsl:for-each select="//*[local-name() = 'keyword']/*">
							<xsl:if
								test="string-length(normalize-space(string(.)))>0 and
								contains('farming, biota, boundaries, climatologyMeteorologyAtmosphere, economy, elevation, environment, geoscientificInformation, health, imageryBaseMapsEarthCover, intelligenceMilitary, inlandWaters, location, oceans, planningCadastre, society, structure, transportation, utilitiesCommunication, ', 
								concat(normalize-space(string(.)),', '))">
								<!-- accumulate topic elements in hasISOtopic variable -->
								<gmd:topicCategory>
									<gmd:MD_TopicCategoryCode>
										<xsl:choose>
											<xsl:when test="translate(normalize-space(string(.)),$uppercase,$lowercase)='atmosphere'">
												<xsl:value-of select="string('climatologyMeteorologyAtmosphere')"/>
											</xsl:when>
											<xsl:when test="translate(normalize-space(string(.)),$uppercase,$lowercase)='military'">
												<xsl:value-of select="string('intelligenceMilitary')"/>
											</xsl:when>
											<xsl:when test="translate(normalize-space(string(.)),$uppercase,$lowercase)='cadastre'">
												<xsl:value-of select="string('planningCadastre')"/>
											</xsl:when>
											<xsl:when test="translate(normalize-space(string(.)),$uppercase,$lowercase)='communication'">
												<xsl:value-of select="string('utilitiesCommunication')"/>
											</xsl:when>
											<xsl:otherwise>
												<xsl:value-of select="normalize-space(string(.))"/>
											</xsl:otherwise>
										</xsl:choose>
									</gmd:MD_TopicCategoryCode>
								</gmd:topicCategory>
								
							</xsl:if>
						</xsl:for-each>
					</xsl:when>
					<xsl:otherwise>
						<gmd:topicCategory>
							<xsl:comment>no topic category code in source metadata, USGIN XSLT inserted default value</xsl:comment>
							<gmd:MD_TopicCategoryCode>
								<xsl:value-of select="'geoscientificInformation'"/>
							</gmd:MD_TopicCategoryCode>
						</gmd:topicCategory>
					</xsl:otherwise>
				</xsl:choose>
				<xsl:apply-templates select="$inputInfo/gmd:environmentDescription"
					mode="no-namespaces"/>
				<!-- Get all the extent information. Have to make sure temporal extent gml:timePeriod is used and has gml:id   -->
				<xsl:for-each select="$inputInfo/gmd:extent">
					<gmd:extent>
						<gmd:EX_Extent>
							<xsl:call-template name="usgin:extentHandler">
								<xsl:with-param name="inputExtent" select="gmd:EX_Extent"/>
							</xsl:call-template>
						</gmd:EX_Extent>
					</gmd:extent>
				</xsl:for-each>

				<xsl:apply-templates select="$inputInfo/gmd:supplementalInformation"
					mode="no-namespaces"/>
			</gmd:MD_DataIdentification>
		</gmd:identificationInfo>
	</xsl:template>
	<!-- end processing MD_DataIdentification -->

	<!-- Citation template -->
	<xsl:template name="usgin:citationHandler">
		<xsl:param name="inputCit"/>
		<gmd:CI_Citation>
			<gmd:title>
				<gco:CharacterString>
					<xsl:value-of select="$inputCit/gmd:title/gco:CharacterString"/>
				</gco:CharacterString>
			</gmd:title>
			<!-- Keeping the title from being indented correctly-->
			<gmd:date>
				<gmd:CI_Date>
					<gmd:date>
						<gco:DateTime>
							<xsl:call-template name="usgin:dateFormat">
								<xsl:with-param name="inputDate"
									select="string($inputCit/gmd:date/gmd:CI_Date/gmd:date/*)"/>
							</xsl:call-template>
						</gco:DateTime>
					</gmd:date>
					<gmd:dateType>
						<gmd:CI_DateTypeCode
							codeList="http://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#CI_DateTypeCode"
							codeListValue="publication">publication</gmd:CI_DateTypeCode>
					</gmd:dateType>
				</gmd:CI_Date>
			</gmd:date>

			<xsl:apply-templates select="$inputCit/gmd:edition" mode="no-namespaces"/>

			<xsl:apply-templates select="$inputCit/gmd:editionDate" mode="no-namespaces"/>
			<!--   handler for identifiers, handle NGCD usage of anchor -->
			<xsl:for-each select="$inputCit/gmd:identifier">
				<xsl:choose>
					<xsl:when test="gmd:MD_Identifier/gmd:code/gmx:Anchor">
						<gmd:identifier>
							<gmd:MD_Identifier>
								<xsl:choose>
									<xsl:when test="gmd:MD_Identifier/gmd:authority">
										<xsl:apply-templates
											select="gmd:MD_Identifier/gmd:authority"
											mode="no-namespaces"/>
									</xsl:when>
									<xsl:otherwise>
										<gmd:authority>
											<gmd:CI_Citation>
												<gmd:title>
												<gco:CharacterString>
												<xsl:value-of
												select="concat('transform from gmx:Anchor with title: ', gmd:MD_Identifier/gmd:code/gmx:Anchor/@xlink:title)"
												/>
												</gco:CharacterString>
												</gmd:title>
												<gmd:date gco:nilReason="not applicable"/>
											</gmd:CI_Citation>
										</gmd:authority>

									</xsl:otherwise>
								</xsl:choose>
								<gmd:code>
									<!--		<gmx:Anchor xlink:href="http://dx.doi.org/10.7289/V5154F01" xlink:title="DOI" xlink:actuate="onRequest">doi:10.7289/V5154F01</gmx:Anchor>  -->
									<gco:CharacterString>
										<xsl:value-of
											select="gmd:MD_Identifier/gmd:code/gmx:Anchor/@xlink:href"
										/>
									</gco:CharacterString>
								</gmd:code>
							</gmd:MD_Identifier>
						</gmd:identifier>
					</xsl:when>
					<xsl:otherwise>
						<!-- if no gmx:Anchors, just copy the identifier -->
						<xsl:apply-templates select="." mode="no-namespaces"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:for-each>
			<!-- for each statement allows more than one contact to be processed -->
			<xsl:choose>
				<xsl:when test="$inputCit/gmd:citedResponsibleParty">
					<xsl:for-each select="$inputCit/gmd:citedResponsibleParty">
						<gmd:citedResponsibleParty>
							<xsl:call-template name="usgin:ResponsibleParty">
								<xsl:with-param name="inputParty" select="gmd:CI_ResponsibleParty"/>
								<xsl:with-param name="defaultRole">
									<gmd:role>
										<gmd:CI_RoleCode
											codeList="http://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#CI_RoleCode"
											codeListValue="originator">originator</gmd:CI_RoleCode>
									</gmd:role>
								</xsl:with-param>
							</xsl:call-template>
						</gmd:citedResponsibleParty>
					</xsl:for-each>
				</xsl:when>
				<xsl:otherwise>
					<!-- no responsible party reported, put in minimal missing element -->
					<gmd:citedResponsibleParty gco:nilReason="missing">
						<gmd:CI_ResponsibleParty>
							<gmd:individualName>
								<gco:CharacterString>missing</gco:CharacterString>
							</gmd:individualName>
							<gmd:contactInfo>
								<gmd:CI_Contact>
									<gmd:phone>
										<gmd:CI_Telephone>
											<gmd:voice>
												<gco:CharacterString>999-999-9999</gco:CharacterString>
											</gmd:voice>
										</gmd:CI_Telephone>
									</gmd:phone>
								</gmd:CI_Contact>
							</gmd:contactInfo>
							<gmd:role>
								<gmd:CI_RoleCode
									codeList="http://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#CI_RoleCode"
									codeListValue="originator">originatory</gmd:CI_RoleCode>
							</gmd:role>
						</gmd:CI_ResponsibleParty>
					</gmd:citedResponsibleParty>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:apply-templates select="$inputCit/gmd:presentationForm" mode="no-namespaces"/>
			<xsl:apply-templates select="$inputCit/gmd:series" mode="no-namespaces"/>
			<xsl:apply-templates select="$inputCit/gmd:otherCitationDetails" mode="no-namespaces"/>
			<xsl:apply-templates select="$inputCit/gmd:collectiveTitle" mode="no-namespaces"/>
			<xsl:apply-templates select="$inputCit/gmd:ISBN" mode="no-namespaces"/>
			<xsl:apply-templates select="$inputCit/gmd:ISSN" mode="no-namespaces"/>
		</gmd:CI_Citation>
	</xsl:template>
	<!-- end of citation handler -->

	<!-- Extent handler -->
	<xsl:template name="usgin:extentHandler">
		<xsl:param name="inputExtent"/>

		<xsl:if test="string-length($inputExtent/gmd:description/gco:CharacterString) > 0">
			<gmd:description>
				<gco:CharacterString>
					<xsl:value-of select="$inputExtent/gmd:description/gco:CharacterString"/>
				</gco:CharacterString>
			</gmd:description>
		</xsl:if>


		<!-- abstract EX_GeographicExent might be value for a gmd:geographicElement or a gmd:spatialExtent -->
		<xsl:for-each select="$inputExtent/gmd:geographicElement">
			<!-- might have a description, and a geoboundingbox or a polygon -->

			<gmd:geographicElement>
				<xsl:call-template name="usgin:geographicExtent"/>
			</gmd:geographicElement>
			<!-- probably could be copy-of... -->
			<!--<xsl:if test="gmd:EX_GeographicBoundingBox">
				<gmd:geographicElement>
					<gmd:EX_GeographicBoundingBox>
						<xsl:if test="gmd:EX_GeographicBoundingBox/gmd:extentTypeCode">
							<gmd:extentTypeCode>
								<gco:Boolean>
									<xsl:choose>
										<xsl:when
											test="gmd:EX_GeographicBoundingBox/gmd:extentTypeCode/gco:Boolean">
											<xsl:value-of
												select="gmd:EX_GeographicBoundingBox/gmd:extentTypeCode/gco:Boolean"
											/>
										</xsl:when>
										<!-\- default value -\->
										<xsl:otherwise>1</xsl:otherwise>
									</xsl:choose>
								</gco:Boolean>
							</gmd:extentTypeCode>
						</xsl:if>
						<gmd:westBoundLongitude>
							<gco:Decimal>
								<xsl:value-of
									select="gmd:EX_GeographicBoundingBox/gmd:westBoundLongitude/gco:Decimal"
								/>
							</gco:Decimal>
						</gmd:westBoundLongitude>
						<gmd:eastBoundLongitude>
							<gco:Decimal>
								<xsl:value-of
									select="gmd:EX_GeographicBoundingBox/gmd:eastBoundLongitude/gco:Decimal"
								/>
							</gco:Decimal>
						</gmd:eastBoundLongitude>
						<gmd:southBoundLatitude>
							<gco:Decimal>
								<xsl:value-of
									select="gmd:EX_GeographicBoundingBox/gmd:southBoundLatitude/gco:Decimal"
								/>
							</gco:Decimal>
						</gmd:southBoundLatitude>
						<gmd:northBoundLatitude>
							<gco:Decimal>
								<xsl:value-of
									select="gmd:EX_GeographicBoundingBox/gmd:northBoundLatitude/gco:Decimal"
								/>
							</gco:Decimal>
						</gmd:northBoundLatitude>
					</gmd:EX_GeographicBoundingBox>
				</gmd:geographicElement>
			</xsl:if>
			<xsl:if test="gmd:EX_BoundingPolygon">
				<gmd:geographicElement>
					<xsl:apply-templates select="gmd:EX_BoundingPolygon" mode="no-namespaces"/>
				</gmd:geographicElement>
			</xsl:if>-->
		</xsl:for-each>
		<!-- end of geographicElement handler -->
		<!-- gmd:geographicElement/gmd:EX_GeographicDescription code values are copied into the
                keywords.type = 'place' group -->
		<xsl:for-each select="$inputExtent/gmd:temporalElement">
			<xsl:call-template name="usgin:temporalElement">
				<xsl:with-param name="thetempelem" select="."/>
			</xsl:call-template>
		</xsl:for-each>

		<!-- gmd:minvalue maxvalue are required; might need to put logic in to test that....-->
		<xsl:apply-templates select="$inputExtent/gmd:verticalElement" mode="no-namespaces"/>
		<!-- vertical element -->

		<!-- end exent processing -->

	</xsl:template>
	<!-- end of extent handler -->

	<xsl:template name="usgin:geographicExtent">
		<!-- might be a gmd:geographicElement or gmd:spatialExtent as local context-->
		<!-- might have a description, and a geoboundingbox or a polygon -->
		<!-- probably could be copy-of... -->

		<xsl:choose>
			<xsl:when test="gmd:EX_GeographicBoundingBox">
				<gmd:EX_GeographicBoundingBox>
					<!-- put in default extenttypecode if it is missing -->
					<gmd:extentTypeCode>
						<gco:Boolean>
							<xsl:choose>
								<xsl:when
									test="gmd:EX_GeographicBoundingBox/gmd:extentTypeCode/gco:Boolean">
									<xsl:value-of
										select="gmd:EX_GeographicBoundingBox/gmd:extentTypeCode/gco:Boolean"
									/>
								</xsl:when>
								<!-- default value -->
								<xsl:otherwise>1</xsl:otherwise>
							</xsl:choose>
						</gco:Boolean>
					</gmd:extentTypeCode>
					<gmd:westBoundLongitude>
						<gco:Decimal>
							<xsl:value-of
								select="gmd:EX_GeographicBoundingBox/gmd:westBoundLongitude/gco:Decimal"
							/>
						</gco:Decimal>
					</gmd:westBoundLongitude>
					<gmd:eastBoundLongitude>
						<gco:Decimal>
							<xsl:value-of
								select="gmd:EX_GeographicBoundingBox/gmd:eastBoundLongitude/gco:Decimal"
							/>
						</gco:Decimal>
					</gmd:eastBoundLongitude>
					<gmd:southBoundLatitude>
						<gco:Decimal>
							<xsl:value-of
								select="gmd:EX_GeographicBoundingBox/gmd:southBoundLatitude/gco:Decimal"
							/>
						</gco:Decimal>
					</gmd:southBoundLatitude>
					<gmd:northBoundLatitude>
						<gco:Decimal>
							<xsl:value-of
								select="gmd:EX_GeographicBoundingBox/gmd:northBoundLatitude/gco:Decimal"
							/>
						</gco:Decimal>
					</gmd:northBoundLatitude>
				</gmd:EX_GeographicBoundingBox>
			</xsl:when>
			<xsl:when test="gmd:EX_BoundingPolygon">
				<xsl:apply-templates select="gmd:EX_BoundingPolygon" mode="no-namespaces"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates select="./*" mode="no-namespaces"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>


	<!-- template to handle MI elements in contentInformation -->
	<xsl:template name="usgin:contentInformationSection">
		<xsl:param name="inputContentInfo"/>
		<gmd:contentInfo>
			<!--	<xsl:apply-templates select=""	mode="no-namespaces"/>-->
			<!-- logic:
			if have MI_ImageDescription or MD_ImageDescription, copy all the attributes except 'dimension' to MD_ImageDescription -->
			<!-- if have MD_CoverageDescription or MI_CoverageDescription, then copy attributes except 'dimension' to MD_ImageDescription;
				the text from MI_RangeElementDescription will be lost; would have to append to the abstract -->
			<!-- for dimension properties, copy MI_Band content, if present, into the MD_RangeDimension/descriptor string -->

			<xsl:choose>
				<xsl:when test="gmd:MD_FeatureCatalogueDescription">
					<xsl:apply-templates select="gmd:MD_FeatureCatalogueDescription"
						mode="no-namespaces"/>
				</xsl:when>
				<xsl:when test="gmd:MD_CoverageDescription | gmi:MI_CoverageDescription">
					<gmd:MD_CoverageDescription>
						<xsl:apply-templates select="./child::node()/gmd:attributeDescription"
							mode="no-namespaces"/>
						<xsl:apply-templates select="./child::node()/gmd:contentType"
							mode="no-namespaces"/>
						<xsl:for-each select="./child::node()/gmd:dimension">
							<xsl:call-template name="usgin:dimensionSection">
								<xsl:with-param name="dimensionElement" select="."/>
							</xsl:call-template>
						</xsl:for-each>
					</gmd:MD_CoverageDescription>
				</xsl:when>
				<xsl:when test="gmd:MD_ImageDescription | gmi:MI_ImageDescription">
					<gmd:MD_ImageDescription>
						<xsl:apply-templates select="./child::node()/gmd:attributeDescription"
							mode="no-namespaces"/>
						<xsl:apply-templates select="./child::node()/gmd:contentType"
							mode="no-namespaces"/>
						<!-- if its a coverage description none of these will be present, but that won't break anything... -->
						<xsl:apply-templates select="./child::node()/gmd:illuminationElevationAngle"
							mode="no-namespaces"/>
						<xsl:apply-templates select="./child::node()/gmd:illuminationAzimuthAngle"
							mode="no-namespaces"/>
						<xsl:apply-templates select="./child::node()/gmd:imagingCondition"
							mode="no-namespaces"/>
						<xsl:apply-templates select="./child::node()/gmd:imageQualityCode"
							mode="no-namespaces"/>
						<xsl:apply-templates select="./child::node()/gmd:cloudCoverPercentage"
							mode="no-namespaces"/>
						<xsl:apply-templates select="./child::node()/gmd:processingLevelCode"
							mode="no-namespaces"/>
						<xsl:apply-templates
							select="./child::node()/gmd:compressionGenerationQuality"
							mode="no-namespaces"/>
						<xsl:apply-templates select="./child::node()/gmd:triangulationIndicator"
							mode="no-namespaces"/>
						<xsl:apply-templates
							select="./child::node()/gmd:radiometricCalibrationDataAvailability"
							mode="no-namespaces"/>
						<xsl:apply-templates
							select="./child::node()/gmd:cameraCalibrationInformationAvailability"
							mode="no-namespaces"/>
						<xsl:apply-templates
							select="./child::node()/gmd:filmDistortionInformationAvailability"
							mode="no-namespaces"/>
						<xsl:apply-templates
							select="./child::node()/gmd:lensDistortionInformationAvailability"
							mode="no-namespaces"/>
						<xsl:for-each select="./child::node()/gmd:dimension">
							<xsl:call-template name="usgin:dimensionSection">
								<xsl:with-param name="dimensionElement" select="."/>
							</xsl:call-template>
						</xsl:for-each>
					</gmd:MD_ImageDescription>
				</xsl:when>
			</xsl:choose>
		</gmd:contentInfo>

	</xsl:template>
	<!-- end content information handler -->

	<!-- handle content description dimension elements -->
	<xsl:template name="usgin:dimensionSection">
		<xsl:param name="dimensionElement"/>

		<xsl:variable name="mi_bandText">
			<xsl:choose>
				<xsl:when test="gmi:MI_Band">
					<xsl:if test="gmi:MI_Band/gmi:bandBoundaryDefinition/gmi:MI_BandDefinition">
						<xsl:value-of
							select="concat('band boundary definition: ', gmi:MI_Band/gmi:bandBoundaryDefinition/gmi:MI_BandDefinition/@codeListValue, '...')"
						/>
					</xsl:if>
					<xsl:if test="gmi:MI_Band/gmi:nominalSpatialResolution/gco:Real">
						<xsl:value-of
							select="concat('nominal spatial resoution: ', string(gmi:MI_Band/gmi:nominalSpatialResolution/gco:Real), '...')"
						/>
					</xsl:if>
					<xsl:if
						test="gmi:MI_Band/gmi:transferFunctionType/gmi:MI_TransferFunctionTypeCode">
						<xsl:value-of
							select="concat('transfer function type: ', gmi:MI_Band/gmi:transferFunctionType/gmi:MI_TransferFunctionTypeCode/@codeListValue, '...')"
						/>
					</xsl:if>
					<xsl:if
						test="gmi:MI_Band/gmi:transmittedPolarisation/gmi:MI_PolarisationOrientationCode">
						<xsl:value-of
							select="concat('transmitted polarisation: ', gmi:MI_Band/gmi:transmittedPolarisation/gmi:MI_PolarisationOrientationCode/@codeListValue, '...')"
						/>
					</xsl:if>
					<xsl:if
						test="gmi:MI_Band/gmi:detectedPolarisation/gmi:MI_PolarisationOrientationCode">
						<xsl:value-of
							select="concat('detected polarisation: ', gmi:MI_Band/gmi:detectedPolarisation/gmi:MI_PolarisationOrientationCode/@codeListValue, '...')"
						/>
					</xsl:if>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="''"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<!-- end definition of mi_bandText -->
		<gmd:dimension>
			<xsl:choose>
				<xsl:when test="gmd:MD_RangeDimension">
					<gmd:MD_RangeDimension>
						<xsl:apply-templates select="./child::node()/gmd:sequenceIdentifier"
							mode="no-namespaces"/>
						<gmd:descriptor>
							<gco:CharacterString>
								<xsl:value-of
									select="concat(./child::node()/gmd:descriptor/gco:CharacterString, '...')"
								/>
							</gco:CharacterString>
						</gmd:descriptor>
					</gmd:MD_RangeDimension>
				</xsl:when>
				<xsl:when test="gmd:MD_Band | gmi:MI_Band">
					<gmd:MD_Band>
						<xsl:apply-templates select="./child::node()/gmd:sequenceIdentifier"
							mode="no-namespaces"/>
						<gmd:descriptor>
							<gco:CharacterString>
								<xsl:if test="./child::node()/gmd:descriptor">
									<xsl:value-of
										select="concat(./child::node()/gmd:descriptor/gco:CharacterString, '...')"
									/>
								</xsl:if>
								<xsl:value-of select="normalize-space($mi_bandText)"/>
							</gco:CharacterString>
						</gmd:descriptor>
						<xsl:apply-templates select="./child::node()/gmd:maxValue"
							mode="no-namespaces"/>
						<xsl:apply-templates select="./child::node()/gmd:minValue"
							mode="no-namespaces"/>
						<xsl:apply-templates select="./child::node()/gmd:units" mode="no-namespaces"/>
						<xsl:apply-templates select="./child::node()/gmd:peakResponse"
							mode="no-namespaces"/>
						<xsl:apply-templates select="./child::node()/gmd:bitsPerValue"
							mode="no-namespaces"/>
						<xsl:apply-templates select="./child::node()/gmd:toneGradation"
							mode="no-namespaces"/>
						<xsl:apply-templates select="./child::node()/gmd:scaleFactor"
							mode="no-namespaces"/>
						<xsl:apply-templates select="./child::node()/gmd:offset"
							mode="no-namespaces"/>
					</gmd:MD_Band>
				</xsl:when>
			</xsl:choose>
		</gmd:dimension>
	</xsl:template>
	<!-- end of content info dimension handler -->


	<!-- Distribution -->
	<xsl:template name="usgin:distributionSection">
		<xsl:param name="inputDistro"/>
		<!-- context will be distributionInfo -->
		<gmd:distributionInfo>
			<gmd:MD_Distribution>
				<!-- copy over any distribution Formats -->
				<xsl:apply-templates
					select="$inputDistro/gmd:MD_Distribution/gmd:distributionFormat"
					mode="no-namespaces"/>
				<!-- if there is a MD_DataIdentification/resourceFormat, put that in here-->
				<xsl:for-each select="//gmd:MD_DataIdentification/gmd:resourceFormat">
					<gmd:distributionFormat>
						<xsl:apply-templates select="gmd:MD_Format" mode="no-namespaces"/>
					</gmd:distributionFormat>
				</xsl:for-each>
				<xsl:for-each select="$inputDistro/gmd:MD_Distribution/gmd:distributor">
					<gmd:distributor>
						<!-- check: may need to check for ID's on distributors used to bind transfer options
                        to distributors if there are multiple distributors and transfer options -->
						<gmd:MD_Distributor>
							<gmd:distributorContact>
								<xsl:call-template name="usgin:ResponsibleParty">
									<xsl:with-param name="inputParty"
										select="gmd:MD_Distributor/gmd:distributorContact/gmd:CI_ResponsibleParty"/>
									<xsl:with-param name="defaultRole">
										<gmd:role>
											<gmd:CI_RoleCode
												codeList="http://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#CI_RoleCode"
												codeListValue="distributor"
												>distributor</gmd:CI_RoleCode>
										</gmd:role>
									</xsl:with-param>
								</xsl:call-template>
							</gmd:distributorContact>
							<xsl:apply-templates
								select="gmd:MD_Distributor/gmd:distributionOrderProcess"
								mode="no-namespaces"/>
							<xsl:apply-templates select="gmd:MD_Distributor/gmd:distributorFormat"
								mode="no-namespaces"/>
							<xsl:apply-templates
								select="gmd:MD_Distributor/gmd:distributorTransferOptions"
								mode="no-namespaces"/>
						</gmd:MD_Distributor>
					</gmd:distributor>
				</xsl:for-each>
				<!-- end of iteration over distributors -->
				<!-- accomodate metadata that has all transfer options in distributorTransferOptions
                 put the first TransferOptions link into MD_Distribtuion/gmd:transferOptions -->
				<xsl:choose>
					<xsl:when test="$inputDistro/gmd:MD_Distribution/gmd:transferOptions">
						<xsl:apply-templates
							select="$inputDistro/gmd:MD_Distribution/gmd:transferOptions"
							mode="no-namespaces"/>
					</xsl:when>
					<xsl:otherwise>
						<!-- copy in the first distributor transfer options -->
						<xsl:if
							test="$inputDistro/gmd:MD_Distribution/gmd:distributor/gmd:MD_Distributor/gmd:distributorTransferOptions">
							<gmd:transferOptions>
								<!-- <xsl:comment>USGIN XSLT copies first distributorTransferOption here for clients that expect transferOptions</xsl:comment> -->
								<xsl:apply-templates
									select="$inputDistro/gmd:MD_Distribution/gmd:distributor/gmd:MD_Distributor/gmd:distributorTransferOptions[1]/gmd:MD_DigitalTransferOptions"
									mode="no-namespaces"/>
							</gmd:transferOptions>
						</xsl:if>
					</xsl:otherwise>
				</xsl:choose>
				<!-- accomodate service distributions described in SV_ServiceIdentification sections -->
				<xsl:if test="//srv:serviceType">
					<xsl:for-each select="//gmd:identificationInfo/srv:SV_ServiceIdentification">
						<!-- each service is in a separate transferOptions section -->
						<gmd:transferOptions>
							<gmd:MD_DigitalTransferOptions>
								<!--  <xsl:comment>USGIN XSLT copies transfer options from SV_ServiceIdentification element in source metadata</xsl:comment> -->
								<xsl:for-each
									select="srv:containsOperations/srv:SV_OperationMetadata">
									<!-- each operation gets a separate CI_OnlineResource link -->
									<gmd:onLine>
										<gmd:CI_OnlineResource>
											<gmd:linkage>
												<gmd:URL>
												<xsl:value-of
												select="string(srv:connectPoint/gmd:CI_OnlineResource/gmd:linkage/gmd:URL)"
												/>
												</gmd:URL>
											</gmd:linkage>
											<gmd:protocol>
												<gco:CharacterString>
												<xsl:value-of
												select="normalize-space(string(ancestor::srv:SV_ServiceIdentification/srv:serviceType))"
												/>
												</gco:CharacterString>
											</gmd:protocol>

											<gmd:applicationProfile>
												<gco:CharacterString>
												<xsl:if test="string-length(string(srv:DCP)) > 0">
												<xsl:value-of
												select="concat('DCP:', normalize-space(string(srv:DCP)), ': ')"
												/>
												</xsl:if>
												<xsl:if
												test="srv:connectPoint/gmd:CI_OnlineResource/gmd:applicationProfile"/>
												<xsl:value-of
												select="srv:connectPoint/gmd:CI_OnlineResource/gmd:applicationProfile/gco:CharacterString"
												/>
												</gco:CharacterString>
											</gmd:applicationProfile>

											<gmd:name>
												<gco:CharacterString>
												<xsl:value-of
												select="concat(srv:connectPoint/gmd:CI_OnlineResource/gmd:name/gco:CharacterString, ' ', srv:operationName/gco:CharacterString)"
												/>
												</gco:CharacterString>
											</gmd:name>
											<xsl:apply-templates
												select="srv:connectPoint/gmd:CI_OnlineResource/gmd:description"
												mode="no-namespaces"/>
											<xsl:apply-templates
												select="srv:connectPoint/gmd:CI_OnlineResource/gmd:function"
												mode="no-namespaces"/>
										</gmd:CI_OnlineResource>
									</gmd:onLine>
								</xsl:for-each>
							</gmd:MD_DigitalTransferOptions>
						</gmd:transferOptions>
					</xsl:for-each>
				</xsl:if>
			</gmd:MD_Distribution>
		</gmd:distributionInfo>
	</xsl:template>
	<!-- end distributionInformation processing -->

	<!-- utility templates -->
	<xsl:template name="usgin:dateFormat">
		<xsl:param name="inputDate"/>
		<!-- input data should be either a string -->
		<!-- USGIN mandates use of DateTime, so will need to add 'T12:00:00Z' to gco:Date string -->
		<xsl:choose>
			<xsl:when test="string-length(normalize-space(string($inputDate))) = 4">
				<xsl:value-of
					select="concat(normalize-space(translate(string($inputDate), '/', '-')), '-01-01T12:00:00Z')"
				/>
			</xsl:when>
			<xsl:when test="string-length(normalize-space(string($inputDate))) = 10">
				<!-- YYYY-MM-DD -->
				<xsl:value-of
					select="concat(normalize-space(translate(string($inputDate), '/', '-')), 'T12:00:00Z')"
				/>
			</xsl:when>
			<xsl:when test="string-length(normalize-space(string($inputDate))) &gt; 17">
				<xsl:value-of select="$inputDate"/>
			</xsl:when>

			<xsl:when test="string-length(normalize-space(string($inputDate/gco:DateTime))) = 11">
				<!-- YYYY-MM-DDT -->
				<xsl:value-of
					select="concat(normalize-space(translate(string($inputDate), '/', '-')), '00:00:00Z')"
				/>
			</xsl:when>
			<xsl:when test="string-length(normalize-space(string($inputDate))) = 16">
				<!-- YYYY-MM-DDTHH:MM -->
				<xsl:value-of select="concat(translate(string($inputDate), '/', '-'), ':00Z')"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="string('1900-01-01T12:00:00Z')"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<!-- end of inputDate handler -->

	<xsl:template name="usgin:temporalElement">
		<xsl:param name="thetempelem"/>

		<!-- process possible incoming TimeInstant or TimePeriod-->
		<!-- Output will always have temporal extent in a TimePeriod element with begin and end elements.
			The intention is to reduce number of options requred for processing filters. 
			If input is a TimeInstant, copy the gml:timePosition into 
			gml:begin/gml:TimeInstant/gml32:timePosition and gml:end/gml:TimeInstant/gml32:timePosition
			of the gml:TimePeriod
        *   make sure that TimePeriod has a gml:id 
		*   try to harden against gml vs gml 3.2 namespaces on the incoming gml (but this is hard to test...) -->

		<!-- check for EX_TemporalExtent or gmd:EX_SpatialTemporalExtent -->
		<xsl:variable name="timeelement" select="./*"/>
		<!-- get its name as a string; xsl:element require as sting input (no functions) -->
		<xsl:variable name="timelemname" select="name($timeelement/gmd:extent/*)"/>

		<!-- get the prefix used for the gml elements; assume is same for all gml -->
		<xsl:variable name="theprefix"
			select="concat(substring-before(string($timelemname), ':'), ':')"/>

		<!-- this gets used in the begin and end elements of the time period -->
		<xsl:variable name="timeinstantname" select="concat($theprefix, string('TimeInstant'))"/>
		<xsl:variable name="gmlidatt" select="concat($theprefix, 'id')"/>
		<xsl:variable name="timeposition" select="concat($theprefix, 'timePosition')"/>

		<gmd:temporalElement>
			<!-- note that gmd:EX_TemporalExtent or gmd:EX_SpatialTemporalExtent  might show up here-->
			<xsl:variable name="tename" select="name($timeelement)"/>
			<xsl:element name="{$tename}">
				<!-- temporal extent could be a gemetric primitive (TimeInstant or TimePeriod
                    or a topologic primitive (TimeNode or TimeEdge); TBD process topologic primitives... -->
				<!-- figure out if using gml 3 or 3.2 -->


				<gmd:extent>
					<!-- local-name references to get around gml version problems (3 vs 3.2) -->
					<xsl:choose>
						<xsl:when
							test="
								$timeelement/gmd:extent/*[local-name() = 'TimePeriod'] or
								$timeelement/gmd:extent/*[local-name() = 'TimeInstant']">
							<xsl:variable name="tpname" select="concat($theprefix, 'TimePeriod')"/>
							<xsl:element name="{$tpname}">
								<xsl:choose>
									<!-- take care of the gml:id, use existing in the data if there is one.. use local-name -->

									<xsl:when
										test="$timeelement/gmd:extent/*[local-name() = 'TimePeriod']/@*[local-name() = 'id']">
										<xsl:for-each
											select="$timeelement/gmd:extent/*[local-name() = 'TimePeriod']/@*[local-name() = 'id']">

											<xsl:attribute name="{$gmlidatt}">
												<xsl:value-of select="normalize-space(string(.))"/>
											</xsl:attribute>
										</xsl:for-each>
									</xsl:when>
									<xsl:otherwise>
										<xsl:attribute name="{$gmlidatt}">
											<xsl:value-of
												select="concat('a', string(generate-id()))"/>
										</xsl:attribute>
									</xsl:otherwise>
								</xsl:choose>
								<!-- gml:id handler -->

	<!-- copy any other gml elements that might be present before begin and end elements 
		gml32:metaDataProperty{0-UNBOUNDED}
		gml32:description{0-1}
		gml32:descriptionReference{0-1}
		gml32:identifier{0-1}
		gml32:name{0-UNBOUNDED
		gml32:relatedTime{0-UNBOUNDED} -->
								<xsl:for-each
									select="$timeelement/gmd:extent/*[local-name() = 'TimePeriod']">
									<!-- this is just to simplify the context -->
									<xsl:apply-templates
										select="*[local-name() = 'metaDataProperty']"
										mode="no-namespaces"/>
									<xsl:apply-templates select="*[local-name() = 'description']"
										mode="no-namespaces"/>
									<xsl:apply-templates
										select="*[local-name() = 'descriptionReference']"
										mode="no-namespaces"/>
									<xsl:apply-templates select="*[local-name() = 'identifier']"
										mode="no-namespaces"/>
									<xsl:apply-templates select="*[local-name() = 'name']"
										mode="no-namespaces"/>
									<xsl:apply-templates select="*[local-name() = 'relatedTime']"
										mode="no-namespaces"/>
								</xsl:for-each>
								<!-- add a name value if the TimePeriod is converted from a TimeInstant as a convience for processors -->
								<xsl:if
									test="$timeelement/gmd:extent/*[local-name() = 'TimeInstant']">
									<xsl:variable name="addname" select="concat($theprefix, 'name')"/>
									<xsl:element name="{$addname}">
										<xsl:value-of select="string('TimePeriod generated from TimeInstant')"
										/>
									</xsl:element>
								</xsl:if>

								<!-- now do the begin position with proper iso8601 formatting... -->
								<xsl:variable name="begname" select="concat($theprefix, 'begin')"/>
								<xsl:element name="{$begname}">
									<xsl:element name="{$timeinstantname}">
										<xsl:variable name="btpos">
											<!-- get the time value string -->
											<xsl:choose>
												<!-- TimePeriod with a beginPosition -->
												<xsl:when test="*//*[local-name() = 'beginPosition']">
													<xsl:value-of select="normalize-space(string(*//*[local-name() = 'beginPosition']))"/>
												</xsl:when>
												<!-- TimePeriod with a begin//timePosition -->
												<xsl:when test="*//*[local-name() = 'begin']//*[local-name() = 'timePosition']">
													<xsl:value-of select="normalize-space(string(*//*[local-name() = 'begin']//*[local-name() = 'timePosition']))"/>
												</xsl:when>
												<!-- TimeInstant with timePosition -->
												<xsl:when test="*//*[local-name() = 'TimeInstant']/*[local-name() = 'timePosition']">
													<xsl:value-of select="normalize-space(string(*//*[local-name() = 'TimeInstant']/*[local-name() = 'timePosition']))"/>
												</xsl:when>
											</xsl:choose>
										</xsl:variable>
										<!-- time value string  -->

										<!-- gml:id for the begin TimeInstant -->
										<xsl:variable name="begTIgmlid">
											<xsl:choose>
												<!-- TimePeriod with a beginPosition make new gml:id -->
												<xsl:when
												test="*//*[local-name() = 'beginPosition']">
												<xsl:value-of
												select="concat('a', string(generate-id()))"/>
												</xsl:when>
												<!-- TimePeriod with a begin//timePosition; use same gml:id -->
												<xsl:when
												test="*//*[local-name() = 'begin']//*[local-name() = 'timePosition']">
												<xsl:choose>
												<!-- take care of the gml:id, use existing in the data if there is one.. use local-name -->
												<xsl:when
												test="*//*[local-name() = 'begin']/*[local-name() = 'TimeInstant']/@*[local-name() = 'id']">
												<xsl:value-of
												select="normalize-space(string(*//*[local-name() = 'begin']/*[local-name() = 'TimeInstant']/@*[local-name() = 'id']))"
												/>
												</xsl:when>
												<xsl:otherwise>
												<xsl:value-of
												select="concat('a', string(generate-id()))"/>
												</xsl:otherwise>
												</xsl:choose>
												<!-- gml:id handler -->
												</xsl:when>
												<!-- TimeInstant with timePosition; use gml:ID for TimeInstant on begin of TimePeriod -->
												<xsl:when
												test="*//*[local-name() = 'TimeInstant']/*[local-name() = 'timePosition']">
												<xsl:choose>
												<!-- take care of the gml:id, use existing in the data if there is one.. use local-name -->
												<xsl:when
												test="*//*[local-name() = 'TimeInstant']/@*[local-name() = 'id']">
												<xsl:value-of
												select="normalize-space(string(*//*[local-name() = 'TimeInstant']/@*[local-name() = 'id']))"
												/>
												</xsl:when>
												<xsl:otherwise>
												<xsl:value-of
												select="concat('a', string(generate-id()))"/>
												</xsl:otherwise>
												</xsl:choose>
												<!-- gml:id handler -->
												</xsl:when>
											</xsl:choose>
										</xsl:variable>
										<!-- gml:id for begin TimeInstant -->

										<!-- clean up the time string -->

										<xsl:variable name="cleanbtime">
											<xsl:call-template name="usgin:dateFormat">
												<xsl:with-param name="inputDate"
												select="string($btpos)"/>
											</xsl:call-template>
										</xsl:variable>
										
					<!-- add other possible gml elements if present -->
										
										<xsl:for-each select="$timeelement/gmd:extent/*[local-name() = 'TimeInstant'] | 
											$timeelement/gmd:extent//*[local-name()='begin']/*[local-name()='TimeInstant']">
											<!-- this is just to simplify the context -->
											<xsl:apply-templates
												select="*[local-name() = 'metaDataProperty']"
												mode="no-namespaces"/>
											<xsl:apply-templates select="*[local-name() = 'description']"
												mode="no-namespaces"/>
											<xsl:apply-templates
												select="*[local-name() = 'descriptionReference']"
												mode="no-namespaces"/>
											<xsl:apply-templates select="*[local-name() = 'identifier']"
												mode="no-namespaces"/>
											<xsl:apply-templates select="*[local-name() = 'name']"
												mode="no-namespaces"/>
											<xsl:apply-templates select="*[local-name() = 'relatedTime']"
												mode="no-namespaces"/>
										</xsl:for-each>

										<xsl:choose>
											<xsl:when test="$cleanbtime != string('1900-01-01T12:00:00Z')">
												<xsl:attribute name="frame">
													<xsl:value-of select="'#ISO-8601'"/>
												</xsl:attribute>
												<xsl:attribute name="{$gmlidatt}">
													<xsl:value-of select="string($begTIgmlid)"/>
												</xsl:attribute>
												<xsl:element name="{$timeposition}">
													<xsl:value-of select="$cleanbtime"/>
												</xsl:element>
											</xsl:when>
											<xsl:otherwise>
												<!-- can't match format with 8601...-->
												<xsl:attribute name="indeterminatePosition">
													<xsl:value-of select="'unknown'"/>
												</xsl:attribute>
												<xsl:element name="{$timeposition}">
													<xsl:value-of select="string('1900-01-01T12:00:00Z')"/>
												</xsl:element>
											</xsl:otherwise>
										</xsl:choose>
									</xsl:element>
									<!-- close TimeInstant -->
								</xsl:element>
								<!--*********************** end gml:begin -->
								
								<!-- now do the end position with proper iso8601 formatting... -->
								<xsl:variable name="endname" select="concat($theprefix, 'end')"/>
								<xsl:element name="{$endname}">
									<xsl:element name="{$timeinstantname}">
										<xsl:variable name="etpos">
											<!-- get the time value string -->
											<xsl:choose>
												<!-- TimePeriod with a beginPosition -->
												<xsl:when test="*//*[local-name() = 'beginPosition']">
													<xsl:value-of select="normalize-space(string(*//*[local-name() = 'beginPosition']))"/>
												</xsl:when>
												<!-- TimePeriod with a begin//timePosition -->
												<xsl:when test="*//*[local-name() = 'begin']//*[local-name() = 'timePosition']">
													<xsl:value-of select="normalize-space(string(*//*[local-name() = 'begin']//*[local-name() = 'timePosition']))"/>
												</xsl:when>
												<!-- TimeInstant with timePosition -->
												<xsl:when test="*//*[local-name() = 'TimeInstant']/*[local-name() = 'timePosition']">
													<xsl:value-of select="normalize-space(string(*//*[local-name() = 'TimeInstant']/*[local-name() = 'timePosition']))"/>
												</xsl:when>
											</xsl:choose>
										</xsl:variable>
										<!-- time value string  -->
										
										<!-- gml:id for the begin TimeInstant -->
										<xsl:variable name="endTIgmlid">
											<xsl:choose>
												<!-- TimePeriod with a beginPosition make new gml:id -->
												<xsl:when test="*//*[local-name() = 'endPosition']">
													<xsl:value-of select="concat('f', string(generate-id()))"/>
												</xsl:when>
												<!-- TimePeriod with a begin//timePosition; use same gml:id -->
												<xsl:when test="*//*[local-name() = 'end']//*[local-name() = 'timePosition']">
													<xsl:choose>
														<!-- take care of the gml:id, use existing in the data if there is one.. use local-name -->
														<xsl:when test="*//*[local-name() = 'end']/*[local-name() = 'TimeInstant']/@*[local-name() = 'id']">
															<xsl:value-of select="normalize-space(string(*//*[local-name() = 'end']/*[local-name() = 'TimeInstant']/@*[local-name() = 'id']))"/>
														</xsl:when>
														<xsl:otherwise>
															<xsl:value-of select="concat('b', string(generate-id()))"/>
														</xsl:otherwise>
													</xsl:choose>
													<!-- gml:id handler -->
												</xsl:when>
												<!-- TimeInstant with timePosition; use gml:ID for TimeInstant on begin of TimePeriod, 
												  generate new gml:id for the end-->
												<xsl:when test="*//*[local-name() = 'TimeInstant']/*[local-name() = 'timePosition']">
													<xsl:value-of select="concat('c', string(generate-id()))"/>
													<!-- gml:id handler -->
												</xsl:when>
											</xsl:choose>
										</xsl:variable>
										<!-- gml:id for begin TimeInstant -->
										
										<!-- clean up the time string -->
										<xsl:variable name="cleanetime">
											<xsl:call-template name="usgin:dateFormat">
												<xsl:with-param name="inputDate" select="string($etpos)"/>
											</xsl:call-template>
										</xsl:variable>
										
										<!-- add other possible gml elements if present -->
										
										<xsl:for-each select="$timeelement/gmd:extent//*[local-name()='end']/*[local-name()='TimeInstant']">
											<!-- this is just to simplify the context -->
											<xsl:apply-templates select="*[local-name() = 'metaDataProperty']"
												mode="no-namespaces"/>
											<xsl:apply-templates select="*[local-name() = 'description']"
												mode="no-namespaces"/>
											<xsl:apply-templates
												select="*[local-name() = 'descriptionReference']"
												mode="no-namespaces"/>
											<xsl:apply-templates select="*[local-name() = 'identifier']"
												mode="no-namespaces"/>
											<xsl:apply-templates select="*[local-name() = 'name']"
												mode="no-namespaces"/>
											<xsl:apply-templates select="*[local-name() = 'relatedTime']"
												mode="no-namespaces"/>
										</xsl:for-each>
										
										<xsl:choose>
											<xsl:when test="$cleanetime != string('1900-01-01T12:00:00Z')">
												<xsl:attribute name="frame">
													<xsl:value-of select="'#ISO-8601'"/>
												</xsl:attribute>
												<xsl:attribute name="{$gmlidatt}">
													<xsl:value-of select="string($endTIgmlid)"/>
												</xsl:attribute>
												<xsl:element name="{$timeposition}">
													<xsl:value-of select="$cleanetime"/>
												</xsl:element>
											</xsl:when>
											<xsl:otherwise>
												<!-- can't match format with 8601...-->
												<xsl:attribute name="indeterminatePosition">
													<xsl:value-of select="'unknown'"/>
												</xsl:attribute>
												<xsl:element name="{$timeposition}">
													<xsl:value-of select="string('1900-01-01T12:00:00Z')"/>
												</xsl:element>
											</xsl:otherwise>
										</xsl:choose>
									</xsl:element>
									<!-- close TimeInstant -->
								</xsl:element>
								<!-- gml:end  -->

								<!-- copy gml:duration or  gml:timeInterval if present -->

							</xsl:element>
							<!-- TimePeriod -->
						</xsl:when>

						<!--  gml:TimeEdge get copied-->
						<xsl:when test="$timeelement/gmd:extent/*">
							<xsl:apply-templates select="$timeelement/gmd:extent/*"
								mode="no-namespaces"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:attribute name="gco:nilReason">
								<xsl:value-of select="'Missing'"/>
							</xsl:attribute>
							<xsl:comment>temporal extent in original metadata specified with nil value or  unhandled time representation</xsl:comment>
						</xsl:otherwise>
					</xsl:choose>
				</gmd:extent>
				<xsl:if test="$timeelement/gmd:spatialExtent">
					<xsl:for-each select="$timeelement/gmd:spatialExtent">
						<gmd:spatialExtent>
							<xsl:call-template name="usgin:geographicExtent">
								<xsl:with-param name="inputExtent" select="./*"/>
							</xsl:call-template>
						</gmd:spatialExtent>
					</xsl:for-each>
				</xsl:if>

			</xsl:element>
		</gmd:temporalElement>
	</xsl:template>
	<!-- end utility template -->
	<!-- *********************** -->
	<!--                           -->
	<!-- generate a new element in the same namespace as the matched element,
     copying its attributes, but without copying its unused namespace nodes,
     then continue processing content in the "copy-no-namepaces" mode -->
	<xsl:template match="*" mode="copy-no-namespaces">
		<xsl:element name="{local-name()}" namespace="{namespace-uri()}">
			<xsl:apply-templates select="@*" mode="copy-no-namespaces"/>
			<xsl:apply-templates select="node()" mode="copy-no-namespaces"/>
		</xsl:element>
	</xsl:template>
	<!-- copy element with namespace prefix, don't put any namespace URI's in
	the output, assume all namespace prefixes are declared  -->
	<xsl:template match="*" mode="no-namespaces">
		<xsl:element name="{name()}">
			<xsl:apply-templates select="@*" mode="no-namespaces"/>
			<xsl:apply-templates select="node()" mode="no-namespaces"/>
		</xsl:element>
	</xsl:template>
	<!-- add attributes -->
	<xsl:template match="@*" mode="no-namespaces">
		<xsl:attribute name="{name()}">
			<xsl:value-of select="string(.)"/>
		</xsl:attribute>
	</xsl:template>
	<xsl:template match="comment() | processing-instruction()" mode="no-namespaces">
		<xsl:copy/>
	</xsl:template>
</xsl:stylesheet>
