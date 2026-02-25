xquery version "3.1";

module namespace errors = "ghg-errors";

declare variable $errors:WARNING := "warning";
declare variable $errors:ERROR := "error";
declare variable $errors:INFO := "info";
declare variable $errors:SKIPPED := "skipped";
declare variable $errors:UNKNOWN := "unknown";
declare variable $errors:BLOCKER := "blocker";
declare variable $errors:FAILED := "failed";

declare variable $errors:COLOR_WARNING := "orange";
declare variable $errors:COLOR_ERROR := "red";
declare variable $errors:COLOR_INFO := "deepskyblue";
declare variable $errors:COLOR_SKIPPED := "grey";
declare variable $errors:COLOR_UNKNOWN := "grey";
declare variable $errors:COLOR_BLOCKER := "red";
declare variable $errors:COLOR_FAILED := "firebrick";

declare variable $errors:LOW_LIMIT := 100;
declare variable $errors:MEDIUM_LIMIT := 250;
declare variable $errors:HIGH_LIMIT := 500;
declare variable $errors:HIGHER_LIMIT := 1000;
declare variable $errors:MAX_LIMIT := 1500;

(: Returns error class if there are more than 0 error elements :)
declare function errors:getClass($elems) {
    if (count($elems) > 0) then
        "error"
    else
        "info"
};

declare function errors:getClassColor($class as xs:string) {
    switch ($class)
        case $errors:FAILED return $errors:COLOR_FAILED
        case $errors:BLOCKER return $errors:COLOR_BLOCKER
        case $errors:ERROR return $errors:COLOR_ERROR
        case $errors:WARNING return $errors:COLOR_WARNING
        case $errors:INFO return $errors:COLOR_INFO
        default return $errors:COLOR_SKIPPED
};

declare function errors:getMaxError($rows as element(tr)*) as xs:string {

  if (exists($rows[@class = $errors:FAILED])) then $errors:FAILED
  else if (exists($rows[@class = $errors:BLOCKER])) then $errors:BLOCKER
  else if (exists($rows[@class = $errors:ERROR])) then $errors:ERROR
  else if (exists($rows[@class = $errors:WARNING])) then $errors:WARNING
  else if (exists($rows[@class = $errors:SKIPPED])) then $errors:SKIPPED
  else $errors:INFO
  
};
