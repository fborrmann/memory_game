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
<style type="text/css">
  <![CDATA[
          @namespace xf url("http://www.w3.org/2002/xforms");
		  .memorycard {background: #FFFFFF; border: none;}
		  ]]></style>

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
<style type="text/css"><![CDATA[

#header {
width: 100%;
margin: 0;
padding: 20px 0;
text-align: center;
}
#logo {
width: 720px;
}

#gametable {
max-width: 900px;
min-width: 500px;
}

button {
margin: 0;
padding: 0;
display: inline;}

.memorycard {
display: inline-block;
margin: 10px 10px 10px 10px;
width: 140px;
height: 140px;
background: none;
line-height: 1.0;
}

#lastpair {
margin: 50px 0 0 50px;
}

#lastpair1, #lastpair2 {
width: 100px;
height: 100px;
background: #EEEEEE;
box-shadow: 0 4px 8px 0 rgba(0, 0, 0, 0.2), 0 6px 20px 0 rgba(0, 0, 0, 0.19);
}
#lastpair1 {
transform: rotate(-10deg);
}
#lastpair2 {
position: relative;
top: -50px;
left: 20px;
transform: rotate(5deg);
}
]]></style>
</head>


<body background="http://localhost:8984/static/data/background.jpg">
		<div id="header">
			<img alt="TUM Memory" src="http://localhost:8984/static/data/logo.svg" id="logo"/>
		</div>
      <table valign="top">
		
		    <td valign="top" style="width: 250px; padding: 10px 50px 10px 10px;">
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
		  <xsl:choose>
		  <xsl:when test="//lastpair&gt;'-1'">
			<div id="lastpair">
				<div id="lastpair1">
					<img src="http://localhost:8984/static/data/cards.svg#card{//lastpair}"/>
				</div>
				<div id="lastpair2">
					<img src="http://localhost:8984/static/data/cards.svg#card{//lastpair}"/>
				</div>
			</div>
		  </xsl:when>
		  </xsl:choose>
      	</td>
      	
      	<td id="gametable">
			  
			  
			  <xsl:for-each select="//cards/card">
        			<xsl:choose>          
        			<xsl:when test="@card_state='hidden'">
                
					<div style="position: absolute; top: {140+position_y*7}px; left: {320+position_x*7}px; width: 150px; height: 150px;">	
					  <xf:submit submission="click{@id}" appearance="xf:image">
								<xf:label>
								  <img src="http://localhost:8984/static/data/cards.svg#flipside" width="100" height="100"/>
								</xf:label>
							  </xf:submit>
					</div>
        			</xsl:when>
        			
				 <xsl:when test="@card_state='shown'">
				 <div style="position: absolute; top: {140+position_y*7}px; left: {320+position_x*7}px; width: 150px; height: 150px;">
                  <xf:submit submission="click{@id}" appearance="xf:image">
        				    <xf:label>
							  <img src="http://localhost:8984/static/data/cards.svg#card{@pair}" width="100" height="100"/>
        				    </xf:label>
        				  </xf:submit>
					</div>
        			</xsl:when>


        			</xsl:choose>
        		</xsl:for-each>	  
			  
			  
		    </td>
    	</table>


  		
</body>
</html>
         

</xsl:template>
</xsl:stylesheet>