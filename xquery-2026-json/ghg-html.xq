xquery version "3.1";

module namespace html = "ghg-html";
import module namespace errors = "ghg-errors" at "ghg-errors.xq";

declare function html:getHead() as element()* {
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/foundation/6.2.3/foundation.min.css">&#32;</link>
};

declare function html:getCSS() as element(style) {
    <style>
        <![CDATA[
        .bullet {
            font-size: 0.8em;
            color: white;
            padding-left:5px;
            padding-right:5px;
            margin-right:5px;
            margin-top:2px;
            text-align:center;
            width: 5%;
        }
        table.maintable.hover tbody tr th {
            text-align:left;
            width: 75%;
        }
        table.maintable.hover tbody tr {
            border-top:1px solid #666666;
        }
        table.maintable.hover tbody tr th.separator {
            font-size: 1.1em;
            text-align:center;
            color:#666666;
        }
        .datatable {
            font-size: 0.9em;
            text-align:left;
            vertical-align:top;
            /*display:none;*/
            border:0px;
        }
        .datatable tbody tr.warning td.mark {
            font-size: 1.2em;
            color:red;
        }
        .datatable tbody tr.error td.mark {
            font-size: 1.2em;
            color:red;
        }

        .datatable tbody tr {
            font-size: 0.9em;
            color:#666666;
        }
        .smalltable {
            display:none;
        }
        .smalltable tbody tr {
             font-size: 0.9em;
             color:grey;
        }
        .smalltable tbody td {
            font-style:italic;
            vertical-align:top;
        }
        .header {
            text-align:right;
            vertical-align:top;
            background-color:#F6F6F6;
            font-weight: bold;
        }
        .largeText {
            font-size:1.3em;
        }
        .box {
            padding:10px;
            border:1px solid rgba(0,0,0,0.5);
        }
        .bg-info {
            background:#A0D3E8;
        }
        .bg-error {
            background:pink;
        }
        .bg-warning {
            background:bisque;
        }
        .reveal {
            width:900px;
            border: 7px solid #cacaca;
        }
        ]]>
    </style>
};

declare function html:getFoot() as element()* {
    (<script src="https://cdn.jsdelivr.net/jquery/2.2.4/jquery.min.js">&#32;</script>,
    <script src="https://cdn.jsdelivr.net/foundation/6.2.3/foundation.min.js">&#32;</script>,
    <script type="text/javascript">
        $(document).foundation();
    </script>)
};

declare function html:getModalInfo($ruleCode, $longText) as element()* {
    (<span><a class="largeText" data-open="{concat('text-modal-', $ruleCode)}">&#8520;</a></span>,
    <div class="reveal" id="{concat('text-modal-', $ruleCode)}" data-reveal="">
        <h4>{$ruleCode}</h4>
        <hr/>
        <p>{$longText}</p>
        <button class="close-button" data-close="" aria-label="Close modal" type="button">x</button>
    </div>)
};

(: JavaScript :)
declare function html:javascript(){

    let $js :=
        <script type="text/javascript">
            <![CDATA[
    function showLegend(){
        document.getElementById('legend').style.display='table';
        document.getElementById('legendLink').style.display='none';
    }
    function hideLegend(){
        document.getElementById('legend').style.display='none';
        document.getElementById('legendLink').style.display='table';
    }
    function toggle(divName, linkName, checkId) {{
         toggleItem(divName, linkName, checkId, 'record');
    }}

   function toggleItem(divName, linkName, checkId, itemLabel) {{
        divName = divName + "-" + checkId;
        linkName = linkName + "-" + checkId;

        var elem = document.getElementById(divName);
        var text = document.getElementById(linkName);
        if(elem.style.display == "table") {{
            elem.style.display = "none";
            text.innerHTML = "Show " + itemLabel + "s";
            }}
            else {{
              elem.style.display = "table";
              text.innerHTML = "Hide " + itemLabel + "s";
            }}
      }}

      function toggleComb(divName, linkName, checkId, itemLabel) {{
        divName = divName + "-" + checkId;
        linkName = linkName + "-" + checkId;

        var elem = document.getElementById(divName);
        var text = document.getElementById(linkName);
        if(elem.style.display == "table") {{
            elem.style.display = "none";
            text.innerHTML = "Show " + itemLabel + "s";
            }}
            else {{
              elem.style.display = "table";
              text.innerHTML = "Hide " + itemLabel + "s";
            }}
      }}

            ]]>
        </script>
    return
        <script type="text/javascript">{normalize-space($js)}</script>
};

declare function html:getBullet($text as xs:string, $level as xs:string) as element(div) {
    let $color :=
        switch ($level)
            case $errors:FAILED return $errors:COLOR_FAILED
            case $errors:ERROR return $errors:COLOR_ERROR
            case $errors:WARNING return $errors:COLOR_WARNING
            case $errors:SKIPPED return $errors:COLOR_SKIPPED
            default return $errors:COLOR_INFO
    return
        <div class="{$level}" style="background-color: { $color };">{ $text }</div>
};

declare function html:build($ruleCode as xs:string, $longText, $text, $records as element(tr)*, $message as xs:string, $errorClass as xs:string) as element(tr)* {
    let $countRecords := count($records)
    let $result :=
        (
            <tr>
                <td class="bullet">{html:getBullet($ruleCode, $errorClass)}</td>
                <th colspan="2">{$text} {html:getModalInfo($ruleCode, $longText)}</th>
                <td><span class="largeText">{$message}</span>{
                    if ($countRecords > 0 or count($records)>0) then
                        <a id='feedbackLink-{$ruleCode}' href='javascript:toggle("feedbackRow","feedbackLink", "{$ruleCode}")'>Show records</a>
                    else
                        ()
                }
                </td>
            </tr>,
            if (count($records) > 0) then
                <tr>
                    <td></td>
                    <td colspan="3">
                        <table class="datatable" id="feedbackRow-{$ruleCode}" style="display:none">
                            <thead>
                                <tr>{
                                    for $th in $records[1]//td return <th>{ data($th/@title) }</th>
                                }</tr>
                            </thead>
                            <tbody>
                                {$records}
                            </tbody>
                        </table>
                    </td>
                </tr>
            else
                ()
        )
    return $result

};