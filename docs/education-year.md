---
theme: dashboard
title: Education by year 
toc: false
---

# Timelines of higher education


```js
const education2 = FileAttachment("data/l_dates_education/educated_degrees2.json").json({typed: true});

```

```js
const color_time = Plot.scale({
		color: {
			range: ["#1f77b4", "#ff7f0e", "#2ca02c", "#d62728", "lightgray"], 
			domain: ["point_in_time", "start_time", "end_time", "latest_date", "filled"]
		}
	});
```



```js

// without faceting

function educatedYearsChart(data, {width}) {
  return Plot.plot({
    title: "higher education chronology, sorted by date of birth",
    width,
    height: 6000,
    marginTop: 10,
    marginLeft: 180,
    x: {
    	grid: true, 
    	//padding:50, // ?
    	label: "year of event", 
    	tickFormat: d3.format('d'),
    	axis: "both" // "both" top and bottom of graph. null for nothing.
    	}, 
    y: {label: null}, // this affects tooltip label too  
    symbol: {legend:true, range: ["diamond", "triangle", "wye", "star", "square"], 
			domain: ["point_in_time", "start_time", "end_time", "latest_date", "filled"]},
    color: color_time,
    marks: [
    	
      Plot.ruleX([1830]), // makes X start at 1830. TODO earliest_year rather than hard coded.
      
      // 1920 etc highlight? hmm. 1878=UoL degrees. need tip/label of some sort.
     // Plot.ruleX([1878], {stroke:"pink"}),
      Plot.ruleX([1920], {stroke: "lightgreen"}),
    //  Plot.ruleX([1948], {stroke: "lightblue"}),
      
      
    	// turn into separate rule for education? needs separate year_last as well
    	// TODO maybe split rule earliest/birth>start and start>end with different styling?
      Plot.ruleY(data, {
      	// x1 to start this at 1830 as well. 
      	x1:1830, // TODO variable not hard coding
      	x2:"year_last", 
      	y: "person_label", 
      	//dy:-6, // if separate
      	stroke: "lightgray" , 
      	strokeWidth: 2,
      channels: {yob: 'bn_dob_yr', "year":"year"}, sort: {y: 'yob'} // you only need to do this once?
      }),
      
      // make separate rule for degrees? needs separate year_last - if no degrees, don't want it to draw anything
    //  Plot.ruleY(data, {
      	// x1 to start this at 1830 as well.
    //  	x1:1830, // TODO variable
    //  	x2:"year_last", // would need its own end year
    //  	y: "person_label", 
    //  	dy:6,
    //  	stroke: "lightgray" , 
    //  	strokeWidth: 1,
    //  channels: {yob: 'bn_dob_yr', "year":"year"}, sort: {y: 'yob'}
    //  }),
      
 			// educated at fill years, no tips. draw BEFORE single points.
      Plot.dot(
      	data, {
      	x: "year", 
      	y: "person_label" , 
      	//filter: (d) => d.date_pairs=="2 both", //keeps start and end as well
      	filter: (d) => d.year_type=="filled",
      	dy:-6,
      	symbol: "year_type",
      	fill:"year_type",
      	r:4,
      	tip:false,
       }
      ),
    	
			// educated at single points
			// can include filled years, but easier to control their appearance if separate
			// highlight start-end pairs cf start/end only?
      Plot.dot(
      	data, {
      	x: "year", 
      	y: "person_label" , 
      	fill: "year_type",
      	symbol: "year_type",
      	filter: (d) =>  d.year_type !="filled"  &	d.src=="educated", 
      	//d.date_pairs !="2 both" to exclude start-end
      	dy:-6, // vertical offset. negative=above line.
      	// tips moved to Plot.tip
      //	channels: {
      //		where:"by_label", 
      //		"year of birth":"bn_dob_yr", 
      //		age:"age",
      //		woman: "person_label"
      //		} , 
      //sort: {y: 'yob'} , // sorting here as well doesn't seem to be needed
      // tooltip
      	//tip:true, // not needed if adding more stuff
  			//tip: {
    		//	format: {
    		//		woman: true, // added channel for label.
      	//		y: false, // now need to exclude this explicitly
    		//		"year of birth": (d) => `${d}`,
      	//		x: (d) => `${d}`, // TODO handle year-dates properly...
      	//		age: true
    		//	},
    			//pointerSize:4,
    			//textPadding:4,
    			//anchor:"top-left", // dont think this does quite what you expected...
  		  //} // /tip
    	}), // /dot
 
      // degrees
      Plot.dot(
      	data, {
      	x: "year", 
      	y: "person_label" , 
      	fill: "year_type",
      	symbol: "year_type",
      	filter: (d) =>	d.src!="educated" , 
      	dy:6, // vertical offset. negative=above line.

      //sort: {y: 'yob'} , // sorting here as well doesn't seem to be needed
      // tooltip stuff removed
      //tips separately on plot.dots seems to cause all sorts of confusion

    	}), // /plot.dot
    	
    	// year of birth dot 
    	Plot.dot(
      	data, {
      	x: "bn_dob_yr", 
      	y: "person_label" , 
      	dx: 6,
      	channels: {
      		"year of birth":"bn_dob_yr", 
      		} , 
      // tooltip
  			tip: {
    			format: {
    				x: false, // added channel for label.
      			y: false, // now need to exclude this explicitly
    				"year of birth": (d) => `${d}`,
    			},
  				anchor: "right", 
  		  }
    	}), // /dot
    	
    	// only show one tip at a time, less mess.
    	// TODO but now if you have educated/degree in the same year it only shows degree. 
    	// could filter and have separate educated/degrees? but probably have collision problems again.
      // problem seems to be how far around a dot the tip works; could "padding" be reduced? 
      // or maybe the problem is that it treats the rule as its middle spot, not the dots. ? even if you use dx. could ?px work instead?
    	Plot.tip(data, Plot.pointer({
    			x: "year", 
    			y: "person_label", // can you really not give this a label?
    			//title: "person_label", // *only* shows person_label.
    			filter: (d) => d.year_type !="filled", // no tips on filled years!
    			anchor:"right",
    			dx:-6,
    			channels: {
      		//woman: "person_label",
    			"event type":"src",
    			"event year": "year",
      		"year of birth":"bn_dob_yr", 
      		"age at event":"age",
      		where:"by_label",
      		qualification:"degree_label", 
      		} , 
      		format: {
      			x:false, 
      			y:false,
      			//woman: true,
      			// make these go first, do formatting
      			"event type":true,
      			"event year": (d) => `${d}`, 
      			"year of birth": (d) => `${d}`,
      			}
    			}
    		)	
    	), // /tip

    ]  // /marks
  });
}

// channels to reference more data variables; can be called anything
// seems clunky to make y label empty then define same variable as a channel for tooltip then exclude y again! 
// maybe there's a better way to keep y label for tooltip but omit from y axis... (could change name in data loader of crs...)

```


<div class="grid grid-cols-1">
  <div class="card">
    ${resize((width) => educatedYearsChart(education2, {width}))}
  </div>
</div>







