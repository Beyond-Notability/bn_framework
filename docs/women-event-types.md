---
theme: parchment
title: Participation in Events
toc: false
---

# Most frequent event attenders

```js
const events = FileAttachment("./data/l_women_events.json").json({typed:true});
```


```js

const checkCategories = view(   
		Inputs.checkbox(
    //lecturersDates.map((d) => d.position_label),
    d3.group(events, (d) => d.event_type ),
    {
     //unique:true,
    label: "Event type",
    key: ["meeting", "conference", "exhibition", "other", "misc"], // does need this
    sort: true,
    }
  ) 
);

//(if you put the const in the same code chunk as table get data is not iterable error)
// when using flat() changes to a "is not a function" error
```

```js
//checkCategories.flat()
```



```js

Inputs.table(checkCategories.flat(), {
	layout: "auto",
	//value:"position_label",
	//sort:"year1",
	format: {
		bn_id: id => htl.html`<a href=https://beyond-notability.wikibase.cloud/entity/${id} target=_blank>${id}</a>`,
		"nice_date": (d) => `${d}`,
		"year": d3.format(".0f")
	},
  columns: [
    "bn_id",
    "personLabel",
    "year",
    "event_type",
    "event_org",
  ], 
  header: {
    bn_id: "Id",
    personLabel: "name",
    year: "year",
    event_type: "event type",
    event_org: "organisation/title",
  }
})

// link https://talk.observablehq.com/t/display-hyperlinks-in-inputs-table/5947
// year gets treated as number in date col.
// d3.format(".0f") only works for years, screws up other dates.
```


[table is not yet linked to chart]


<!-- A shared color scale for consistency, sorted by the number of launches -->

```js
const color = Plot.scale({
  color: {
    type: "categorical",
    domain: d3.groupSort(events, (D) => -D.length, (d) => d.event_type).filter((d) => d !== "Other"),
    unknown: "var(--theme-foreground-muted)"
  }
});
```

<!-- 
date,state,stateId,family
count(bn_id, personLabel, event_type, n_bn)
 -->

```js
function eventsChart(data, {width}) {
  return Plot.plot({
    title: "Frequent Attenders, by event type",
    width,
    height: 1200,
    marginTop: 0,
    marginLeft: 180,
    x: {grid: true, label: "events"},
    y: {label: null},
    color: {...color, legend: true},
    marks: [
      Plot.rectX(data, Plot.groupY({x: "count"}, {y: "personLabel", fill: "event_type", tip: true, sort: {y: "-x"}})),
      Plot.ruleX([0])
    ]
  });
}
```

<div class="grid grid-cols-1">
  <div class="card">
    ${resize((width) => eventsChart(events, {width}))}
  </div>
</div>