---
theme: dashboard
title: All the Dates (v2)
toc: false
---


# (Almost) All The Dates

Using [Observable Plot](https://observablehq.com/plot/) / [dodge transform](https://observablehq.com/plot/transforms/dodge)


NOTE: in this version dates are correctly parsed, but it causes the chart to be both more spread out and longer. (About three dates between 1718 and 1790 have been filtered out.) 

<div class="grid grid-cols-1">
  <div class="card">
    ${resize((width) => datesChartY(dates, {width}))}
  </div>
</div>



lorem ipsum etc etc.






```js
// Import components
import {datesChartY} from "./components/allTheDates2.js";
```

```js
// load data
const dates = FileAttachment("./data/l_dates_precise_all.csv").csv({typed: true});
```

<!-- 
data variables
precise
"person"          "personLabel"     
"date"            "year"    "month"           "day"             "m"              
"nice_date"       
"date_precision"  "date_certainty" 
"date_label"      "date_level"      "date_string"    "qual_date_prop" 
"date_propLabel" "date_prop"   "prop_label"     "category"         
"prop_valueLabel"  "prop_value" 
"s"  
-->

