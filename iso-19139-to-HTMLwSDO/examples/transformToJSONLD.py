import lxml.etree as ET

# Data file source
# wget https://www.seadatanet.org/content/download/4534/file/CDI_ISO19139_full_example_12.2.0.xml

# Transform
dom = ET.parse("./CDI_ISO19139_full_example_12.2.0.xml")
xslt = ET.parse("../ISO19139ToSDODatasetStandalone1.0.xslt") ## convert to JSON-LD schema.org voc
transform = ET.XSLT(xslt)
newdom = transform(dom)
print(newdom)
 