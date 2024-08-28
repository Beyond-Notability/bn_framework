import * as Plot from "npm:@observablehq/plot";


export function residedTypesChart(data, {width}) {

return Plot.plot({
title: "Resided at dates",
  x: {grid: true, label:"count"},
  y: {label: null},
  //color: {legend: true},
  width,
  height:400,
  marginLeft: 80,
  marks: [
    Plot.ruleX([0]),
    Plot.rectX(
    	data, 
    	Plot.groupY({x: "count"}, {y:"date_prop_label", sort: {y: "x", reverse: true} }) )
  ]
});
}

// adding more things
//export function datesChartY(data, {width}, plotTitle, plotHeight) {

//  return Plot.plot({
  
//    title: plotTitle, 
    
//    width,
//    height: plotHeight, // 2000,


export function residedFacetedStackedDot(data, {width}) {
 
return Plot.plot({
  //aspectRatio: 1,
  x: {label: "Age (years)"},
  y: {
    grid: true,
    label: "← resided at · other →",
    labelAnchor: "center",
    tickFormat: Math.abs
  },
  marks: [
    Plot.dot(
      data,
      Plot.stackY2({
       fx: "group",
        x: "age",
        y: (d) => d.residence === "resided at" ? 1 : -1,
        r: 2.5,
        fill: "residence",
        //title: "full_name"
      })
    ),
    Plot.ruleY([0])
  ]
})
}


export function residedStackedDot(data, {width}) {
 
return Plot.plot({
  //aspectRatio: 1,
  x: {label: "Age (years)"},
  y: {
    grid: true,
    label: "← resided at · other →",
    labelAnchor: "center",
    tickFormat: Math.abs
  },
  marks: [
    Plot.dot(
      data,
      Plot.stackY2({
       
        x: "age",
        y: (d) => d.residence === "resided at" ? 1 : -1,
        fill: "residence",
        r:1.5,
        //title: "full_name"
      })
    ),
    Plot.ruleY([0])
  ]
})
}




export function residedEarlyLateBeeswarm(data, {width}) {

return Plot.plot({
  y: {grid: true},
  color: {legend: true},
  marks: [
    Plot.dot(data, 
    	Plot.dodgeX("middle", 
    		{fx: "group", 
    		 y: "age", 
    		 fill: "residence",
    		 tip: {
    		 	format: {
    		 		fill: false,
    		 		fx: false, 
    		 		y: true,
    		 		property: true,
    		 		year: (d) => `${d}`
    		 	}
    		 },
    		 channels: {
    		 		//name:"personLabel", // maybe?
	    		 	property:"propertyLabel",
	    		 	year: "year"
    		 }
    	 },
    	)	
    )
  ]
})
}