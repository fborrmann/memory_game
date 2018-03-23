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

body {
font-family: verdana, arial;
color: #606060;
padding: 0 20px;
}

h2 {
	font-size: 120%;
	color: #3070B3;
	}

#header {
width: 100%;
margin: 0;
padding: 20px 0;
text-align: center;
}
#logo {
width: 720px;
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

#infoboard {
width: 300px;
background: #FFFFFF;
box-shadow: 0 4px 8px 0 rgba(0, 0, 0, 0.2), 0 6px 20px 0 rgba(0, 0, 0, 0.19);
padding: 15px;
}

.player {
font-weight: bold;
color: #606060;
}

.player td {
padding: 5px;
}

.active_player {
color: #FFFFFF;
background-color: #3070B3;
}

.button {
	display: block;
	margin: 5px 0 5px 150px;
	padding: 5px;
	font-size: 16px;
	width: 100px;
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

.showandhide, .showandflip {
background: #EEEEEE;
width: 100px;
height: 100px;
padding: 0;
margin: 0;
border: 1px solid #808080;
position: relative;
}

.hideandflip {
display: none;
}

#game_finished {
width: 600px;
height: 300px;
position: absolute;
top: 200px;
left: 400px;
background: #FFFFFF;
box-shadow: 0 4px 8px 0 rgba(0, 0, 0, 0.2), 0 6px 20px 0 rgba(0, 0, 0, 0.19);
padding: 15px;
}

.winnerpoints::before { 
    conent: " (";
	}

]]></style>
<script src="https://code.jquery.com/jquery-3.1.1.min.js"></script> 
</head>


<body background="http://localhost:8984/static/data/background.jpg">
		<div id="header">
			<img alt="TUM Memory" src="http://localhost:8984/static/data/logo.svg" id="logo"/>
		</div>
		
		
      
		
		  <div id="infoboard">
		  <h2>Spielstatus</h2>
	      <table width="100%" border="0" cellpadding="0" cellspacing="0"> 
	        <col width="70%"/>
	        <col width="30%"/>
	        
			<tr>
            <td></td>
            <td>Punkte</td>         
			</tr>
			
          <xsl:for-each select="//players/player">
            <xsl:choose>
        			<xsl:when test="@id=//active_player_id">
                <tr class="player active_player">
                   <td><xsl:value-of select='name'/></td>
                   <td><xsl:value-of select='points'/></td>
                </tr> 
        			</xsl:when>
        			<xsl:otherwise>
                <tr class="player"> 
                   <td><xsl:value-of select='name'/></td>
                   <td><xsl:value-of select='points'/></td>
                </tr>   
        			</xsl:otherwise>
        		</xsl:choose>             
        	</xsl:for-each>
	        
	       
	      </table>
		  
		  <xf:submit submission="playAgain" class="button">
		          <xf:label >Spiel verlassen</xf:label>
		   </xf:submit>
		  
		  <!--<xf:submit submission="quit">
		          <xf:label>quit</xf:label>
		      </xf:submit>-->
		  
		  </div>
		  
		  
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
		  
		  <xsl:otherwise>
			<div id="lastpair">
				<div id="lastpair1" style="display: none;"></div>
				<div id="lastpair2" style="display: none;"></div>
			</div>
		  </xsl:otherwise>
		  
		  </xsl:choose>
      	
      	
			  
			  
			  <xsl:for-each select="//cards/card">
        			
                
					<div style="position: absolute; top: {140+position_y*7}px; left: {320+position_x*7}px; width: 150px; height: 150px;">
					
					<xsl:choose>          
        			<xsl:when test="@card_state='hidden'">
					
					  <xf:submit submission="click{@id}" appearance="xf:image">
								<xf:label>
								  <img src="http://localhost:8984/static/data/cards.svg#flipside" width="100" height="100"/>
								</xf:label>
							  </xf:submit>
					</xsl:when>
					
					<xsl:when test="@card_state='shown'">
							<xf:submit submission="click{@id}" appearance="xf:image">
        				    <xf:label>
							  <img src="http://localhost:8984/static/data/cards.svg#card{@pair}" width="100" height="100"/>
        				    </xf:label>
        				  </xf:submit>
					</xsl:when>
					
					<xsl:when test="@card_state='showandhide'">
							
							  <div class="showandhide" id="showandhide"><img src="http://localhost:8984/static/data/cards.svg#card{@pair}" width="100" height="100"/></div>
        				    
					</xsl:when>
					
					<xsl:when test="@card_state='showandflip'">
							
							  
							  <div class="hideandflip">
							  <xf:submit submission="click{@id}" appearance="xf:image">
									<xf:label>
									  <img src="http://localhost:8984/static/data/cards.svg#flipside" width="100" height="100"/>
									</xf:label>
							  </xf:submit>
							  </div>
							  <div class="showandflip"><img src="http://localhost:8984/static/data/cards.svg#card{@pair}" width="100" height="100"/></div>
        				    
					</xsl:when>
					
					</xsl:choose> 
					</div>
        			
        			
				
        		</xsl:for-each>	  
			  
				<xsl:choose>
					  <xsl:when test="//@game_state='finished'">
							<div id="game_finished">
							<h2>Fertig!</h2>
							
							<p>Gewonnen hat:</p>
							
							<xsl:for-each select="//winners/player">
							
									   <p>
									   <xsl:value-of select='name'/><td> </td> <span class="winnerpoints"><td> </td> mit<td> </td> <xsl:value-of select='points'/><td> </td> Punkten</span>
									   </p>
													
							</xsl:for-each>
							
							
							</div>
					  </xsl:when>
				</xsl:choose>	
<script>		
		$(function () { 
		if ( $( ".showandhide" ).length ) {	
		$('.showandhide').delay(1000).fadeOut( 500 , function() {
		$('#lastpair1').html($('.showandhide').html());
		$('#lastpair2').html($('.showandhide').html());
		$('#lastpair1').show();
		$('#lastpair2').show();
		});		
		}		
	  });

	  $(function () {  
		$('.showandflip').delay(1000).fadeOut( 500 , function() {
		$('.hideandflip').delay(1000).show();
		});		
	  });
     
	  
</script>
  		
</body>
</html>
         

</xsl:template>
</xsl:stylesheet>