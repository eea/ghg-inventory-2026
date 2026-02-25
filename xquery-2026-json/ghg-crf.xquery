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

  let $result := 
  
    try {
      let $expectedYear := if (exists($submissionYear)) then $submissionYear - 2 else ()
      let $inventoryYears := $json?data?values?*?inventory_year
      let $hasExpected :=
        some $y in $inventoryYears
        satisfies ($y castable as xs:integer and xs:integer($y) = $expectedYear)
  
      let $exists := exists($expectedYear) and $hasExpected
      return
        if (not($exists)) then
          <tr class="{$errors:BLOCKER}">
            <td title="ExpectedYear">{$expectedYear}</td>
            <td title="inventoryYears">{string-join($inventoryYears ! string(.), ", ")}</td>
            <td title="submissionYear">{$submissionYear}</td>
          </tr>
        else ()
    } catch * {
      <tr class="{$errors:FAILED}">
        <td title="Error code">{$err:code}</td>
        <td title="Error description">{$err:description}</td>
      </tr>
    }

  let $count := string(count($result))

  let $errorClass := errors:getMaxError($result)

  return html:build("InventoryYearCheck", "Latest inventory year check:", "This QCs return latest inventory year check:", $result, $count, $errorClass)
  
};

declare function ghg:checkTotalsPresence($json as map(*)) {

  let $result :=
    try {
      let $requiredUIDs := (
        "77342124-10f8-457d-9e80-11ae3a9da617",
        "3dd796c9-35f6-46c9-bff2-3f81b2a85a5f",
        "88f0dc0d-3799-4262-8442-39acc5856eac",
        "4d40dd2a-3345-4f66-b779-5cd329128148",
        "83d72864-f4f7-4847-8a93-ed8fbf7e98c2",
        "1c1b4bf7-6884-480e-accd-055af1526585"
      )

      let $submittedUIDs :=
        $json?data?values?*?values?*?variable_uid
        ! lower-case(.)

      let $hasRequired :=
        some $uid in $submittedUIDs
        satisfies $uid = $requiredUIDs

      return
        if (not($hasRequired)) then
          <tr class="{$errors:BLOCKER}">
            <td title="QC">QC totals presence</td>
            <td title="Message">No required total variable_uid found in any inventory_year</td>
          </tr>
        else (
          <tr class="{$errors:INFO}">
            <td title="QC">QC totals presence</td>
            <td title="Message">At least some matching variable_uids were found in any inventory_year</td>
          </tr>
        )

    } catch * {
      <tr class="{$errors:FAILED}">
        <td title="Error code">{$err:code}</td>
        <td title="Error description">{$err:description}</td>
      </tr>
    }

  let $count := string(count($result))

  let $errorClass := errors:getMaxError($result)

  return
    html:build("TotalsPresenceCheck", "Totals value check:", "This QC verifies that at least one required total variable_uid is present in the submission.", $result, $count, $errorClass)
};

declare function ghg:checkNodeUidNonEmpty($json as map(*)) {

  let $result :=
    try {

      let $variables :=
        $json?country_specific_data?variables?*

      let $warnings :=
        for $var at $pos in $variables
        let $isCalculated := $var?is_calculated
        let $nodeUid := $var?node_uid
        let $uid := $var?uid
        let $name := $var?name

        where
          $isCalculated = false()
          and normalize-space($nodeUid) = ""

        return
          <tr class="{$errors:WARNING}">
            <td title="uid">{$uid}</td>
            <td title="name">{$name}</td>
            <td title="message">"node_uid" is empty while "is_calculated" = false</td>
          </tr>

      return $warnings

    } catch * {
      <tr class="{$errors:FAILED}">
        <td title="Error code">{$err:code}</td>
        <td title="Error description">{$err:description}</td>
      </tr>
    }

  let $count := string(count($result))

  let $errorClass := errors:getMaxError($result)

  return
    html:build("NodeUidNonEmptyCheck", "node_uid non-empty check:", "Checks that node_uid is not empty when is_calculated = false.", $result, $count, $errorClass)
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
        ghg:checkLatestInventoryYear($json),
        ghg:checkTotalsPresence($json),
        ghg:checkNodeUidNonEmpty($json)
    )
    
    let $errorLevel := upper-case(errors:getMaxError($results//tr))

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