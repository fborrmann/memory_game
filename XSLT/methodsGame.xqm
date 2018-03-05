xquery version "3.0"  encoding "UTF-8";

module namespace g = "brueggemann/guessANumber/model";
import module namespace h = "brueggemann/helpers" at "helpers.xqm";

declare namespace map = "http://www.w3.org/2005/xpath-functions/map";
declare namespace math = "http://www.w3.org/2005/xpath-functions/math";

declare variable $g:instancesGame := db:open("XSLT")/instancesGame;


declare %private function g:newID() as xs:string {
  h:timestamp()
};

declare %updating function g:insertGame($game as element(game)) {
  insert node $game as first into $g:instancesGame
};

declare %private function g:updateGame($id as xs:string, $game as element(game)) as empty-sequence() {
  (: Replace game $id with $game in database. :)
  let $storedGame := $g:instancesGame//game[xs:string(id/text()) = $id]
  return (replace node $storedGame with $game)
};

declare function g:chooseCard($chosenCard, $gameId) {
  let $currentGame := db:open("game_states")//game[@id=$gameId]
  let $currentPlayer := $currentGame/active_player_id
  let $firstCard := $currentGame/flippedCard
  let $cardFlipped := $currentGame/cards/card[@id=$chosenCard]
  return if ($cardFlipped/@card_state="hidden") then
	if ($currentGame/flippedCard=0) then (replace value of node $currentGame/flippedCard with $chosenCard, replace value of node $cardFlipped/@card_state with "shown")
	else let $firstCardGroup := $currentGame/cards/card[@id=$firstCard]/@pair
	
		return if ($currentGame/cards/card[@id=$chosenCard]/@pair = $firstCardGroup) then (replace value of node $currentGame/players/player[@id=$currentPlayer]/points with $currentGame/players/player[@id=$currentPlayer]/points+2, replace value of node $firstCard with 0)
		else (replace value of node $cardFlipped/@card_state with "hidden", replace value of node $currentGame/cards/card[@id=$firstCard]/@card_state with "hidden", replace value of node $firstCard with 0, replace value of node $currentPlayer with ($currentPlayer mod count($currentGame/players/player))+1)
	
	else 0
};

declare %updating function g:flipCard($chosenCard as xs:integer){
  let $currentGame := db:open("XSLT")//game[@game_state="active"]
  let $currentPlayer := $currentGame/active_player_id
  let $firstCard := $currentGame/flippedCard 
  let $cardFlipped := $currentGame/cards/card[@id=$chosenCard]
  
  return (
	  if ($cardFlipped/@id = "5")
	  then(
		  let $in := db:open("XSLT")//game[@game_state="active"] 	
		  let $style := doc('C:\Program Files (x86)\BaseX\webapp\static\data\results_creator.xsl')
		  let $node := xslt:transform($in, $style)
		  let $fName := "C:\Program Files (x86)\BaseX\webapp\XSLT\game.xml"
		  let $value:= <?xml-stylesheet href="http://localhost:8984/static/xsltforms/xsltforms.xsl" type="text/xsl"?>
		  		  return ($value, $node)
	  )
	  
	  else(
		  let $in := 
		  	if ($cardFlipped/@card_state="hidden")
		  	then (
		  		replace value of node $cardFlipped/@card_state with "shown", 
		  		copy $c := db:open("XSLT")//game[@game_state="active"]
		   			modify (replace value of node $c/cards/card[@id=$chosenCard]/@card_state with "shown")
		    		return $c
		    	)
			else (
				replace value of node $cardFlipped/@card_state with "hidden", 
		  		copy $c := db:open("XSLT")//game[@game_state="active"]
		   			modify (replace value of node $c/cards/card[@id=$chosenCard]/@card_state with "hidden")
		    		return $c
		    	)	
		  let $style := doc('C:\Program Files (x86)\BaseX\webapp\static\data\svg_creator.xsl')
		  let $node := xslt:transform($in, $style)
		  let $fName := "C:\Program Files (x86)\BaseX\webapp\XSLT\game.xml"
		  let $value:= <?xml-stylesheet href="http://localhost:8984/static/xsltforms/xsltforms.xsl" type="text/xsl"?>
		  
		  return ($value, $node)
	  )
   )
};

declare function g:startbyID ($gameId as xs:integer){
let $in := db:open("XSLT")//game[@id=$gameId]
let $style := doc('C:\Program Files (x86)\BaseX\webapp\static\data\svg_creator.xsl')
let $node := xslt:transform($in, $style)
let $fName := "C:\Program Files (x86)\BaseX\webapp\XSLT\game.xml"
let $value:= <?xml-stylesheet href="http://localhost:8984/static/xsltforms/xsltforms.xsl" type="text/xsl"?>
return (replace value of node $in/@game_state with "active", $value, $node)
};

declare function g:startbyData ($gameData as element(game)){
let $style := doc('C:\Program Files (x86)\BaseX\webapp\static\data\svg_creator.xsl')
let $node := xslt:transform($gameData, $style)
let $fName := "C:\Program Files (x86)\BaseX\webapp\XSLT\game.xml"
let $value:= <?xml-stylesheet href="http://localhost:8984/static/xsltforms/xsltforms.xsl" type="text/xsl"?>
return (insert nodes $gameData as first into db:open("XSLT")/games, $value, $node)
};


(: JOE: Methods to create a new game: g:newGame, g:createCard, g:createCards, g:spreadCards:)
declare function g:newGame($rows as xs:integer, $players as xs:integer) as element(game)
{
  let $id := random:integer(100000) (: JOE: Need to add a helper to generate ID - time based?:)
  return
    <game gameID = "{$id}" game_state="active">
      <!-- JOE: create Players -->
      <players>
      {for $n in 1 to $players
        return
          <player playerID="{$n}">
            <name>Player{$n}</name>
            <points>0</points>
          </player>
      }
      </players>
      <!-- JOE: create cards -->
      <cards>
      <!-- JOE: Position will be initialised with 0 0. There are two ways two spread the cards on the table: Use CSS block layout, or fixed coordinates. The latter might be better handeled in the xslt file! -->
      <!-- JOE: multiple cards are generated and than permuated with a random seed -->
      <!-- {random:seeded-permutation(random:integer(),dg:createCards($rows * $rows))} -->
      {g:spreadCards($rows,$rows,random:seeded-permutation(random:integer(),g:createCards($rows * $rows)))}

      
      </cards>
      
    </game>
};

(: create a card :)
declare %private function g:createCard($x as xs:integer, $y as xs:integer, $pair as xs:integer, $id as xs:integer) as element(card){
  <card id="{id}" pair="{$pair}" card_state = "hidden">
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
