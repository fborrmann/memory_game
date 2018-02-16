xquery version "3.0" encoding "UTF-8";

module namespace bcrtl = "some/demoA/demobcrtl";

(:Inital starting point for program, calling xhtml file with GUI:)
declare
%rest:path("/demoB")
%rest:GET
function bcrtl:start(){
  doc("page0.xml")  
};

(: switch to first page:)
declare
%rest:path("/demoB/page1")
%rest:GET
function bcrtl:showPage1(){
  doc("page1.xml")
};

(: switch to second page:)
declare
%rest:path("/demoB/page2")
%rest:GET
function bcrtl:showPage2(){
  doc("page2.xml")
};

(: switch to starting page (zero):)
declare
%rest:path("/demoB/page0")
%rest:GET
function bcrtl:showPage0(){
  doc("page0.xml")
};







