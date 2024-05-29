---
theme: dashboard
title: Education
toc: false
---

# Timelines of higher education

```js
const education = FileAttachment("./data/dates_education.json").json({typed: true});
```

<!--
educated at
"bn_id"	"person_label"	"college_label"	"year"	"year_type"	"age"	"age_death_"	"date_pairs"	"bn_dob_yr"	"bn_dod_yr"	"s"
"age_last" "cert"

max age in data is 102; max age at event is 65

-->

```js
function facetedEducatedAgesChart(data, {width}) {
  return Plot.plot({
    title: "higher education and age, sorted by date of birth",
    width,
    height: 4000,
    marginTop: 0,
    marginLeft: 180,
    x: {grid: true, label: "age at event"},
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

// channels to reference more data variables; can be called anything
// i think you only need to do sort once
// seems clunky to make y label empty then define same variable as a channel for tooltip then exclude y again! 
// maybe there's a better way to keep y label for tooltip but omit from y axis... (could change name in data loader of crs...)
```




<div class="grid grid-cols-1">
  <div class="card">
    ${resize((width) => facetedEducatedAgesChart(education, {width}))}
  </div>
</div>





```js

// without faceting

function educatedAgesChart(data, {width}) {
  return Plot.plot({
    title: "higher education and age, sorted by date of birth",
    width,
    height: 1200,
    marginTop: 0,
    marginLeft: 180,
    x: {grid: true, label: "age at event"},
    y: {label: null}, // this affects tooltip label too
    symbol: {legend:true},
    marks: [
      Plot.ruleX([10]), // makes X start at 10. 
      Plot.ruleY(data, {x1:10, x2:"age_last", y: "person_label", stroke: "lightgray" , // x1 to start this at 10 as well
      channels: {yob: 'bn_dob_yr', "year":"year"}, sort: {y: 'yob'}
      }),
      Plot.dot(
      	data, {
      	x: "age", 
      	y: "person_label" , 
      	fill: "year_type",
      	symbol: "year_type",
      	//r: "cert", // not working???
      	tip:true,
      	channels: {
      		college:"college_label", 
      		"year of birth":"bn_dob_yr", 
      		year:"year",
      		woman: "person_label"
      		} , 
      //sort: {y: 'yob'} , // sorting here as well doesn't seem to be needed
      // tooltip
  			tip: {
    			format: {
    				woman: true, // added channel for label.
      			y: false, // now need to exclude this explicitly
    				"year of birth": (d) => `${d}`,
      			"year": (d) => `${d}`, // TODO handle year-dates properly...
      			x: true
    			}
  		  }
    	})
    ]
  });
}

// channels to reference more data variables; can be called anything
// i think you only need to do sort once
// seems clunky to make y label empty then define same variable as a channel for tooltip then exclude y again! 
// maybe there's a better way to keep y label for tooltip but omit from y axis... (could change name in data loader of crs...)

```