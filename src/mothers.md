---
theme: dashboard
title: Motherhood
toc: false
---

# A timeline of childbirth

[curent version of the data essay is now [here](https://beyond-notability.github.io/beyond-notability-observable-essays/). this chart retained for reference/experimentation.]



```js
//toggle
const checkMothers = view(makeCheckbox) ;
```
<div class="grid grid-cols-1">
  <div class="card">
    ${resize((width) => hadChildrenAgesChart(hadChildrenAges, lastAges, flatMothers,  {width}, plotTitle, plotHeight))}
  </div>
</div>



```js
// editables

const plotTitle = "The ages at which BN women had children, sorted by mothers' dates of birth";

const plotHeight = 1500;
```

```js
// Import components
import {hadChildrenAgesChart} from "./components/mothers.js";
```

```js
//load data [dataloader uses zip method to create multiple objects]

const hadChildrenAges = FileAttachment("data/l_women_children/had-children-ages.csv").csv({typed: true});

//const workServedYearsWithChildren = FileAttachment("data/l_women_children/work-served-years-with-children.csv").csv({typed:true});

const workServedSpokeYearsWithChildren = FileAttachment("data/l_women_children/work-served-years-with-children.csv").csv({typed:true})

const lastAges = FileAttachment("data/l_women_children/last-ages-all.csv").csv({typed:true});

```






```js
// make checkbox
const makeCheckbox =
 		Inputs.checkbox(
 		d3.group(workServedSpokeYearsWithChildren, (d) => d.activity ),
    {
    label: "Activity type",
    key: ["work", "served", "spoke"] 
    }
  ) ;

```
```js
// flatten. [checkMothers is view(makeCheckbox)]
const flatMothers = checkMothers.flat();
```

