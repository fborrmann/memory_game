xquery version "3.0"  encoding "UTF-8";

module namespace g = "brueggemann/guessANumber/model";
import module namespace h = "brueggemann/helpers" at "helpers.xqm";

declare namespace map = "http://www.w3.org/2005/xpath-functions/map";
declare namespace math = "http://www.w3.org/2005/xpath-functions/math";

(: open database XSLT, locate ressource within database and navigate to its top element :)
declare variable $g:instancesGame := db:open("XSLT")/instancesGame;

(: TODO: remove variables g:correct and g:continue in refactored version :)
declare variable $g:high := "HIGH";
declare variable $g:low := "LOW";
declare variable $g:correct := "CORRECT";
declare variable $g:win := "WIN";
declare variable $g:lose := "LOSE";
declare variable $g:continue := "CONTINUE";
declare variable $g:active := "ACTIVE";
declare variable $g:over := "OVER";

declare %private function g:numberGuesses($range as xs:integer) as xs:integer {
  (: A class method to compute the number of guesses that are sufficient to guess
   : a secret number in [1,$range].
   : The formula is floor(ld($range)) + 1.
   : Using precomputed conversion factor log10 --> ld.
   :)
  xs:integer(floor(math:log10($range)*3.32193)) + 1
};

(: The two functions g:newGame and g:insertGame together represent the Game constructor. :)
(: newID is a helper class method :)
declare %private function g:newID() as xs:string {
  h:timestamp()
};
declare function g:newGame($range as xs:integer) as element(game) {
  let $id := g:newID()
  return
    <game>
      <id>{$id}</id>
      <range>{$range}</range>
      <secret>{h:random($range)}</secret>
      <maxGuesses>{g:numberGuesses($range)}</maxGuesses>
      <guessesSoFar>0</guessesSoFar>
      <status>{$g:active}</status>
    </game>
};
declare %updating function g:insertGame($game as element(game)) {
  insert node $game as first into $g:instancesGame
};

declare %private function g:getGame($id as xs:string) as element(game) {
  (: internal use only :)
  $g:instancesGame//id[.=$id]/..
};

(: Computes new gameState (after handling the guess) but does not update guessesSoFar. :)
declare
function g:evaluateGuess($id as xs:string, $guess as xs:integer) {
  let $game := g:getGame($id)
  let $statusGuess :=
    <statusGuess>{g:statusGuess($game,$guess)}</statusGuess>
  let $statusGame := <statusGame>{g:statusGame($game,$statusGuess/text())}</statusGame>
  let $guessesSoFar :=
    <guessesSoFar>{
      xs:string(xs:integer($game/guessesSoFar/text()) + 1)
    }</guessesSoFar>
  let $secret := if ($statusGame/text() = $g:continue) then () else $game/secret
  return
    <gameState>{(
      $game/id,
      $guessesSoFar,
      $game/maxGuesses,
      $game/range,
      $statusGame,
      $statusGuess,
      $secret
    )}</gameState>
};

declare
%private
function g:statusGuess($game as element(game), $guess as xs:integer) as xs:string {
  (: Returns one of the pre-defined strings $g:high, $g:low or $g:correct. :)
  let $secret := xs:integer($game/secret/text())
  return if ($guess = $secret) then $g:correct else if ($guess < $secret) then $g:low else $g:high
};

declare
%private
function g:statusGame($game as element(game), $statusGuess as xs:string) as xs:string {
  (:
   : This method is called as part of handling a user guess.
   : The current number of guesses has not tallied the current guess at this point.
   :)
  let $anotherGuessAllowed := (xs:integer($game/guessesSoFar) + 1 < xs:integer($game/maxGuesses))
  return
    if ($statusGuess = $g:correct) then $g:win else if ($anotherGuessAllowed) then $g:continue else $g:lose
};

declare %updating function g:advanceNoGuesses($id as xs:string) {
  let $noGuessesNode := g:getGame($id)/guessesSoFar
  let $newNoGuesses := xs:string(xs:integer($noGuessesNode/text()) + 1)
  return replace value of node $noGuessesNode with $newNoGuesses
};


(: TODOs for supporting dashboard
g:isOver($id as xs:string) as xs:boolean (: guessesSoFar >= maxGuesses :)
% updating g:removeGame($id as xs:string)
g:listGames() as sequence of maps
%private g:listGameIDs() as sequence of strings (: helper for g:listGames() :)
:)

declare
%rest:path("/XSLT/test/createGame/range/{$range}")
%rest:GET
%private
function g:createGame($range as xs:integer) as element(game) {
  let $id := g:newID()
  return
    <game>
      <id>{$id}</id>
      <range>{$range}</range>
      <secret>{h:random($range)}</secret>
      <maxGuesses>{g:numberGuesses($range)}</maxGuesses>
      <guessesSoFar>0</guessesSoFar>
      <state>$g:active</state>
    </game>
};

declare
%rest:path("/XSLT/test/newGame/range/{$range}")
%rest:GET
function g:newGameNew($range as xs:integer) as element(gameStatus) {
(:~
 : Create a new game element from $range, insert it into the database of games
 : and return its game status representation.
 :)
  (: create a new game from $range :)
  let $newGame:=g:createGame($range)
  (: insert $newGame into database of games :)
  let $_notNeeded:=g:insertGameNew($newGame)
  (: TODO: convert $newGame into a game status element and return that :)
  return g:getGameStatusStatic($newGame)
};

declare %private function g:insertGameNew($game as element(game)) as empty-sequence() {
  let $insertRequest :=
    <http:request method="POST"
      username="admin"
      password="admin"
      send-authorization="true"
      href="http://localhost:8984/XSLT/intern/insertGameViaHTTP">
    <http:body media-type="application/xml">
      {$game}
    </http:body>
    </http:request>
  let $_notNeeded := http:send-request($insertRequest)
  return ()
};

declare
%rest:path("/XSLT/intern/insertGameViaHTTP")
%rest:POST("{$body}")
%updating
%private
function g:insertGameViaHTTP($body) {
  let $game:=$body//game
  return (insert node $game as first into $g:instancesGame)
};

declare %private function g:gameEvalStatic(
  $state as element(state), $guessEval as element(guessEval)
  ) as element(gameEval)? {
  (: Computes, if game is over, if it was won or lost by player,
     returning the empty sequence if game is still active or otherwise
     the game result "win" or "lose", wrapped into an element gameEval.
   :)
  if ($state/text()=$g:active)
    then ()
    else <gameEval>{if ($guessEval) then "lose" else "win"}</gameEval>
};

declare %private function g:getGameStatusStatic($game as element(game)) as element(gameStatus) {
  (: This function, on condition of $game data, creates a new element gameEval
   : and removes sub-element secret from $game; it always removes sub-element state;
   : it then wraps the remaining subelements into a gameStatus container.
   :)
   let $gameEval := g:gameEvalStatic($game/state,$game/guessEval)
   let $secret := if ($gameEval) then $game/secret else ()
   return <gameStatus>{($game/*[not((local-name()="secret") or (local-name()="state"))],
     $secret,$gameEval)}</gameStatus>
};

declare %private function g:getGameStatus($id as xs:string) as element(gameStatus) {
  (: An object version of static g:getGameStatusStatic. :)
  g:getGameStatusStatic(g:getGame($id))
};

declare
%rest:path("/XSLT/test/processGuess/id/{$id}/guess/{$guess}")
%rest:GET
function g:processGuess($id as xs:string, $guess as xs:integer) {
(:~
 : Process guess for game $id and return its new game status representation;
 : assume that the game is active.
 :)
  let $game:=g:getGame($id)
  (: assert $game/state/text = $g:active :)
  let $guessesSoFarNewInt := xs:integer($game/guessesSoFar/text()) + 1
  let $secretInt := xs:integer($game/secret/text())
  let $guessEvalNew := if ($guess = $secretInt)
    then ()
    else <guessEval>{
      if ($guess < $secretInt) then $g:low else $g:high
    }</guessEval>
  let $stateNew := <state>{
      if (($guessesSoFarNewInt >= xs:integer($game/maxGuesses/text())) or not($guessEvalNew) )
        then $g:over else $g:active
    }</state>
  let $gameNew := <game>{
      ($game/id, $game/range, $game/secret, $game/maxGuesses,
        <guessesSoFar>{xs:string($guessesSoFarNewInt)}</guessesSoFar>,
        $stateNew, $guessEvalNew)
    }</game>
  let $notNeeded := g:updateGame($id,$gameNew)
  return <oldPlusNewGame>{$game,$gameNew}</oldPlusNewGame>
};

declare %private function g:updateGame($id as xs:string, $game as element(game)) as empty-sequence() {
  (: Replace game $id with $game in database. :)
  let $storedGame := $g:instancesGame//game[xs:string(id/text()) = $id]
  return (replace node $storedGame with $game)
};
