---
theme: dashboard
title: Residence
---

# Residence

[curent version of the data essay is now [here](https://beyond-notability.github.io/beyond-notability-observable-essays/). charts here retained for reference/experimentation.]



## "resided at" date types


<div class="grid grid-cols-1">
  <div class="card">
    ${resize((width) => residedTypesChart(resided, {width}))}
  </div>
</div>

## age / residence v other dates


```js
//datesResidedAges
```

<div class="grid grid-cols-1">
  <div class="card">
    ${resize((width) => residedStackedDot(datesResidedAges, {width}))}
  </div>
</div>

Notes on the data:

- all women who have dates of birth
- birth dates are excluded
- excluded women who have any undated resided at
- also anyone born before 1831 or after 1910 (small numbers)


### women who only have early (up to age 30) and late (age 60+) residence data


<div class="grid grid-cols-1">
  <div class="card">
    ${resize((width) => residedFacetedStackedDot(datesResidedEarlyLate, {width}))}
  </div>
</div>

Notes on the data:

- for "early": excluded anyone who has start time that has no corresponding end time, and any with earliest date
- for "late": excluded anyone who has end time with no corresponding start time, and any with latest date




```js
// Import components
import {residedTypesChart, residedEarlyLateBeeswarm, residedStackedDot, residedFacetedStackedDot} from "./components/resided.js";
```




```js

const datesResidedAges = FileAttachment("./data/l_resided_at/dates-ages.csv").csv({typed: true})

const resided = FileAttachment("./data/l_resided_at/resided.csv").csv({typed: true})

//const residedDated = FileAttachment("./data/l_resided_at/resided-dated.csv").csv({typed: true})

const datesResidedEarlyLate = FileAttachment("./data/l_resided_at/dates-resided-early-late.csv").csv({typed: true})

//const datesResidedOther = FileAttachment("./data/l_resided_at/dates-resided-other.csv").csv({typed: true})

```
