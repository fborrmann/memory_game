xquery version "3.0"  encoding "UTF-8";

module namespace h = "XSLT/helpers";

declare function h:timestamp() as xs:integer {
  let $random := xs:integer(h:random(10000) - 1)
  return $random
};

declare function h:random($range as xs:integer) as xs:integer {
  xs:integer(ceiling(Q{java:java.lang.Math}random() * $range))
};

