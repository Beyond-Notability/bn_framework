---
theme: dashboard
title: (Almost) All the Dates
toc: false
---


# All The Dates

Using [Observable Plot](https://observablehq.com/plot/) / [dodge transform](https://observablehq.com/plot/transforms/dodge)

*This is a work-in-progress data essay*

Historians study change over time. We care about temporality. We consider what came before and what came after. We note the relationship between when things occured in our topic of discrete study, Braudel's proverbial surface ripples, and the longue duree of societal, cultural, demographic, geological, and climatological time.

As good historians, [Beyond Notability](https://beyondnotability.org/) project team collected a large number of dates associated with women's work in archaeology, history and heritage between - roughly - 1870 to 1950. And as we sought to organise the information we found within a biographical framework, we also collected data - where available - on when women were born, when they died, significant life events such as childbirth (see 'Motherhood'), and activities that enabled work, such as education (see 'Education').

All this information was collected as [queryable data](beyond-notability.wikibase.cloud/), and so as good computational historians we pulled it together and stuck it on a timeline. The result is a [beeswarm plot](https://observablehq.com/@d3/beeswarm/2) - below - that looks a lot like Mr Twit's Beard.

<div class="grid grid-cols-1">
  <div class="card">
    ${resize((width) => datesChartY(dates, {width}, plotTitle, plotHeight))}
  </div>
</div>

Much like Mr Twit, the uncritical user of our data - which on a bad day, might include us - could well feel wise and grand by having created a plot in the shape of the hirsute villain, might indulge in exploring the jungle of data for tasty morsels' of supposed insight: the decline in activity during the Great War, the growth in both education and work, the long delay in women being able to access spaces of work in these fields.

Now, there are some insights here, as well as nuances and complications to be teased out. But more importantly there is a problem of temporal equivalency - each spike on the beard may represent a date but there is a variety of *types* of dates among them.

Birth and death are simple. They take place when they take place (or at least that true for births and deaths as recorded by the bureaucratic regimes of modern nation states in the global north). They - like asking a question at an events, being elected to a membership body, or writing a letter - are things that take place at [points in time](https://beyond-notability.wikibase.cloud/wiki/Property:P1).

But can we equate these acts easily with, say, the point in time at which a book was published? Many acts that happen at a moment are the result of a more gradual process: a letter to a professional body [may be dated 16 February 1921](https://beyond-notability.wikibase.cloud/wiki/Item:Q577), but may have been written over a series of days. And if this seems trivial, what about writing a book? Maude Violet Clarke's 'The Medieval City State' may have [been published in 1926](https://beyond-notability.wikibase.cloud/wiki/Item:Q381), but the labour the produced the book does not have the same temporal equivalency to [her giving a paper at the Royal Historical Society on 10 December 1925](https://beyond-notability.wikibase.cloud/wiki/Item:Q374). And yet they both are, on our plot, equivalent in size and shape, another point in time among many.

More problems arise if we consider the [other types of time in the data](https://beyond-notability.wikibase.cloud/wiki/Special:WhatLinksHere/Item:Q94): start times, end times, latest dates, earliest dates; different forms of temporal flow and historical imagination.

For example, we know that [Ethel Lega-Weekes](https://beyond-notability.wikibase.cloud/wiki/Item:Q954) was elected as Fellow of the Royal Historical Society on 18 July 1914 and remaining a Fellow of the Society until her death in 1949. We also know that she became a member of the Devonshire Association in 1900, but we have no record of if and when that membership ended. We know that [Ada Goodrich-Freer](https://beyond-notability.wikibase.cloud/wiki/Item:Q747) served on the Council of the Folklore Society until 1906, but we don't know when she joined the Council. We know that [Winifred Lamb](https://beyond-notability.wikibase.cloud/wiki/Item:Q238) was living in Liphook, Hampshire, by 1932, because that was the address given in her nomination papers for election to the Society of Antiquaries of London. And we know that 1934 is the latest date that [Veronica Seton-Williams](https://beyond-notability.wikibase.cloud/wiki/Item:Q1176) could have lived in Melbourne, because 1934 is the earliest date for which we have found record of her living in London.

Indeed, places of residence are particular interesting for considering the temporal equivalency of data points. If [Veronica Seton-Williams](https://beyond-notability.wikibase.cloud/wiki/Item:Q1176) is recorded as resident at 4 Handel Street, London, in 1934, then at 9 Elvaston Place, London, in 1946, how do we understand the crossover between these two data points? What can we reasonably assume of the twelve year gap between information? And most significantly perhaps - given the tendency for visualisation to be taken as objective knowledge (see *Data Feminism* ([2020](https://data-feminism.mitpress.mit.edu/pub/5evfe9yd/release/5)) for both why and the best rebuttal of that tendency) - how might we represent this more accurately as data? Mr Twit's Beard, useful as it is for getting a sense of the shape of our data (e.g. women did do work in these fields after the 1950s, just our data collection stops then), is perhaps not the best way for representing that kind of temporal complexity: other posts in this interactive essay ('Motherhood' and 'Education') explore further our attempts to grapple with these flavours of time and temporality in our data.





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

<!-- 
data variables
precise
"person"          "personLabel"     
"date"            "year"    "month"           "day"             "m"              
"nice_date"       
"date_precision"  "date_certainty" 
"date_label"      "date_level"      "date_string"    "qual_date_prop" 
"date_propLabel" "date_prop"   "prop_label"     "category"         
"prop_valueLabel"  "prop_value" 
"s"  
-->

