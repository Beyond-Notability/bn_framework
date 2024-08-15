---
theme: dashboard
title: Motherhood
toc: false
---

# Timelines of childbirth

Alongside collecting information about women's work in archaeology, history and heritage - as well as the work related activities such as [Education](https://beyond-notability.github.io/bn_framework/education.html) - the [Beyond Notability](https://beyondnotability.org/) project team sought to collect data on biographical 'life events' such as marriage, divorce, parenthood. When we began to plot these we began to consider how best to represent them, how to seperate them out in ways that enabled us to consider what events like becoming a parent did to women's ability to pursue their work in the fields of archaeology, history and heritage.

This graph shows all the women in our wikibase for whom we have ['had child in'](https://beyond-notability.wikibase.cloud/wiki/Special:WhatLinksHere/Property:P131) data with a known date. Each woman is represented on a single row, with the rows organised by data of birth, with the earliest - [Margaret Emily Blaauw](https://beyond-notability.wikibase.cloud/wiki/Item:Q3658), born 1798 - at the top and the latest - [Jacquetta Hawkes](https://beyond-notability.wikibase.cloud/wiki/Item:Q106), born 1910 - at the bottom. Each row then shows four types of information:

- the years in which they had a child, represented as a vertical line.
- for women who had multiple children, periods between having their first and last child.
- the years (usually not start and end dates) in which we are aware that they ['served on'](https://beyond-notability.wikibase.cloud/wiki/Property:P102) a committee or group, for example that [Sophie Lomas served on the Historical Committee of the Festival of Empire in 1911](https://beyond-notability.wikibase.cloud/wiki/Item:Q960).
- the years (again, usually not start and end dates) in which we are aware that they ['held a position'](https://beyond-notability.wikibase.cloud/wiki/Property:P17) in or for an organisation, such as a recorded reference to Lina Chaworth Musters having held the position of County Collector for The Folklore Society in 1984.

<div class="grid grid-cols-1">
  <div class="card">
    ${resize((width) => hadChildrenAgesChart(hadChildrenAges, lastAges, workYearsWithChildren, servedYearsWithChildren, {width}))}
  </div>
</div>



Here is an inline note.^[Inlines notes are easier to write, since
you don't have to pick an identifier and move down to type the
note.]

Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.[^1] Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.[^2] 

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
