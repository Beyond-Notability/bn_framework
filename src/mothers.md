---
theme: dashboard
title: Motherhood
toc: false
---

# Timelines of childbirth


Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.[^1] Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.[^2] 


<div class="grid grid-cols-1">
  <div class="card">
    ${resize((width) => hadChildrenAgesChart(hadChildrenAges, lastAges, workYearsWithChildren, servedYearsWithChildren, {width}))}
  </div>
</div>


Here is an inline note.^[Inlines notes are easier to write, since
you don't have to pick an identifier and move down to type the
note.]

Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. 


[^1]: [Observable Framework Markdown](https://observablehq.com/framework/markdown)
[^2]: [Footnote extension for OF](https://observablehq.observablehq.cloud/framework-example-markdown-it-footnote/)


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
