---
theme: dashboard
title: Motherhood
toc: false
---

# Timelines of childbirth


```js
// Import components
import {hadChildrenAgesChart} from "./components/mothers.js";
```

```js
//load data [dataloader uses zip method to create multiple objects]

const hadChildrenAges = FileAttachment("data/l_women_children/had-children-ages.csv").csv({typed: true});

const workYearsWithChildren = FileAttachment("data/l_women_children/work-years-with-children.csv").csv({typed:true});

const servedYearsWithChildren = FileAttachment("data/l_women_children/served-years-with-children.csv").csv({typed:true});

const lastAges = FileAttachment("data/l_women_children/consolidated-last-ages.csv").csv({typed:true});

```



<div class="grid grid-cols-1">
  <div class="card">
    ${resize((width) => hadChildrenAgesChart(hadChildrenAges, lastAges, workYearsWithChildren, servedYearsWithChildren, {width}))}
  </div>
</div>


