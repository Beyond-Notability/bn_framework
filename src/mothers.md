---
theme: dashboard
title: Motherhood
toc: false
---

# Timelines of childbirth

*This is a work-in-progress data essay*

Alongside collecting information about women's work in archaeology, history and heritage - as well as the work related activities such as [Education](https://beyond-notability.github.io/bn_framework/education.html) - the [Beyond Notability](https://beyondnotability.org/) project team sought to collect data on biographical 'life events' such as marriage, divorce, parenthood. When we began to plot these we began to consider how best to represent them, how to seperate them out in ways that enabled us to consider what events like becoming a parent did to women's ability to pursue their work in the fields of archaeology, history and heritage.

This graph shows all the women in our wikibase for whom we have ['had child in'](https://beyond-notability.wikibase.cloud/wiki/Special:WhatLinksHere/Property:P131) data with a known date. Each woman is represented on a single row, with the rows organised by data of birth, with the earliest - [Margaret Emily Blaauw](https://beyond-notability.wikibase.cloud/wiki/Item:Q3658), born 1798 - at the top and the latest - [Jacquetta Hawkes](https://beyond-notability.wikibase.cloud/wiki/Item:Q106), born 1910 - at the bottom. Each row then shows four types of information:

- the years in which they had a child, represented as a vertical line.
- for women who had multiple children, periods between having their first and last child.
- the years (usually not start and end dates) in which we are aware that they ['served on'](https://beyond-notability.wikibase.cloud/wiki/Property:P102) a committee or group, for example that [Sophie Lomas served on the Historical Committee of the Festival of Empire in 1911](https://beyond-notability.wikibase.cloud/wiki/Item:Q960).
- the years (again, usually not start and end dates) in which we are aware that they ['held a position'](https://beyond-notability.wikibase.cloud/wiki/Property:P17) in or for an organisation, such as a recorded reference to [Lina Chaworth Musters having held the position of County Collector for The Folklore Society in 1894](https://beyond-notability.wikibase.cloud/wiki/Item:Q998). Note this this does not include employment at an institution that typically employed people on a formal, longstanding basis.

<div class="grid grid-cols-1">
  <div class="card">
    ${resize((width) => hadChildrenAgesChart(hadChildrenAges, lastAges, workServedYearsWithChildren, {width}))}
  </div>
</div>

What does organising the data in this way suggest to us?

- it foregrounds parenthood as a significant feature in the lives of many women in our dataset, and states unambigously that many women who had children also had active and productive lives in the fields of archaeology, history and heritage.
- that few women sat on committees or held positions before the age of 30, and those that did cluster towards the end of our period.
- that after the age of 40 women with children started sitting on committes and holding postitions with greater frequency.
- that across our period, some women, though few in number sat on committees or held positions in and around periods when they were having children.
- given that a woman wouldn't be in our data unless they did work in archaeology, history and heritage, that many women who had children did things other than serving on committees or holding positions, and that these cluster towards the start of the period. FIXME work through some examples. Significant, however, that no women in our dataset recorded as becoming a parent did no 'work' after having children. Chimes with scholarship on wider atitudinal shift towards working mothers (McCarthy)
- it opens up questions that go beyond the data, back into the archive, back into particular cases and circumstances: how was socio-economic class at play? did different work to fit around children? how did cultures created by the marriage bar - even if it didn't apply to many contexts these women worked in - shape what work women did and didn't do?

What do we need to know to not misread this visualistion and the underlying data it contains?

- First, that we have 'had child in' data for fewer than 10% of the women in our data ([72](https://beyond-notability.wikibase.cloud/w/index.php?title=Special:WhatLinksHere/Property:P131&limit=500) of 899). That cannot be all the data. And is likely a sample skewed towards those women who were more notable.
- Second, this can't be all the data about committess / positions - local committees, less well regarded roles less likely to be captured in our data.
- Third, that parenthood isn't faced equally. Some people have help. Some children get unwell. Some parents get unwell. Birth are not experienced equally. Some people take on significant caring responsiblities without ever 'having' children.
- Fourth, if our project had sought to recover the lives of forgotten men, would we have though to do this for them? Would we have thought of parenthood as a life event? Would we think to create visualisations that anchor men's lives around their fertility?

Probably not. But there is some merit to this approach to captured this data that, we think, could open up linked data biography to enable better questions to be asked of the lifecourse as it relates to people of all gender. **Add bits from article about how WD represents people having children in a flat way**

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

//const workYearsWithChildren = FileAttachment("data/l_women_children/work-years-with-children.csv").csv({typed:true});

//const servedYearsWithChildren = FileAttachment("data/l_women_children/served-years-with-children.csv").csv({typed:true});

const workServedYearsWithChildren = FileAttachment("data/l_women_children/work-served-years-with-children.csv").csv({typed:true});

const lastAges = FileAttachment("data/l_women_children/consolidated-last-ages.csv").csv({typed:true});

```
