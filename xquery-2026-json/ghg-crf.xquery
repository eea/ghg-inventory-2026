xquery version "3.1";

module namespace ghg="http://converters.eionet.europa.eu";
import module namespace common = "ghg-common" at "ghg-common.xq";
import module namespace dd = "ghg-dd" at "ghg-dd.xq";
import module namespace html = "ghg-html" at "ghg-html.xq";
import module namespace errors = "ghg-errors" at "ghg-errors.xq";


(:
 QC inventory year, #298062 
Since each submission contains the full timeseries, we need a check on the data years to make sure the latest year is included (n is submission year):
Latest inventory_year = n -2
:)
declare function ghg:checkLatestInventoryYear($json as map(*)) {

  let $submissionYear := common:getSubmissionYear($json)

  let $expectedYear :=
    if (exists($submissionYear)) then $submissionYear - 2
    else ()

  let $inventoryYears := $json?data?values?*?inventory_year

  let $hasExpected :=
    some $y in $inventoryYears satisfies ($y castable as xs:integer)
    and xs:integer($y) = $expectedYear
    
    let $exists := exists($expectedYear)
    and $hasExpected

  let $result :=
    if (not($exists)) then
      <tr class="{$errors:BLOCKER}">
        <td>Latest inventory year missing</td>
        <td>Expected inventory_year: {$expectedYear}</td>
      </tr>
    else (
      <tr class="{$errors:BLOCKER}">
        <td>Latest inventory year missing</td>
        <td>Expected inventory_year: {$expectedYear}</td>
      </tr>
      
    )

  let $count := string(count($result))

  let $errorClass :=
    if ($exists) then $errors:INFO
    else $errors:BLOCKER

  return
    html:build(
      "3",
      "Latest inventory year check:",
      "This QCs return latest inventory year check:",
      $result,
      $count,
      $errorClass
    )
};


(: Main Function:)
declare function ghg:proceed($url as xs:string) {

    let $json := json-doc($url)

    let $version := $json?version
    let $data := $json?country_specific_data
    let $variables := $data?variables?*

    let $country := $version?country

    (: QCs here:)
    let $results := (
        ghg:checkLatestInventoryYear($json)
    )

    let $errorLevel := upper-case(errors:getMaxError($results//tbody/tr))

    let $feedbackmessage :=
        if ($errorLevel = 'FAILED') then
            "This JSON file generated unknown errors"
        else if ($errorLevel = 'BLOCKER') then
            "This JSON file generated blocking errors"
        else if ($errorLevel = 'ERROR') then
            "This JSON file generated blocking errors"
        else if ($errorLevel = 'WARNING') then
            "This JSON file generated non-blocking warnings"
        else
            "This JSON file passed all checks without errors or warnings"

    return
        <div class="feedbacktext">
            {html:getHead()}
            {html:getCSS()}
            <div>
                <span id="feedbackStatus" class="{$errorLevel}" style="display:none">
                    {$feedbackmessage}
                </span>

                <div class="callout secondary">
                    <p>Checked JSON file: {common:stripSourceUrl($url)}</p>
                    <p>Country: {$country}</p>
                </div>

                <table class="maintable hover">
                    {$results}
                </table>

                {html:getFoot()}
                {html:javascript()}
            </div>
        </div>
};