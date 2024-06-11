---
theme: dashboard
title: All the Dates
toc: false
---


# All The Dates

```js
const dates = FileAttachment("./data/l_dates_simple_all.json").json({typed: true});
```




<!--
// Manually set the colors using the `range`
Plot.legend({
  color: {
    type: "categorical",
    domain: d3.range(10).map(d => `Category ${d + 1}`), 
    range: ["green", "purple", "orange", "yellow", "blue", "pink", "brown", "grey", "green", "lavender"]
  }
})

what i want to do:
make "undefined" label sthg like "other" but still comes at the end of the list
and coloured grey.
-->

<!-- 
data variables
"person"         "personLabel"    "propLabel"      "psvLabel"       "qual_dateLabel" "prop_label"     "date_value"     "s"              "prop"           "psv"            "qual_date"     

 -->


```js
function datesChartY(data, {width}) {
  return Plot.plot({
    title: "Every date as a dot",
    width,
    height: 1300,
    marginTop: 0,
    marginLeft: 0,
    x: {label: null, type: "point", axis:null}, //, round: true, nice: d3.utcYear
    y: {label: null},
    color: {legend: true, 
    				range: ["#1f77b4", "green", "#ff7f0e", "#8c564b", "#bdbdbd"],
    				domain: ["birth", "death", "education", "work", "other"]
    				},
    marks: [
    	//Plot.text(data, Plot.selectFirst({x:0, text:"date", anchor:"top"})), // y and x make no difference to positioning? nor does anchor.
    	//Plot.text([`some text\nnewline`], {frameAnchor: "bottom-right", fontSize:20}), // this is right at the bottom.
    	//Plot.axisX({anchor: "top"}), 
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
      			property: "propLabel",
      			woman: "personLabel"
      		} , 
      	 // tooltip
  				tip: {
  					fontSize:13,
  					lineHeight:1.3,
    				format: {
    					woman: true, // added channel for label.
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

