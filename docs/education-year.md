---
theme: dashboard
title: Education by year 
toc: false
---

# Timelines of higher education


```js
// Import components
import {educatedYearsChart} from "./components/education.js";
```

```js
// load data
const education2 = FileAttachment("data/l_dates_education/educated_degrees2.json").json({typed: true});

```





<div class="grid grid-cols-1">
  <div class="card">
    ${resize((width) => educatedYearsChart(education2, {width}))}
  </div>
</div>







