<?xml version="1.0" encoding="UTF-8"?>


<xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<!-- for now, match the whole xml file -->
<xsl:template match="/">

<svg width="1300" height="680" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" version="1.1">
	<defs>
		<!-- background image -->
		<image id = "background" width="100" height="78.5" xlink:href="http://localhost:8984/static/data/background.jpg"/>
		<g id = "card_flipside">
			<rect height="20" width="20" style="fill: #FFFFFF"/>
			<rect x="1" y="1" height="18" width="18" style="fill: #3070B3"/>
			<text x="4.5" y="10" style="fill: #FFFFFF; stroke: none; font-size: 4.8px; font-family: verdana;">TUM</text>
			<text x="4.5" y="13" style="fill: #FFFFFF; stroke: none; font-size: 2.5px; font-family: verdana;">Memory</text>
		</g>
		<!-- create dummy card faces for each (unique) id -->
		<xsl:for-each select ="//cards/card[not(following::card/@id = @id)]">
			<g id = "card_face_{@id}">
				<rect height="20" width="20" style="fill: #FFFFFF"/>
				<rect x="1" y="1" height="18" width="18" style="fill:#23dc92"/>
				<text x="6" y="15" style="fill: #FFFFFF; stroke: none; font-size: 10 font-family: verdana;"><xsl:value-of select="@id"/></text>
			</g>
		</xsl:for-each>
	</defs>
	<!-- set background image -->
	<use xlink:href="#background" transform="scale(15 9)" x= "0" y ="0" />
	<!-- show cards -->
	<g transform = "scale({//cards/@scale_factor} {//cards/@scale_factor})">
		<xsl:for-each select="//game/cards/card">
			<xsl:choose>
			<xsl:when test="@card_state='hidden'">
				<use xlink:href ="#card_flipside" x ="{position_x}" y="{position_y}"/>
				<a href="http://localhost:8984/XSLT/showCard/{position_x}/{position_y}" target="_top">
					<rect x ="{position_x}" y="{position_y}" height="20" width="20" style="fill: #F00FFF" opacity="0.0">
					</rect>
				</a>          
			</xsl:when>
			<xsl:otherwise>
			<use xlink:href ="#card_face_{@id}" x ="{position_x}" y="{position_y}"/>
			</xsl:otherwise>
			</xsl:choose>
		</xsl:for-each>
	</g>
</svg>

</xsl:template>
</xsl:stylesheet>