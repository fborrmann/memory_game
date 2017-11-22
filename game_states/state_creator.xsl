<?xml version="1.0" encoding="UTF-8"?>
<svg width="1600" height="790" xsl:version="1.0" xmlns="http://www.w3.org/2000/svg"
	 xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xlink="http://www.w3.org/1999/xlink">
	<defs>
		<image id = "background" width="100" height="78.5" xlink:href="background.jpg"/>
	</defs>
	<use xlink:href="#background" transform="scale(16 10)" x= "0" y ="0" />
	
	<xsl:for-each select="game/cards/card">
		<use xlink:href="cards.xml#card1" transform="scale(1.5 1.5)" y="100">
   			 <xsl:attribute name="x" select="//position_x/text()"/>
		</use>
	</xsl:for-each>
</svg>
