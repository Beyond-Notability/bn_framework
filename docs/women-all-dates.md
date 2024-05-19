---
theme: dashboard
title: All the Dates
toc: false
---


# All The Dates

```js
const dates = FileAttachment("./data/dates_simple_all.json").json({typed: true});
```



<!-- 
data variables
"person"         "personLabel"    "propLabel"      "psvLabel"       "qual_dateLabel" "prop_label"     "date_value"     "s"              "prop"           "psv"            "qual_date"     

 -->

```js
function datesChart(data, {width}) {
  return Plot.plot({
    title: null,
    width,
    height: 800,
    marginTop: 0,
    marginLeft: 0,
    y: {label: null, type: "point", axis:null}, //, round: true, nice: d3.utcYear
    x: {label: null},
    //color: {...color, legend: true}, //TODO

    marks: [
    	Plot.dotY(data, 
    		Plot.dodgeX({
    			y: "date", 
    			//title:"personLabel", // can't have this and tips!
    			anchor:"middle", 
    			fill:"currentColor", 
    			padding:0.6, r:3.5, sort:"date", 
    			tip:true,
    			channels: {
      		// label:colname
      			property: "propLabel",
      			//year:"year",  
      			woman: "personLabel"
      		} , 
      	 // tooltip
  				tip: {
  					fontSize:13,
  					lineHeight:1.3,
    				format: {
    					woman: true, // added channel for label.
    					//"year": (d) => `${d}`,  
      				property:true
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
    ${resize((width) => datesChart(dates, {width}))}
  </div>
</div>