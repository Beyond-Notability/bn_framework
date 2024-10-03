---
theme: dashboard
title: Residence
---

# Residence

Where people lived connected to the work they could do, networks they could form. 'Spatial' turn in history. BN data can be used to map women. But apart from telling us hot and cold spots in the data, didn't tell us much about relationship between residence and work. We found that much better were queries that, say, told us who was moving around a lot, both between towns/cities and - crucially - for London *within* the city. So when we turned to viz of residence data, took more creative - unexpected - approach.

## "resided at" date types

Nature of data we are dealing with. Mostly moments in time captured in the archive, connected together with - for those who move - another later moment in time, from which we infer - but cannot know - points of transition. More on this later.

<div class="grid grid-cols-1">
  <div class="card">
    ${resize((width) => residedTypesChart(resided, {width}))}
  </div>
</div>

## age / residence v other dates

Look across the lifecourse. Places in orange of residence vs other places in blue that they were found it. Which is more indicative of networks?

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

What do we see?

- place information for women peaks from mid-20s to late-50s. Bulk of adult life (tie to life expectancy in the period). Long tail.
- residence smoother. Some for when children. peaks more mid-30s to late-40s.
- much less residence data than other place data, however still alot given average number of places women lived at in the db + likley mobility patterns in our period.
- no way to disagreegate 'family home' from 'residence' from seasonal residences from long-term residences during, say, fieldwork.

### women who only have early (up to age 30) and late (age 60+) residence data

some viz on people with only residence data for early or late in life;

<div class="grid grid-cols-1">
  <div class="card">
    ${resize((width) => residedFacetedStackedDot(datesResidedEarlyLate, {width}))}
  </div>
</div>

Notes on the data:

- for "early": excluded anyone who has start time that has no corresponding end time, and any with earliest date
- for "late": excluded anyone who has end time with no corresponding start time, and any with latest date

## what does this all mean?

Data in the aggregate. But we don't want to aggregate. Brining in examples of people with gaps: look at place data between those gaps, does it help explain absent residence data?













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
