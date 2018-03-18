<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:template match="/">

<xsl:text disable-output-escaping="yes"></xsl:text>

<html
  xmlns="http://www.w3.org/1999/xhtml"
  xmlns:xf="http://www.w3.org/2002/xforms"
>

<head>
  <title>Memory</title>


<xf:model>
  <xf:instance xmlns=""/>
  <xf:submission id="playAgain" method="get"  resource="http://localhost:8984/XSLT"/>
  <xf:submission id="quit" method="get"  resource="http://localhost:8984/XSLT/quitScreenInfo"/>
</xf:model>

</head>


<body>
      <table width="100%" valign="top" bgcolor="#00FF00" style="font-family:arial;">
        <col width="20%"/>
        <col width="20%"/>
        <col width="60%"/>
		    <tr><td>Ergebnisse</td></tr>
        <tr><td>Gewinner:</td><td><xsl:value-of select='//players/player[points=max((//players/player/points))]/name'/></td></tr>
        <xsl:for-each select="//players/player">
          <tr> 
            <td> Spieler <xsl:value-of select='@id'/></td>
            <td><xsl:value-of select='name'/></td>
            <td><xsl:value-of select='points'/></td>
          </tr> 
        </xsl:for-each>
	        <tr>
		        <td><xf:submit submission="playAgain">
		          <xf:label>play again</xf:label>
		        </xf:submit></td>
	        </tr>
	        <tr>
	          <td><xf:submit submission="quit">
		          <xf:label>quit</xf:label>
		      </xf:submit></td>
	        </tr>
    	</table>


  		
</body>
</html>
         

</xsl:template>
</xsl:stylesheet>