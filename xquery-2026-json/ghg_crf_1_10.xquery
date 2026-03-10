xquery version "3.1";

(: For Test :)
import module namespace ghg = "http://converterstest.eionet.europa.eu" at "ghg-crf_JSON.xquery";

(: For Production :)
(: 
import module namespace ghg = "http://converters.eionet.europa.eu"
       at "ghg-crf_JSON.xquery";
:)

declare variable $source_url as xs:string external;

declare option output:method "html";
declare option db:inlinelimit "0";


let $envelopeXmlUrl :=
    replace(concat($source_url, "/xml"), '^http://', 'https://')


let $envelope :=
    if (doc-available($envelopeXmlUrl)) then
        doc($envelopeXmlUrl)
    else
        ()

let $json-files :=
    for $f in $envelope//file
    let $link := data($f/@link)
    let $type := data($f/@type)


    where
        ends-with(lower-case($link), ".json")
        or $type = "application/json"


    return replace($link, '^http://', 'https://')

for $json-url in $json-files


let $json :=
  try {
    json-doc($json-url)
  } catch * {
    ()
  }


return ghg:proceed($json, $json-url)
