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
  %rest:path("/XSLT/createNewGame")
  %rest:POST
  %rest:form-param("cards","{$cards}", "20")
  %rest:form-param("player1","{$player1}", "Spieler 1")
  %rest:form-param("player2","{$player2}", "Spieler 2")
  %rest:form-param("player3","{$player3}", "")
  %rest:form-param("player4","{$player4}", "")
function c:createNewGame(
  $cards as xs:integer,
  $player1 as xs:string,
  $player2 as xs:string,
  $player3 as xs:string,
  $player4 as xs:string
) {
  let $newGameId := g:newID()
  let $newGame := g:newGameXML($newGameId, $cards, $player1, $player2, $player3, $player4)
  let $insertDB := g:insertGame($newGame)
  let $setSession := session:set('gameid', $newGameId)
  return $newGame
};

declare %rest:path("/XSLT/ListSavedGames") %rest:GET function c:ListSavedGames() {
  <savedgames>{for $g in $g:instancesGame/game 
  where $g/@game_state="active"
  return <game id="{$g/@id}">{for $p in $g/players/player return string($p/name)}</game>}</savedgames>
};

declare %rest:path("/XSLT/HighScoreList") %rest:GET function c:HighScoreList() {
	<highscores class="highscores">{
	let $highScores := db:open("XSLT_highscores")
	for $player in $highScores//player
	order by xs:integer($player/points) descending
	return $player}</highscores>
};

declare %rest:path("/XSLT/UpdateHighScoreList") %rest:GET function c:UpdateHighScoreList() { 
<highscores>{
  let $highScores := db:open("XSLT_highscores")
  let $scores :=
   for $player in $highScores//player
   order by xs:integer($player/points) descending
   return $player
  let $del := (delete node $highScores//player)
for $player at $count in subsequence($scores, 1, 10)
return (<player><name>{string($player/name)}</name><points>{string($player/points)}</points><timestamp>{current-dateTime()}</timestamp></player>)}</highscores>
};

declare %rest:path("/XSLT/insertHighScore/{$gameid}") %rest:GET function c:insertHighScore($gameid as xs:integer) {
g:insertHighScores($gameid)
};


declare
%updating
%rest:path("/XSLT/welcomeScreenInfo")
%rest:GET
function c:welcomeScreenInfo() as element(screenInfo) {
<screenInfo>
  <pairs>5</pairs>
  <player1>Joe</player1>
  <player2>Tilman</player2>
  <player3>Egor</player3>
  <player4>Franziska</player4>
  <id_chosen>0</id_chosen>
  <IDs>
  {( let $game := db:open("XSLT")//game[@game_state="active"]
  	 return($game/players/player/@id/text())  	
  )}
  </IDs>
  
  {c:HighScoreList()}
  {c:ListSavedGames()}
  
</screenInfo>
};

(: start of table :)
(: ------------------------------------------------------------------------------------------ :)
declare
%updating
%rest:path("/XSLT/newGameID")
%rest:POST("{$body}")
function c:newGameID($body){
	g:startbyID($body//id_chosen)
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
	let $updtae := g:insertGame($newGameXML)	    	
  	return g:startbyData($newGameXML)
	
};
declare
%updating
%rest:path("/XSLT/click/{$id}")
%rest:GET
function c:click($id as xs:integer){
	g:flipCard($id)

};

declare
%updating
%rest:path("/XSLT/updateScreen")
%rest:GET
function c:click(){
	g:updateScreen()

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
