---
theme: dashboard
title: Residence
---

# Residence

Places connect people to understandings, practices, and conceptions of space. Residences are particular kinds of places, private - in most cases - spheres of experience whose character is deeply personal. For the historian encountering residence information - the places people lived, the periods in which they lived there, the people they lived with - the impenetrability of these private realms can provoke a retreat to place: to putting dots on maps and to using those maps as proxies for where people did things, the spaces they encountered and fashioned. Where people live is of course strongly connected to the work they do, the networks they form, their understandings, practices, and conceptions of space. And Beyond Notability has collected lots of information about where people lived. But when we began to put residence data from [our wikibase](https://beyond-notability.wikibase.cloud/) on a map, apart from highlighting hot and cold spots in our data, it didn't tell us much about the relationship between residences and work. Much more generative we found were those queries that used residence data to tell us who moved on multiple occasions, whether those residence were far apart, if those residences were *within* the city or local area; in short, the relationships between residences and time. And so as we turned to visualising our residence data we put maps aside, took a more lifecourse-oriented approach, and tried to use the appearance of residence data in our sources to get at when women's work in archaeology, history, and heritage became present in those fields. This was not, as we'll explain, without complication.

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
