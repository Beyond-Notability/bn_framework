---
theme: dashboard
title: All the Dates
toc: false
---


# All The Dates

Using [Observable Plot](https://observablehq.com/plot/) / [dodge transform](https://observablehq.com/plot/transforms/dodge)

```js
const dates = FileAttachment("./data/l_dates_precise_all.json").json({typed: true});
```

what happens here

```js
//new Date(now).toLocaleTimeString("en-US")

//for (let i = 0; i < 5; ++i) {
//  display(i);
//}

dates.find((d) => d.date)
```


dates everything

```js
dates
```

<!--
// Manually set colors using `range`
Plot.legend({
  color: {
    type: "categorical",
    domain: d3.range(10).map(d => `Category ${d + 1}`), 
    range: ["green", "purple", "orange", "yellow", "blue", "pink", "brown", "grey", "green", "lavender"]
  }
})

"undefined" label ="other", at the end of the list, coloured grey.
-->

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


```js
function datesChartY(data, {width}) {
  return Plot.plot({
    title: "Every date as a dot",
    width,
    height: 1200,
    marginTop: 10,
    marginLeft: 0,
    x: {label: null, type: "point", axis:null}, //round: true, nice: d3.utcYear
    y: {label: null},
    color: {legend: true, 
    				range: ["#1f77b4", "green", "#ff7f0e", "#8c564b", "#bdbdbd"],
    				domain: ["birth", "death", "education", "work", "other"]
    				},
    marks: [
    	
    	// 1. how to make this use data? 2. how to put in the right place?
    	// is there any option other than plot.text?
    	// intervals? i don't think so but can't really tell... https://observablehq.com/plot/features/intervals 
    	// tick mark? if you can get the right sort of grouping it feels like it should be possible... and yet... https://observablehq.com/plot/marks/tick
    	
    	// the first/middle/last dates are OK as fixed location. 
    	// but in betweens are harder, because of responsive width. 
    	Plot.text([`2016`], {frameAnchor: "top-right", fontSize:12, dy:-15, dx:10}), // at the top; dy to move above the plot area.
    	Plot.text([`1907`], {frameAnchor: "top", fontSize:12, dy:-15}), //centre
    	Plot.text([`1718`], {frameAnchor: "top-left", fontSize:12, dy:-15, dx:-10}), 
    	
    	// inbetween locations... sort of. ?????
    	Plot.text([`xxxx`], {frameAnchor: "top-left", fontSize:12, dy:-15, dx:250}), 
      Plot.text([`xxxx`], {frameAnchor: "top-right", fontSize:12, dy:-15, dx:-250}), 
    	    	
    	//Plot.text(data, Plot.selectMinX({x:"date", frameAnchor: "top", fontSize:12, dy:-15}) ),  // shows 0 but at least it shows something. selectFirst is the same.
    	
    	// can't even get it to draw a horiz rule at top.
    	//Plot.axisX( d3.ticks(1718, 2020, 50), {anchor: "top", tickSize:0 }), // yuck. why does it behave like this? d3.ticks might get somewhere...
    	// tickSize:0 - turns off ticks, 
    	// ticks: "(anything)" - blob disappears

    	
    	Plot.dot(data, 
    		Plot.dodgeY({
    			x: "date", 
    			anchor:"top", 
    			fill:"category", 
    			padding:0.6, 
    			r:3, 
    			sort:"day",
    			reverse:true, 
    			tip:true,
    			channels: {
      		// label:colname
      			name: "personLabel",
      			property: "date_propLabel",
      			"date type":"date_label",
      			"date precision":"nice_date"
      		} , 
      	 // tooltip
  				tip: {
  					fontSize:13,
  					lineHeight:1.3,
    				format: {
    					name: true, // added channel for label.
    					x: false, 
    					//"year": (d) => `${d}`,  
      				property:true,
      				category:true
    				}
    			}
    		 })
    		)    
  ]
  });
}

```



<div class="grid grid-cols-1">
  <div class="card">
    ${resize((width) => datesChartY(dates, {width}))}
  </div>
</div>

