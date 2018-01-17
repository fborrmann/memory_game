xquery version "3.0"  encoding "UTF-8";

module namespace h = "brueggemann/helpers";

declare function h:timestamp() as xs:string {
  let $random := xs:string(h:random(10000) - 1)
  return $random
};

declare function h:random($range as xs:integer) as xs:integer {
  xs:integer(ceiling(Q{java:java.lang.Math}random() * $range))
};

