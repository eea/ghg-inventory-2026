xquery version "3.1";

module namespace common = "ghg-common";

declare function common:getSubmissionYear($json as map(*)) as xs:integer? {

  let $dataVersion := $json?version?data_version
  let $year := replace($dataVersion, ".*-(\d{4})-.*", "$1")

  return
    if ($year castable as xs:integer)
      then xs:integer($year)
    else ()
};

declare function common:stripSourceUrl($url as xs:string) {
    if (contains($url, "source_url=")) then
        substring-after($url, "source_url=")
    else
        $url
};