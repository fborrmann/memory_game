xquery version "3.0"  encoding "UTF-8";

module namespace c = "brueggemann/guessANumber/controller";
import module namespace g = "brueggemann/guessANumber/model" at "methodsGame.xqm";
import module namespace h = "brueggemann/helpers" at "helpers.xqm";

declare namespace map = "http://www.w3.org/2005/xpath-functions/map";
declare namespace math = "http://www.w3.org/2005/xpath-functions/math";

declare variable $c:memoryXForms := doc("memoryXForms.xml");
declare variable $c:gameTableXForms := doc("gameTableXForms.xml");

declare variable $c:bild := doc("../static/data/bild.xml");

declare
%rest:path("/XSLT")
%rest:GET
function c:start() {
  $c:memoryXForms
};

(: This is called internally from the XForms form to fill its instance:)
declare
%rest:path("/XSLT/welcomeScreenInfo")
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
%rest:path("/XSLT/newGame")
%rest:GET
function c:newGame() as element(screenInfo){

<screenInfo>
        <type>firstGuessScreen</type>
        <players>5</players>
        <cards>20</cards>
  </screenInfo>
  
};

declare
%updating
%rest:path("/XSLT/guess")
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
%rest:path("/XSLT/quitScreenInfo")
%rest:GET
function c:quitScreenInfo() as element(screenInfo) {
<screenInfo>
  <type>quitScreen</type>
</screenInfo>
};

declare
%rest:path("/XSLT/showCard/{$x}/{$y}")
%rest:GET
function c:showCard($x as xs:integer, $y as xs:integer){
	g:renewSVG(),
	$c:gameTableXForms
};