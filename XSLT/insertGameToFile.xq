(: Vielleicht derweil mit default Werten die in ner Hilfsfunktion übergeben werden? Hab hier noch den absoluten Pfad vom letzen mal drin:)
(:
declare
%updating
%rest:path("/XSLT/newGame")
%rest:POST("{$body}")
function c:newGame($body){
  let $rows := $body//rows/text()
  let $players := $body//players/text()
  let $game := g:newGame($rows,$players)
  return ($game, file:write("C:\Users\sun\Desktop\XML XSL\foo2.xml", $game))
};
:)

let $foo := "foo" return $foo