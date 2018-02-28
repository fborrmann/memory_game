xquery version "3.0"  encoding "UTF-8";

module namespace c = "brueggemann/guessANumber/controller";
import module namespace g = "brueggemann/guessANumber/model" at "methodsGame.xqm";

declare namespace map = "http://www.w3.org/2005/xpath-functions/map";
declare namespace math = "http://www.w3.org/2005/xpath-functions/math";

declare variable $c:lobby := doc("lobby.xml");
declare variable $c:game := doc("game.xml");
declare variable $c:results := doc("results.xml");

(: start and welcome screen :)
(: ------------------------------------------------------------------------------------------ :)
declare
%rest:path("/XSLT")
%rest:GET
function c:start() {
  $c:lobby
};

declare
%updating
%rest:path("/XSLT/welcomeScreenInfo")
%rest:GET
function c:welcomeScreenInfo() as element(screenInfo) {
<screenInfo>
  <pairs>2</pairs>
  <player1>Joe</player1>
  <player2>Tilmann</player2>
  <player3>Egor</player3>
  <id_chosen>0</id_chosen>
  <IDs>
  {( let $game := db:open("XSLT")//game[@game_state="active"]
  	 return($game/players/player/@id/text())  	
  )}
  </IDs>
  <highscore>
  {( let $game := db:open("XSLT")//game
  	 return(max($game/players/player/points))  	
  )}
  </highscore>
</screenInfo>
};

(: start of table :)
(: ------------------------------------------------------------------------------------------ :)
declare
%updating
%rest:path("/XSLT/newGameID")
%rest:POST("{$body}")
function c:newGameID($body){
	g:renewSVG($body//id_chosen)
};

declare
%updating
%rest:path("/XSLT/newGameNew")
%rest:POST("{$body}")
function c:newGameNew($body){
	let $gameData := $body//pairs
	(: let $in := copy $c := $body//pairs
		   			modify (replace node doc("C:\Users\sun\Desktop\XML XSL\foo2.xml") with $c)
		    		return $c
	:)
		    	
  	return g:renewSVG($body//id_chosen)
	
};
declare
%updating
%rest:path("/XSLT/click/{$id}")
%rest:GET
function c:click($id as xs:integer){
	g:flipCard($id)

};

(: quit screen :)
(: ------------------------------------------------------------------------------------------ :)
declare
%updating
%rest:path("/XSLT/quitScreenInfo")
%rest:GET
function c:quitScreenInfo(){
	$c:results
};
