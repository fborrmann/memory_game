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
  <!-- Precondition: range is xs:integer >= 0 -->
  <xf:submission id="newGame" method="post" resource="http://localhost:8984/XSLT/newGame"/>
  <xf:submission id="playAgain" method="get"  resource="http://localhost:8984/XSLT"/>
 
  <xsl:for-each select="//cards/card">
                <xf:submission id="click{@id}" method="get"  resource="http://localhost:8984/XSLT/click/{@id}"/>
  </xsl:for-each>	
  
  <xf:submission id="quit" method="get"  resource="http://localhost:8984/XSLT/quitScreenInfo"/>
</xf:model>

</head>


<body>
      <table width="100%" valign="top">
        <col width="20%"/>
        <col width="80%"/>
		
		    <td valign="top">
	      <table width="100%" bgcolor="#00FF00" style="font-family:arial;"> 
	        <col width="50%"/>
	        <col width="50%"/>
	        <tr>
            <td></td>
            <td>Name</td>
            <td>Punkte</td>         
          </tr>
          <xsl:for-each select="//players/player">
            <xsl:choose>
        			<xsl:when test="@id=//active_player_id">
                <tr bgcolor="#ff0000">
                   <td> Spieler <xsl:value-of select='@id'/></td>
                   <td><xsl:value-of select='name'/></td>
                   <td><xsl:value-of select='points'/></td>
                </tr> 
        			</xsl:when>
        			<xsl:otherwise>
                <tr bgcolor="#00FF00"> 
                   <td> Spieler <xsl:value-of select='@id'/></td>
                   <td><xsl:value-of select='name'/></td>
                   <td><xsl:value-of select='points'/></td>
                </tr>   
        			</xsl:otherwise>
        		</xsl:choose>             
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
      	</td>
      	
      	<td>
			  <table width="100%" style="font-family:arial;height:750px;" background="http://localhost:8984/static/data/background.jpg"> 
		        <col width="20%"/>
		        <col width="20%"/>	
		        <col width="20%"/>	
		        <col width="20%"/>
		        <col width="20%"/>
        		<xsl:for-each select="//cards/card">
        			<xsl:choose>
        			<xsl:when test="@card_state='hidden'">
                <td>
                  <xf:submit submission="click{@id}" appearance="xf:image" >
        				    <xf:label>
        				      <img src="http://localhost:8984/static/data/card_flipside.svg" width="{//cards/@scale_factor}" height="{//cards/@scale_factor}"/>
        				    </xf:label>
        				  </xf:submit>
                </td>
        			</xsl:when>
        			<xsl:otherwise>
                <td>
                  <xf:submit submission="click{@id}" appearance="xf:image">
        				    <xf:label>
        				      <img src="http://localhost:8984/static/data/card_face_{@pair}.svg" width="{//cards/@scale_factor}" height="{//cards/@scale_factor}"/>
        				    </xf:label>
        				  </xf:submit>
                </td>
        			</xsl:otherwise>
        			</xsl:choose>
        		</xsl:for-each>	      		
	      </table>
		    </td>
    	</table>


  		
</body>
</html>
         

</xsl:template>
</xsl:stylesheet>