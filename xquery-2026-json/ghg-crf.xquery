xquery version "3.0";

module namespace ghg="http://converters.eionet.europa.eu";
import module namespace common = "ghg-common" at "ghg-common.xq";
import module namespace dd = "ghg-dd" at "ghg-dd.xq";
import module namespace html = "ghg-html" at "ghg-html.xq";
import module namespace errors = "ghg-errors" at "ghg-errors.xq";

declare variable $ghg:CURRENT_REPORTING_YEAR as xs:integer := 2024;
declare variable $ghg:QA_YEAR as xs:integer := $ghg:CURRENT_REPORTING_YEAR - 2;
declare variable $ghg:QA_PREVIOUS_YEAR as xs:integer := $ghg:QA_YEAR - 1;


declare function ghg:checkVariables($docRoot as document-node()) as element(tr)* {

    let $IPCCvars := dd:getIPCCVariables()

    let $result :=
        try {
            for $z in $IPCCvars
            let $uid := string($z/uid)
            let $name := string($z/name)

            let $localvar := $docRoot/data/variables/variable[@uid = $uid]
            let $year := $ghg:QA_YEAR
            let $yearNode := $localvar/years/year[@name = string($ghg:QA_YEAR)]
            let $value := $localvar/years/year[@name = string($ghg:QA_YEAR)]/record/value
            let $isNE := common:containsToken($value, ",", "NE")
            let $notProvided := common:nullOrEmpty($yearNode)
            where $isNE or $notProvided
            order by $isNE descending, $notProvided descending
            return
                <tr class="{$errors:WARNING}" >
                    <td title="Name of the variable">{$name}</td>
                    <td title="IPCC" class="mark">{if ($isNE) then data($value) else ""}</td>
                    <td title="Not provided" class="mark" style="text-align:center">{if ($notProvided) then "x" else ""}</td>
                </tr>
        } catch * {
            <tr class="{$errors:FAILED}">
                <td title="Error code">{$err:code}</td>
                <td title="Error description">{$err:description}</td>
            </tr>
        }
    let $count := string(count($result))
    let $errorClass := errors:getMaxError($result)
    let $ruleCode := "1"
    return
        html:build($ruleCode, "IPCC variables check:", "IPCC variables check:", $result, $count, $errorClass)
};

declare function ghg:checkEmissions($docRoot as document-node()) {

    let $variables := dd:getEmissionsVariables()
    let $result :=
        try {
            for $x in $variables
                let $uid := string($x/uid)
                let $name := string($x/name)

                let $localvar := $docRoot/data/variables/variable[@uid = $uid]
            	let $value := $localvar/years/year[@name = string($ghg:QA_YEAR)]/record/value
            	let $prevValue := $localvar/years/year[@name = string($ghg:QA_PREVIOUS_YEAR)]/record/value
                where ($value castable as xs:double) and ($prevValue castable as xs:double) and ($prevValue = $value)
                return
                <tr class="{$errors:WARNING}">
                    <td title="Name of the variable">{$name}</td>
                    <td title="{$ghg:QA_PREVIOUS_YEAR}" class="mark">{data($prevValue)}</td>
                    <td title="{$ghg:QA_YEAR}" class="mark">{data($value)}</td>
                </tr>
        } catch * {
            <tr class="{$errors:FAILED}">
                <td title="Error code">{$err:code}</td>
                <td title="Error description">{$err:description}</td>
            </tr>
        }

    let $invalidCount := string(count($result))
    let $ruleCode := "2"
    let $errorClass := errors:getMaxError($result)
    return
        html:build($ruleCode, "Identical emissions check:", "Identical emissions check:", $result, $invalidCount, $errorClass)
};

declare function ghg:proceed($url as xs:string) {
    let $docRoot := doc($url)
    let $country := common:getReportingCountry($url)
    let $obligationsUrl := common:getObligationsUrl($url)

    let $countAllValues := count($docRoot/data/variables/variable/years/year/record/value)
    let $countQAYearValues := count($docRoot/data/variables/variable/years/year[@name = string($ghg:QA_YEAR)])

    let $results := (ghg:checkVariables($docRoot), ghg:checkEmissions($docRoot))
    let $errorLevel := upper-case(errors:getMaxError($results//tbody/tr))

(:    let $errorString := normalize-space(string-join($results//p[tokenize(@class, "\s+") = $errors:ERROR], ' || '))
    let $warningString := normalize-space(string-join($results//p[tokenize(@class, "\s+") = $errors:WARNING], ' || '))
    let $failedString := string-join($results//p[tokenize(@class, "\s+") = $errors:FAILED], ' || '):)

    let $feedbackmessage :=
        if ($errorLevel = 'FAILED') then
            "This XML file generated unknown errors"
        else if ($errorLevel = 'BLOCKER') then
            "This XML file generated blocking errors"
        else if ($errorLevel = 'ERROR') then
            "This XML file generated blocking errors"
        else if ($errorLevel = 'WARNING') then
            "This XML file generated non-blocking warnings"
        else
            "This XML file passed all checks without errors or warnings"
    return
        <div class="feedbacktext">
            {html:getHead()}
            {html:getCSS()}
            <div>
                <span id="feedbackStatus" class="{$errorLevel}" style="display:none">{$feedbackmessage}</span>
                <div class="callout secondary">
                    <p>Checked XML file: {common:stripSourceUrl($url)}</p>
                    <p>The envelope is attached to the following obligations:</p>
                    <ul>
                        {for $x in $obligationsUrl
                        return
                        <li>
                            <strong>{$x}</strong>
                        </li>}
                    </ul>
                </div>
                <div class="callout secondary">
                    <p>Greenhouse gas inventories automatic checks</p>
                    <p>Two distinct checks have been applied:</p>
                    <ul>
                        <li>IPCC variables check: variables for which <a href="https://dd.eionet.europa.eu/vocabulary/ghg/IPCC_variables_MMR">"IPCC methods"</a> are available are listed under column "IPCC" in case the notation key "NE" (not estimated) is reported for the inventory year {$ghg:QA_YEAR};
                            or are listed under column "Not provided" in case the variable is not reported for the inventory year {$ghg:QA_YEAR};
                        </li>
                        <li>Identical emissions check: <a href="https://dd.eionet.europa.eu/vocabulary/ghg/emissions_variables_MMR">"emissions variables"</a> are listed if the difference between two reported numeric values for inventory year {$ghg:QA_PREVIOUS_YEAR} and inventory year {$ghg:QA_YEAR} is "zero".</li>
                    </ul>
                </div>
                <table class="maintable hover">
                    {$results}
                </table>
                <p>
                    For any questions you may contact <a href="mailto:eea-inventories@eea.europa.eu">eea-inventories@eea.europa.eu</a>
                </p>
                {html:getFoot()}
                {html:javascript()}
            </div>
        </div>
};
