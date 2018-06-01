# Files for html display of ISO19139 and 19139-1  xml records

The html documents will have a JSON-LD Script in the html header with a schema.org
version of the metadata following conventions developed by the NSF EarthCube P418 project

What's here

## ISO19139ToHTML.xsl

Base transform for converting ISO xml to html. Extensively modified from transform originated by Jacqui Mize at NOAA. This transform imports the various xsl files in the imports subdirectory, as well as the ISO19139ToSchemaOrgDataset1.0.xslt transform.

## ISO19139ToHTMLwMap.xsl

Base transform for converting ISO xml to html. The trasform uses the javascript code copied from IEDA to present a map showing the location of the resource if there is a gmd:EX_Extent with a GeographicBoundingBox element or Point locations stored in gml:Polygon elements.  
Extensively modified from transform originated by Jacqui Mize at NOAA. This transform imports the various xsl files in the imports subdirectory, as well as the ISO19139ToSchemaOrgDataset1.0.xslt transform.

## ISO19139ToSchemaOrgDataset1.0.xslt

XML transform to generate Schema.org Dataset JSON-LD metadata serialization from ISO xml metadata format.

## imports

Subdirectory containing various files required for the ISO xml to html transformation.

### general.xslt 

Transform defines import elements for stylesheets and scripts; doesn't include scripts for map widget.

### generalwMap.xslt 

Transform defines import elements for stylesheets and scripts; Javascript to generate map is imported here.
datadoi.css style sheet from IEDA has been inserted inline in the styles template.

### iso19139usginMap.xslt

this is where most of the transformation work is done; imports the other xslt's in the import directory

### private.xslt

defines variables for API keys or other secrets that should not be visible in public githup. This file is included 
in .gitignore

### private-template.xslt

template xslt that will be included in repository clones.  change name to private.xslt in your checkout of the repo when you want to deploy or test. Put your keys in the indicated variables. 

### other support files

These are unmodified from the original package produced by JM at NOAA: 

auxCountries.xslt, auxLanguages.xslt, auxUCUM.xslt are lookup files for standard abbreviations.

codelists.xslt, XML.xslt handlers for commonly used elements.

## Files for map display in html view:

If the ISO xml contains spatial extents encoded either as a bounding box or as gmd:polygon//gmd:Point, a map will be displayed in the landing page. The scripts were written by developers at IEDA and are used in the IEDA dataset landing pages. Minor modifications were necessary for use here; changes are noted in comments in the code. Note that coordinate locations at the poles are not handled.

### doimap.js

Handles drawing extent geometries on the basemap

### basemap_v3.js

Sets up the base map, using WMS tiles from the GMRT OGC web map service.

### jquery-1.9.1.js, jquery-ui-1.10.2.custom.min.js 

Handlers for jquery. No modifications in these scripts for use here, they are cached to make sure we have the correct versions.


# Deployment

This package is designed to deploy on a LAMP or WAMP server, tested with php 5.1.6 (LAMP, RedHat) and 5.6.31 (WAMP, Windows 10).   Getting the maps to display can be tricky, I don't understand fully all the environmental requirements...
