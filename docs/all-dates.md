---
theme: dashboard
title: (Almost) All the Dates
toc: false
---


# All The Dates

Using [Observable Plot](https://observablehq.com/plot/) / [dodge transform](https://observablehq.com/plot/transforms/dodge)

NOTE: about three dates between 1718 and 1790 have been filtered out. 


<div class="grid grid-cols-1">
  <div class="card">
    ${resize((width) => datesChartY(dates, {width}))}
  </div>
</div>



lorem ipsum blah blah.






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

