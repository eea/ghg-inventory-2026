xquery version "3.1";

(:~
: User: dev-gso
: Date: 12/19/16
: Time: 2:36 PM
: To change this template use File | Settings | File Templates.
:)

module namespace dd = "ghg-dd";
declare namespace skos = "http://www.w3.org/2004/02/skos/core#";
declare namespace rdf = "http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace adms="http://www.w3.org/ns/adms#";
declare namespace rdfs="http://www.w3.org/2000/01/rdf-schema#";
declare namespace dctype="http://purl.org/dc/dcmitype/";
declare namespace owl="http://www.w3.org/2002/07/owl#";
declare namespace dcterms="http://purl.org/dc/terms/";
declare namespace prop = "http://dd.eionet.europa.eu/property/";

(: declare variable $dd:VALIDRESOURCE := "http://dd.eionet.europa.eu/vocabulary/datadictionary/status/valid";
June 2022. There is a New version of <adms:status> element. Function version getting the status value directly from <adms:status>valid</adms:status>
:)
declare variable $dd:VALIDRESOURCESTATUS := "valid";
declare variable $dd:IPCCVARIABLES := "http://dd.eionet.europa.eu/vocabulary/ghg/IPCC_variables_MMR/";
declare variable $dd:EMISSIONSVARIABLES := "http://dd.eionet.europa.eu/vocabulary/ghg/emissions_variables_MMR/";


declare function dd:getValid($url as xs:string) {
(: June 2022. There is a New version of <adms:status> element. Function version getting the status value directly from <adms:status>valid</adms:status>
    doc($url || "rdf")//skos:Concept[adms:status/@rdf:resource = $dd:VALIDRESOURCE] :)
    doc($url || "rdf")//skos:Concept[adms:status = $dd:VALIDRESOURCESTATUS]
};

declare function dd:getIPCCVariables() {
    let $valid := dd:getValid($dd:IPCCVARIABLES)
    for $x in $valid
        let $variables :=
            for $i in tokenize($x, "\]")
            return substring-after($i, "[")
        let $uid := $x/skos:notation/string()
        let $name := $x/skos:prefLabel/string()
        let $category := $variables[1]
        let $classification := $variables[2]
        let $measure := $variables[3]
        let $gas := $variables[4]
        let $unit := $variables[5]
        let $source := $variables[6]
        let $method := $variables[7]
        let $target := $variables[8]
        let $option := $variables[9]
        let $type := $variables[10]
        return
            <variable>
                <uid>{$uid}</uid>
                <name>{$name}</name>
                <category>{$category}</category>
                <classification>{$classification}</classification>
                <measure>{$measure}</measure>
                <gas>{$gas}</gas>
                <unit>{$unit}</unit>
                <source>{$source}</source>
                <method>{$method}</method>
                <target>{$target}</target>
                <option>{$option}</option>
                <type>{$type}</type>
            </variable>
};

declare function dd:getEmissionsVariables() {
    let $valid := dd:getValid($dd:EMISSIONSVARIABLES)
    for $x in $valid
        let $variables :=
            for $i in tokenize($x, "\]")
            return substring-after($i, "[")
        let $uid := $x/skos:notation/string()
        let $name := $x/skos:prefLabel/string()
        let $category := $variables[1]
        let $classification := $variables[2]
        let $measure := $variables[3]
        let $gas := $variables[4]
        let $unit := $variables[5]
        let $source := $variables[6]
        let $method := $variables[7]
        let $target := $variables[8]
        let $option := $variables[9]
        let $type := $variables[10]
        return
            <variable>
                <uid>{$uid}</uid>
                <name>{$name}</name>
                <category>{$category}</category>
                <classification>{$classification}</classification>
                <measure>{$measure}</measure>
                <gas>{$gas}</gas>
                <unit>{$unit}</unit>
                <source>{$source}</source>
                <method>{$method}</method>
                <target>{$target}</target>
                <option>{$option}</option>
                <type>{$type}</type>
            </variable>
};

declare function dd:getValidConcepts($url as xs:string) as xs:string* {   
    (: June 2022. There is a New version of <adms:status> element. Function version getting the status value directly from <adms:status>valid</adms:status> 
    instead of getting it from the attribute rdf:resource: <adms:status rdf:resource="http://dd.eionet.europa.eu/vocabulary/datadictionary/status/valid"/> :) 
    (: data(doc($url)//skos:Concept[adms:status/@rdf:resource = $dd:VALIDRESOURCE]/@rdf:about) :)
    data(doc($url)//skos:Concept[adms:status = $dd:VALIDRESOURCESTATUS]/@rdf:about)
};

declare function dd:getValidNotations($url as xs:string) as xs:string* {
    (: June 2022. There is a New version of <adms:status> element. Function version getting the status value directly from <adms:status>valid</adms:status> :)
    (: data(doc($url)//skos:Concept[adms:status/@rdf:resource = $dd:VALIDRESOURCE]/skos:notation) :)
    data(doc($url)//skos:Concept[adms:status = $dd:VALIDRESOURCESTATUS]/skos:notation)
};

(: Lower case version :)
declare function dd:getValidConceptsLC($url as xs:string) as xs:string* {
    (: June 2022. There is a New version of <adms:status> element. Function version getting the status value directly from <adms:status>valid</adms:status>. Lower case version :)
    (: data(doc($url)//skos:Concept[adms:status/@rdf:resource = $dd:VALIDRESOURCE]/lower-case(@rdf:about)) :)
    data(doc($url)//skos:Concept[adms:status = $dd:VALIDRESOURCESTATUS]/lower-case(@rdf:about))
};
