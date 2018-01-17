(:
 : testing a variable whose value is the empty sequence
 : converting elements to data types
 :)
let $elemA := doc("globalsGame.xml")
let $empty := $elemA/xxx
return (
  if (not($empty)) then "OK" else "surprise",
  <shouldBeEmpty>{$empty}</shouldBeEmpty>,
  xs:integer(<abc>7</abc>) + 1
  )
