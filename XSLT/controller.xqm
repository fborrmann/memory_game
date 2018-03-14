xquery version "3.0"  encoding "UTF-8";

module namespace c = "brueggemann/guessANumber/controller";
import module namespace g = "brueggemann/guessANumber/model" at "methodsGame.xqm";

declare namespace map = "http://www.w3.org/2005/xpath-functions/map";
declare namespace math = "http://www.w3.org/2005/xpath-functions/math";
import module namespace session = 'http://basex.org/modules/session';

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
  <player4>Franziska</player4>
  <id_chosen>0</id_chosen>
  <IDs>
  {( let $game := db:open("XSLT")//game[@game_state="active"]
  	 return($game/players/player/@id/text())  	
  )}
  </IDs>
  {g:HighScoreList()}
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
	let $player1 := $body//player1
	let $player2 := $body//player2
	let $player3 := $body//player3
	let $player4 := $body//player4
	let $pairs := xs:integer($body//pairs)*2
	let $newGameId := g:newID()
	let $newGameXML := g:newGameXML($newGameId, $pairs, $player1, $player2, $player3, $player4)
	let $update := g:insertGame($newGameXML)
	return g:startbyData($newGameXML)
	
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
