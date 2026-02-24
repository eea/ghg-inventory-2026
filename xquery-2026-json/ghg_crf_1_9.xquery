xquery version "3.1";

import module namespace ghg = "http://converters.eionet.europa.eu" at "ghg-crf.xquery";

declare variable $source_url as xs:string external;
declare option output:method "html";
declare option db:inlinelimit '0';

ghg:proceed($source_url)