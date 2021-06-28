import lxml.etree as ET

# Data file source
# wget https://www.seadatanet.org/content/download/4534/file/CDI_ISO19139_full_example_12.2.0.xml

# Transform
dom = ET.parse("./CDI_ISO19139_full_example_12.2.0.xml")
xslt = ET.parse("../ISO19139ToHTML.xsl")  ## Use the HTML transform
transform = ET.XSLT(xslt)
newdom = transform(dom)
o = (ET.tostring(newdom, pretty_print=True))
print(o.decode('ascii'))

