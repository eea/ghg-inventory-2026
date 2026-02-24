xquery version "3.0";

module namespace common = "ghg-common";

(:~
 : Function removes the file part from the end of URL and appends 'xml' for getting the envelope xml description.
 : @param $url XML File URL.
 : @return Envelope XML URL.
 :)

declare function common:getEnvelopeXML($url as xs:string)
as xs:string
{
    let $col := fn:tokenize($url,'/')
    let $col := fn:remove($col, fn:count($col))
    let $ret := fn:string-join($col,'/')
    let $ret := fn:concat($ret,'/xml')
    return
        if (fn:doc-available($ret)) then
            $ret
        else
            ""
};

(:~
 : Function reads reproting country code from envelope xml. Returns empty string if envelope XML not found.
 : @param $url XML file URL.
 : @return ECountry code.
 :)
declare function common:getReportingCountry($url as xs:string)
as xs:string
{
    let $envelopeUrl := common:getEnvelopeXML($url)
    let $countryCode := if(string-length($envelopeUrl)>0) then fn:doc($envelopeUrl)/envelope/countrycode else ""
    return
    (: ""DE" :)
        $countryCode
};

declare function common:getObligationsUrl($url as xs:string) as xs:string* {
    let $envelopeXml := doc(common:getEnvelopeXML($url))
    return data($envelopeXml/envelope/obligation)
};

declare function common:containsValidYears($submittedYears as xs:string*, $ipccYear as xs:double) as xs:boolean
{
    let $ipccYears :=
        for $y in $submittedYears
        where $y castable as xs:integer and number($y) >= $ipccYear
        return
            $y
    return
        count($ipccYears) > 0
};

declare function common:getMostRecentSubmittedYear($submittedYears as xs:string*) as xs:double
{
    let $years :=
        for $y in $submittedYears
        where $y castable as xs:integer
        return
            number($y)
    return
        if (count($years) > 0) then
            max($years)
        else
            0
};

declare function common:isValidByIpccYear($variables as node()*, $uid as xs:string, $ipccYear as xs:double)
{
    let $variableYear := common:getMostRecentSubmittedYear($variables[@uid = $uid]/years/year/@name)
    return $ipccYear = 0 or $variableYear >= $ipccYear
};

declare function common:nullOrEmpty($stringNode) as xs:boolean {
    empty($stringNode) or $stringNode = ""
};

declare function common:containsToken($value, $separator as xs:string, $token as xs:string) as xs:boolean {
    let $tokens := tokenize($value, $separator)
    let $tokens :=
        for $i in $tokens
        return fn:normalize-space($i)
    return $tokens = $token
};

(: Formats number without rounding :)
declare function common:format-number($number, $fractions as xs:integer) {
    let $tokens := tokenize($number, "\.")
    let $i := $tokens[1]
    let $f := $tokens[2]
    return
        if (string-length($f) > 0) then
            $i || "." || substring($f, 1, $fractions)
        else
            $i
};

declare function common:stripSourceUrl($url as xs:string) {
    if (contains($url, "source_url=")) then
        substring-after($url, "source_url=")
    else
        $url
};