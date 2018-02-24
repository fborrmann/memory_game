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
%rest:path("/XSLT/welcomeScreenInfo")
%rest:GET
function c:welcomeScreenInfo() as element(screenInfo) {
<screenInfo>
  <range>20</range>
  <players>5</players>
</screenInfo>
};

(: start of table :)
(: ------------------------------------------------------------------------------------------ :)
declare
%updating
%rest:path("/XSLT/newGame")
%rest:GET
function c:newGame(){
	g:renewSVG(),
	$c:game
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
