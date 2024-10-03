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

Another way to think about the lifecourse is to filter to only women with only residence data for early or late in life, and then plot that alongside the other place data in their lifecourse.

<div class="grid grid-cols-1">
  <div class="card">
    ${resize((width) => residedFacetedStackedDot(datesResidedEarlyLate, {width}))}
  </div>
</div>

Notes on the data:

- for "early": excluded anyone who has start time that has no corresponding end time, and any with earliest date
- for "late": excluded anyone who has end time with no corresponding start time, and any with latest date

What do we see?

- similar numbers of women have residence data for only late-teens / early-30s *or* late-50s to early-70s.
- 'early' peaks 25-30
- 'late' peaks at roughly 60
- where the residence data clusters the other place data clusters
- BUT, for 'late' peak of place data before residece peak (esp mid-50s) and for 'early' peak in early-20s before residence peak. Women, therefore, seem to be doing things that get into our data before they do things that get in our data that requires their address to be known. Going back to first graph and dominance of PiT data, where women live becomes archivable in the records we have used once women have done things first that make that residence worth recording.
- Then, for 'early' - they drift away (kids?)
- Then, for 'late' - they reach an age when they can no longer contribute or pass away.

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
