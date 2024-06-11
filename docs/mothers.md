---
theme: dashboard
title: Motherhood
toc: false
---

# Timelines of childbirth

```js
//got it!
const hadChildrenAges = FileAttachment("data/l_women_children/had-children-ages.csv").csv({typed: true});

```

<!-- 

mutate(personLabel = fct_rev(fct_reorder(personLabel, bn_dob))) 

  ggplot(aes(y=personLabel, x=age)) +
  geom_segment( aes(x=start_age, xend=last, yend=personLabel), linewidth=0.2, colour="lightgrey") +
  geom_point(shape = 124, size = 2.2, colour="black") +
  
 -->

```js
function hadChildrenAgesChart(data, {width}) {
  return Plot.plot({
    title: "The ages at which BN women had children, sorted by mothers' dates of birth",
    width,
    height: 900,
    marginTop: 0,
    marginLeft: 180,
    x: {grid: true, label: "age at birth of child"},
    y: {label: null}, // this affects tooltip label too
    marks: [
      Plot.ruleX([10]), // makes X start at 10. 
      Plot.ruleY(data, {x1:10, x2: "last_age", y: "personLabel", stroke: "lightgray" , // x1 to start this at 10 as well
      channels: {yob: 'bn_dob_yr', year:"year"}, sort: {y: 'yob'}
      }),
      Plot.tickX(
      	data, {x: "age", y: "personLabel" , tip:true,
      	channels: {
      		"child born":"year", 
      		child:"childLabel", 
      		"year of birth":"bn_dob_yr", 
      		woman: "personLabel"
      		} , 
      //sort: {y: 'yob'} , // sorting here as well doesn't seem to be needed
      // tooltip
  			tip: {
    			format: {
    				woman: true, // added channel for label.
      			y: false, // now need to exclude this explicitly
    				"year of birth": (d) => `${d}`,
      			"child born": (d) => `${d}`, // there's probably a more correct way to make this format as text without a comma...
      			x: true,
      			child:true
    			}
  		  }
    	})
    ]
  });
}

// channels to reference more data variables; can be called anything
// i think you only need to do the sort once
// seems clunky to make y label empty then define same variable as a channel for tooltip then exclude y again! maybe there's a better way to keep y label for tooltip but omit from y axis...
```

```js
// a version showing dates rather than ages so we can see when we have data for... 

function hadChildrenYearsChart(data, {width}) {
  return Plot.plot({
    title: "When BN women had children, sorted by date of first child",
    width,
    height: 900,
    marginTop: 0,
    marginLeft: 180,
    x: {grid: true, label: "year child born", tickFormat: d3.format(".0f")}, // get rid of commas in years
    // Plot.plot({  x: {    tickFormat: d3.format(".0f"), 
    y: {label: null}, // this affects tooltip label too
    marks: [
      Plot.ruleX([1830]), // makes X start at specified number.
      Plot.ruleY(data, {x1:1830, x2: "latest_year", y: "personLabel", stroke: "lightgray" , // x1 to start this at 10 as well
      channels: {yob: 'bn_dob_yr', year:"year", "first year":"first_year"}, sort: {y: "first year"}
      }),
      Plot.tickX(
      	data, {x: "year", y: "personLabel" , tip:true,
      	channels: {
      	// label:colname
      		"age at birth of child": "age",
      		"year child born":"year", 
      		child:"childLabel", 
      		"year of birth":"bn_dob_yr", 
      		woman: "personLabel"
      		} , 
      // tooltip
  			tip: {
    			format: {
    				woman: true, // added channel for label.
      			y: false, // now need to exclude this explicitly.
    				"year of birth": (d) => `${d}`, // same effect as d3.format in next line
      			"year child born": d3.format(".0f"), 
      			x: true,
      			child:true
    			}
  		  }
    	})
    ]
  });
}

```


<div class="grid grid-cols-1">
  <div class="card">
    ${resize((width) => hadChildrenAgesChart(hadChildrenAges, {width}))}
  </div>
</div>


<!-- 
<div class="grid grid-cols-1">
  <div class="card">
    ${resize((width) => hadChildrenYearsChart(hadChildrenAges, {width}))}
  </div>
</div>
 -->