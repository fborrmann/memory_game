xquery version "3.0"  encoding "UTF-8";

module namespace c = "brueggemann/guessANumber/controller";
import module namespace g = "brueggemann/guessANumber/model" at "methodsGame.xqm";
import module namespace h = "brueggemann/helpers" at "helpers.xqm";

declare namespace map = "http://www.w3.org/2005/xpath-functions/map";
declare namespace math = "http://www.w3.org/2005/xpath-functions/math";

declare variable $c:guessTheNumberXForms := doc("guessTheNumberXForms.xml");

declare
%rest:path("/guessTheNumber")
%rest:GET
function c:start() {
  $c:guessTheNumberXForms
};

(: This is called internally from the XForms form to fill its instance:)
declare
%rest:path("/guessTheNumber/welcomeScreenInfo")
%rest:GET
function c:welcomeScreenInfo() as element(screenInfo) {
<screenInfo>
  <type>welcomeScreen</type>
  <range>20</range>
  <players>5</players>
</screenInfo>
};

declare
%updating
%rest:path("/guessTheNumber/newGame")
%rest:POST("{$body}")
function c:newGame($body) {
  let $range := $body//range/text()
  let $game := g:newGame($range)
  return (<screenInfo>
    <type>firstGuessScreen</type>
    </screenInfo>, g:insertGame($game))
};

declare
%updating
%rest:path("/guessTheNumber/guess")
%rest:POST("{$body}")
function c:guess($body) {
  let $id := $body//id/text()
  let $guess := $body//guess/text()
  let $gameState := g:evaluateGuess($id,$guess)
  let $screenInfo := <screenInfo>{(
    if ($gameState//statusGame/text() = $g:continue)
      then (
        <type>furtherGuessScreen</type>,
        <guess/>
      )
      else (
        <type>resultScreen</type>,
        $gameState/statusGame,
        $gameState/secret
      )
    ,
    $gameState/id,
    $gameState/guessesSoFar,
    $gameState/maxGuesses,
    $gameState/range,
    $gameState/statusGuess
  )}</screenInfo>
  return (db:output($screenInfo),g:advanceNoGuesses($id))
};

declare
%rest:path("/guessTheNumber/quitScreenInfo")
%rest:GET
function c:quitScreenInfo() as element(screenInfo) {
<screenInfo>
  <type>quitScreen</type>
</screenInfo>
};

