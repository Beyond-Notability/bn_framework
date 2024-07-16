---
theme: dashboard
title: Education by age
toc: false
---

# Timelines of higher education





<div class="grid grid-cols-1">
  <div class="card">
    ${resize((width) => educatedAgesChart(education, {width}))}
  </div>
</div>








```js
// Import components
import {educatedAgesChart} from "./components/education.js";
```

```js
// load data
const education = FileAttachment("data/l_dates_education/educated_degrees2.json").json({typed: true});
```


