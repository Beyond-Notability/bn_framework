---
theme: dashboard
title: Education by age
toc: false
---

# Timelines of higher education

```js
const education_facet = FileAttachment("data/l_dates_education/educated_degrees.json").json({typed: true}); // for faceted chart

const education = FileAttachment("data/l_dates_education/educated_degrees2.json").json({typed: true});
```

<!--

colours?
https://talk.observablehq.com/t/consistent-colour-for-a-variable-level/8244

https://talk.observablehq.com/t/possible-to-keep-colors-static-when-toggling-out-observations-in-plot/7322/6
-->


```js

const color_time = Plot.scale({
		color: {
			//scheme: "Tableau10",
			range: ["#1f77b4", "#ff7f0e", "#2ca02c", "#d62728", "lightgray"], 
			domain: ["point_in_time", "start_time", "end_time", "latest_date", "filled"]
		}
	});
```

```js

// without faceting

function educatedAgesChart(data, {width}) {
  return Plot.plot({
    title: "higher education and age, sorted by date of birth",
    width,
    height: 6000,
    marginTop: 10,
    marginLeft: 180,
    x: {
    	grid: true, 
    	//padding:20,
    	label: "age at event", // TODO only showing at bottom, why? year version shows both.
    	axis: "both" // "both" top and bottom of graph. null for nothing.
    	}, 
    y: {label: null}, // this affects tooltip label too  
    symbol: {legend:true, 
    				range: ["diamond", "triangle", "wye", "star", "square"], 
						domain: ["point_in_time", "start_time", "end_time", "latest_date", "filled"]},
    color: color_time,
    marks: [
    	
      Plot.ruleX([0]), // makes X start at 0. 
      Plot.ruleY(data, {
      	// x1 to start this at 0 as well. maybe you need an age_first as well as last. but then what happens to women with only one event?
      	x1:0, 
      	x2:"age_last", 
      	y: "person_label", 
      	stroke: "lightgray" , 
      	strokeWidth: 1,
      channels: {yob: 'bn_dob_yr', "year":"year"}, sort: {y: 'yob'}
      }),
 
 			// educated at fill years, no tips. draw before single points.
      Plot.dot(
      	data, {
      	x: "age", 
      	y: "person_label" , 
      	//filter: (d) => d.date_pairs=="2 both", //keeps start and end as well
      	filter: (d) => d.year_type=="filled",
      	dy:-6,
      	symbol: "square",
      	fill:"lightgray",
      	r:4,
      	tip:false,
       }
      ),
      
			// educated at single points
      Plot.dot(
      	data, {
      	x: "age", 
      	y: "person_label" , 
      	fill: "year_type",
      	symbol: "year_type",
      	filter: (d) =>  d.year_type !="filled"  & d.src=="educated", 
      	dy:-6, // vertical offset. negative=above line.
      	// tips -> Plot.tip
 //     	channels: {
  //    		where:"by_label", 
 //     		"year of birth":"bn_dob_yr", 
 //     		year:"year",
 //     		woman: "person_label"
 //     		} , 
      // tooltip
//  			tip: {
//    			format: {
//    				woman: true, // added channel for label.
//      			y: false, // now need to exclude this explicitly
//    				"year of birth": (d) => `${d}`,
//      			"year": (d) => `${d}`, // TODO handle year-dates properly...
//      			x: true
//    			},
//    			anchor:"top-right", // dont think this does quite what you expected...
//  		  }
    	}), // /dot
    	
      // degrees
      Plot.dot(
      	data, {
      	x: "age", 
      	y: "person_label" , 
      	fill: "year_type",
      	symbol: "year_type",
      	filter: (d) =>	d.src!="educated" , 
      	dy:6, // vertical offset. negative=above line.
//      	channels: {
//      		degree:"degree_label", 
//      		conferred:"by_label",
//      		"year of birth":"bn_dob_yr", 
//      		year:"year",
//      		woman: "person_label"
//      		} , 

      // tooltip -> Tip

    	}), // /dot
    	
       	// only show one tip at a time
    	Plot.tip(data, 
    		Plot.pointer({
    			x: "age", 
    			y: "person_label", // can you really not give this a label?
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
      			// make these go first and do formatting
      			"event type":true,
      			"event year": (d) => `${d}`, 
      			"year of birth": (d) => `${d}`,
      			}
    			}
    		)	
    	), // /tip
	  	
    	
    ] // /marks
  });
}


// seems clunky to make y label empty then define same variable as a channel for tooltip then exclude y again! 
// maybe there's a better way to keep y label for tooltip but omit from y axis... (could change name in data loader of crs...)

```




<div class="grid grid-cols-1">
  <div class="card">
    ${resize((width) => educatedAgesChart(education, {width}))}
  </div>
</div>





```js
// not deprecating this just yet. 
function facetedEducatedAgesChart(data,  {width}) {
  return Plot.plot({
    title: "higher education and age, sorted by date of birth",
    width,
    height: 4000,
    marginTop: 0,
    marginLeft: 180,
    x: {grid: true, label: "age at event", axis:"both"},
    y: {label: null, axis: null}, // this affects tooltip label too. 
    facet: {data, y:"person_label", label: "woman"}, 
    symbol: {legend:true},
    //fill: {legend:true}, // doesn't work?
    marks: [
      Plot.ruleX([10]), // makes X start at 10. 
      Plot.ruleY(data, {x1:10, x2:"age_last",  // x1 to start this at 10 as well
      			y: "src", // different from unfaceted version
      			stroke: "lightgray" ,
      			channels: {yob: 'bn_dob_yr', "year":"year"}, 
      			sort: {y: 'yob'} // not sure this is doing anything now.
      }),


   
      Plot.dot(
      	data, {
      	x: "age", 
      	y: "src", 
      	fill: "date_pairs",
      	symbol: "year_type",
      	sort: {fy: 'year of birth'} , // fy, not y.
      	channels: {
      		university:"by_label", 
      		qualification:"degree_label",
      		"year of birth":"bn_dob_yr", 
      		"year of event":"year",
      		//source: "src"
      		} , 
      	tip:true,
      
      // tooltip
  			tip: {
    			format: {
    				fy: true, // need this here to put it first.
      			y: false, // need to exclude this explicitly. now = src
    				"year of birth": (d) => `${d}`,
      			"year of event": (d) => `${d}`, // TODO handle year-dates properly...
      			x: true,
      			symbol: false,
      			//fill: false, // for "src". need here AND y. ffs.
    			}
  		  }
    	})
    ]
  });
}

```

