xquery version "3.0"  encoding "UTF-8";

module namespace g = "brueggemann/guessANumber/model";
import module namespace h = "XSLT/helpers" at "helpers.xqm";

declare namespace map = "http://www.w3.org/2005/xpath-functions/map";
declare namespace math = "http://www.w3.org/2005/xpath-functions/math";
import module namespace session = 'http://basex.org/modules/session';
declare variable $g:instancesGame := db:open("XSLT")//games;


declare function g:newID() as xs:integer {
  h:timestamp()
};


declare %updating function g:insertGame($game as element(game)) {
  insert node $game as first into $g:instancesGame
};

declare %updating function g:flipCard($chosenCard as xs:integer){
  let $currentGame := db:open("XSLT")//game[@id=session:get('gameId')]
  let $currentPlayer := $currentGame/active_player_id
  let $firstCard := $currentGame/flippedCard 
  let $cardFlipped := $currentGame/cards/card[@id=$chosenCard]
  
  return (
	  
		  let $in := 
		  	if ($cardFlipped/@card_state="hidden")
		  	then (
				(: bisher noch keine Karte umgedreht, erste Karte :)
				if ($currentGame/flippedCard=0) then (replace value of node $currentGame/flippedCard with $chosenCard,replace value of node $cardFlipped/@card_state with "shown", copy $c := db:open("XSLT")//game[@id=session:get('gameId')]
		   			modify (replace value of node $c/cards/card[@id=$chosenCard]/@card_state with "shown")
		    		return $c)
		  		
		  		else (
				(: bereits eine Karte umgedreht, zweite Karte :)	
					if ($currentGame/cards/card[@id=$chosenCard]/@pair = $currentGame/cards/card[@id=$firstCard]/@pair)
							then (
									(: erste und zweite Karte ergeben Paar :)
									let $checkState := (
									replace value of node $currentGame/players/player[@id=$currentPlayer]/points with $currentGame/players/player[@id=$currentPlayer]/points+2,
									replace value of node $currentGame/lastpair with $currentGame/cards/card[@id=$chosenCard]/@pair,
									replace value of node $cardFlipped/@card_state with "outofgame",
									replace value of node $currentGame/cards/card[@id=$firstCard]/@card_state with "outofgame",
									replace value of node $firstCard with 0,
									copy $c := g:checkGameState()
									modify (replace value of node $c/cards/card[@id=$chosenCard]/@card_state with "showandhide",
											replace value of node $c/cards/card[@id=$firstCard]/@card_state with "showandhide",
											replace value of node $c/players/player[@id=$currentPlayer]/points with $c/players/player[@id=$currentPlayer]/points+2)
											
									return $c)
									return if ($checkState/@game_state="finished") then (
									g:insertHighScores($checkState),
									$checkState)
									else $checkState
							)
							
							else (

									(: erste und zweite Karte ergeben kein Paar :)
									replace value of node $cardFlipped/@card_state with "hidden",
									replace value of node $currentGame/cards/card[@id=$firstCard]/@card_state with "hidden",
									replace value of node $firstCard with 0,
									replace value of node $currentPlayer with (($currentPlayer mod count($currentGame/players/player))+1),
							
							
									copy $c := db:open("XSLT")//game[@id=session:get('gameId')]
									modify (replace value of node $c/cards/card[@id=$chosenCard]/@card_state with "showandflip",
											replace value of node $c/cards/card[@id=$firstCard]/@card_state with "showandflip",
											replace value of node $c/active_player_id with (($c/active_player_id mod count($c/players/player))+1))
									return $c
							)
				
				
					
					
					)
		    	)
			else (
				(:replace value of node $cardFlipped/@card_state with "hidden", :)
		  		db:open("XSLT")//game[@id=session:get('gameId')]
		    	)	
		  let $style := doc('C:\Program Files (x86)\BaseX\webapp\static\data\svg_creator.xsl')
		  let $node := xslt:transform($in, $style)
		  let $fName := "C:\Program Files (x86)\BaseX\webapp\XSLT\game.xml"
		  let $value:= <?xml-stylesheet href="http://localhost:8984/static/xsltforms/xsltforms.xsl" type="text/xsl"?>
		  
		  return ($value, $node)
	  
   )
};

declare function g:getWinner() {
  let $currentGame := (copy $c := db:open("XSLT")//game[@id=session:get('gameId')]
	modify (replace value of node $c/players/player[@id=($c/active_player_id)]/points with $c/players/player[@id=($c/active_player_id)]/points+2)
	return $c)
  let $maxPoints := max($currentGame//player/points) 
  for $player in $currentGame//player
  where $player/points = $maxPoints
  return $player         
};


declare function g:checkGameState() {
  let $currentGame := $g:instancesGame//game[@id=session:get('gameId')]
  let $cardsCovered := count($currentGame//card[@card_state="hidden"])
  return if ($cardsCovered<=2) then (
	copy $c := $currentGame
	modify (replace value of node $c/@game_state with "finished",
			insert node <winners>{g:getWinner()}</winners> as last into $c
			)
	return $c
  )
  else $currentGame       
};



declare function g:renewSVG ($gameId as xs:integer){
let $in := db:open("XSLT")//game[@id=$gameId]
let $style := doc('C:\Program Files (x86)\BaseX\webapp\static\data\svg_creator.xsl')
let $node := xslt:transform($in, $style)
let $fName := "C:\Program Files (x86)\BaseX\webapp\XSLT\game.xml"
let $value:= <?xml-stylesheet href="http://localhost:8984/static/xsltforms/xsltforms.xsl" type="text/xsl"?>
return (replace value of node $in/@game_state with "active", $value, $node)
};


declare function g:startbyData ($gameData as element(game)){
let $setsession := session:set('gameId', xs:integer(string($gameData/@id)))
let $style := doc('C:\Program Files (x86)\BaseX\webapp\static\data\svg_creator.xsl')
let $node := xslt:transform($gameData, $style)
let $value:= <?xml-stylesheet href="http://localhost:8984/static/xsltforms/xsltforms.xsl" type="text/xsl"?>
return ($value, $node)
};

declare function g:startbyId ($gameId as xs:integer){
let $setsession := session:set('gameId', $gameId)
let $gameData := db:open("XSLT")//game[@id=$gameId]
let $style := doc('C:\Program Files (x86)\BaseX\webapp\static\data\svg_creator.xsl')
let $node := xslt:transform($gameData, $style)
let $value:= <?xml-stylesheet href="http://localhost:8984/static/xsltforms/xsltforms.xsl" type="text/xsl"?>
return ($value, $node)
};


declare function g:newGameXML($gameid as xs:integer, $cards as xs:integer, $player1 as xs:string, $player2 as xs:string, $player3 as xs:string, $player4 as xs:string) as element(game)
{
	<game id = "{$gameid}" game_state="active">
	
	<flippedCard>0</flippedCard>
    <active_player_id>1</active_player_id>
	<lastpair></lastpair>
	
      <players>
	  { if ($player1!="") then <player id="1"><name>{$player1}</name><points>0</points></player> else ""}
	  { if ($player2!="") then <player id="2"><name>{$player2}</name><points>0</points></player> else ""}
	  { if ($player3!="") then <player id="3"><name>{$player3}</name><points>0</points></player> else ""}
	  { if ($player4!="") then if ($player3!="") then <player id="4"><name>{$player4}</name><points>0</points></player>
							   else <player id="3"><name>{$player4}</name><points>0</points></player>
							   else ""}
	  </players>
	  
      <cards>
	  {g:spreadCards(xs:integer(ceiling(math:sqrt($cards))),xs:integer(ceiling(math:sqrt($cards))),random:seeded-permutation(random:integer(),g:createCards($cards)))}
	  </cards>  
    </game>
};



(: create a card :)
declare %private function g:createCard($x as xs:integer, $y as xs:integer, $pair as xs:integer, $id as xs:integer) as element(card){
  <card id="{$id}" pair="{$pair}" card_state = "hidden">
    <position_x>{$x}</position_x>
    <position_y>{$y}</position_y>
  </card>
};
(: create multiple cards :)
declare %private function g:createCards($count as xs:integer) as element(card)*{
  for $n at $pos in 0 to $count -1
    return g:createCard(0,0,(($n - ($n mod 2)) div 2),$pos)
};

(: Spread the cards in rows and collumns:)
declare %private function g:spreadCards($rows as xs:integer, $collumns as xs:integer,$cards as element(card)*) as element(card)*{
  for $card  at $pos in $cards
    let $i := ($pos -1) mod $collumns (: collum of element :)
    let $j := (($pos -1) - (($pos -1) mod $rows)) div $rows
    (: JOE: need to change "magic numbers" to an external config file:)
    let $border := 10
    let $increment := 21
    return g:createCard(
      $border + ($i * $increment) ,
      $border + ($j * $increment),
      $card/@pair,
      $card/@id)
};

declare function g:ListSavedGames() {
  <savedgames>{for $g in $g:instancesGame/game 
  where $g/@game_state="active"
  return <game id="{$g/@id}">{for $p in $g/players/player return string($p/name)}</game>}</savedgames>
};

declare function g:HighScoreList() {
	<highscores>{
	let $highScores := db:open("XSLT_highscores")
	for $player in $highScores//player
	order by xs:integer($player/points) descending
	return $player}</highscores>
};


declare function g:insertHighScores($currentGame) {
  let $maxPoints := max($currentGame//winners/points) 
  let $highScores := db:open("XSLT_highscores")
  let $countEntries := count($highScores//player)
 
  let $minScore := if (count($highScores//player)=0) then 0 else min($highScores//player/points)
  return if ($minScore <= $maxPoints or $countEntries<10) then
  for $player in $currentGame//winners/player
  return (insert node <player><name>{string($player/name)}</name><points>{string($player/points)}</points><timestamp>{current-dateTime()}</timestamp></player> as last into $highScores/highscores, g:updateHighScores())
  else 0
};

declare function g:updateHighScores() {
  let $highScores := db:open("XSLT_highscores")
  let $scores :=
   for $player in $highScores//player
   order by xs:integer($player/points) descending
   return $player
  let $del := (delete node $highScores//player)
for $player at $count in subsequence($scores, 1, 9)
return (insert node <player><name>{string($player/name)}</name><points>{string($player/points)}</points><timestamp>{current-dateTime()}</timestamp></player> as last into $highScores/highscores)
};