---
theme: dashboard
title: BN Women Participation in Events
toc: false
---

# Most frequent event attenders

```js
const events = FileAttachment("./data/women_events.json").json();
```


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