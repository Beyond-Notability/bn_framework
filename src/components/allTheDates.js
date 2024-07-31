import * as Plot from "npm:@observablehq/plot";

export function datesChartY(data, {width}) {

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
    	// tick mark? if you can work out the grouping it feels like it should be possible... and yet... https://observablehq.com/plot/marks/tick
    	
    	// the first/middle/last dates can be fixed location. 
 
    	Plot.text([`2016`], {frameAnchor: "top-right", fontSize:12, dy:-15, dx:10}), // top; dy to move above the plot area.
    	Plot.text([`1907`], {frameAnchor: "top", fontSize:12, dy:-15}), //centre
    	Plot.text([`1718`], {frameAnchor: "top-left", fontSize:12, dy:-15, dx:-10}), 
    	
    	// in between locations...  ?????
    	//Plot.text([`FIXME`], {frameAnchor: "top-left", fontSize:12, dy:-15, dx:250}), 
      //Plot.text([`FIXME`], {frameAnchor: "top-right", fontSize:12, dy:-15, dx:-250}), 
    	    	
    	//Plot.text(data, Plot.selectMinX({x:"date", frameAnchor: "top", fontSize:12, dy:-15}) ),  // shows 0 but at least it shows something. selectFirst is the same.

    	// dots
    	
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
    			} // /tip
    		 }) // /dodge
    	)  // /dot
  ] // /marks
  });
}
