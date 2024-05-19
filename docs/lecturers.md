---
theme: [cotton, wide]
title: Lecturers
toc: false
---

# Lecturing

```js
//got it!
const lecturersDates = FileAttachment("data/women_lecturing/lecturers-dates.csv").csv({typed: true});

```

<!-- 
bn_lecturers_dates |>
  count(organisation_ext, position_label, sort = T) |> 
  mutate(organisation_ext = fct_reorder(organisation_ext, n)) |>
  ggplot(aes(n, organisation_ext, fill=position_label)) 
  
 -->
 
<!--
faceted bars ?

bn_lecturers_dates |>
  count(position_label, year1) |>
  ggplot(aes(year1, n)) +
  geom_col() +
  facet_wrap(~position_label)

-->

```js
function lecturersDatesChart(data, {width}) {
 return Plot.plot({
	title: "By date",
	x: {label: "year", ticks: d3.range(1880,1950,10), tickFormat: d3.format('d')},
	y: {label: "number of positions", grid:true},
	
	width,
	height:600,
	 facet: {data, x: "position_label", label:null},
	marks: [
		//Plot.ruleY[0],
		//Plot.gridX(interval:10),
		Plot.rectY(
			data,
			Plot.groupX({y: "count"}, {x:"year1"})
		)
	]
 });
}
```

```js
function lecturersOrgsChart(data, {width}) {
	return Plot.plot({
title: "Organisations",
  x: {grid: true, label:"number of positions"},
  y: {label: null},
  color: {legend: true},
  width,
  height:600,
  marginLeft: 275,
  marks: [
    Plot.ruleX([0]),
    Plot.rectX(
    	data, 
    	Plot.groupY({x: "count"}, {y:"organisation_ext", fill:"position_label", sort: {y: "x", reverse: true} }) )
  ]
});
}
```


<div class="grid grid-cols-1">
  <div class="card">
    ${resize((width) => lecturersDatesChart(lecturersDates, {width}))}
  </div>
</div>

<div class="grid grid-cols-1">
  <div class="card">
    ${resize((width) => lecturersOrgsChart(lecturersDates, {width}))}
  </div>
</div>



```js
Inputs.table(lecturersDates, {
	layout: "auto",
	format: {
		bn_id:   id => htl.html`<a href=https://beyond-notability.wikibase.cloud/entity/${id} target=_blank>${id}</a>`,
		"nice_date": (d) => `${d}`,
		"year1": d3.format(".0f")
	},
  columns: [
    "bn_id",
    "person_label",
    "position_label",
    "organisation",
    "nice_date",
    "year1"
  ], 
  header: {
    bn_id: "Id",
    person_label: "name",
    position_label: "position type",
    organisation: "organised by",
    nice_date: "date",
    year1: "year"
  }
})

// link https://talk.observablehq.com/t/display-hyperlinks-in-inputs-table/5947
// year gets treated as number in date col.
// d3.format(".0f") only works for years, screws up other dates.
```
