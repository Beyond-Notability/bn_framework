---
theme: dashboard
title: (Almost) All the Dates
toc: false
---


# All The Dates

[curent version of the data essay is now [here](https://beyond-notability.github.io/beyond-notability-observable-essays/). charts here retained for reference/experimentation.]

Using [Observable Plot](https://observablehq.com/plot/) / [dodge transform](https://observablehq.com/plot/transforms/dodge)


<div class="grid grid-cols-1">
  <div class="card">
    ${resize((width) => datesChartY(dates, {width}, plotTitle, plotHeight))}
  </div>
</div>





```js 
//editables

const plotTitle = "(Almost) every date as a dot";

const plotHeight = 2000;
```



```js
// Import components
import {datesChartY} from "./components/allTheDates2.js";
```


```js
// load data
const dates = FileAttachment("./data/l_dates_precise_all.csv").csv({typed: true});
```



