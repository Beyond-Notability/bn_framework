import * as Plot from "../../_npm/@observablehq/plot@0.6.15/_esm.js";

export function datesChartY(data, {width}) {

  return Plot.plot({
  
    title: "Every date as a dot",
    
    width,
    height: 2000,
    marginTop: 10,
    marginLeft: 0,
    
   x: {label: "year",  axis:"top"}, //round: true, nice: d3.utcYeartype: "point",
    y: {label: null},
    
    color: {legend: true, 
    				range: ["#1f77b4", "green", "#ff7f0e", "#8c564b", "#bdbdbd"],
    				domain: ["birth", "death", "education", "work", "other"]
    				},
    				
    marks: [
    	

    	// dots
    	
    	Plot.dot(
    	
    	data.filter((d) => d.year>1790), 
    	//data, 
    	
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
      				"date precision": (d) => `${d}`, 
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
