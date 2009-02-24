all: html

html: doc-fpgaMods.xml
	@echo "Building ----> Documentation"
	@rm -f *.html
#	@xsltproc --catalogs /usr/share/sgml/docbook/xsl-stylesheets/html/chunk.xsl doc-fpgaMods.xml
	@xsltproc --catalogs /usr/share/sgml/docbook/xsl-stylesheets/xhtml/chunk.xsl doc-fpgaMods.xml
#/usr/share/xml/gnome/xslt/docbook/common/db-chunk.xsl
