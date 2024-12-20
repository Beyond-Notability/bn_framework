import * as Plot from "../../_npm/@observablehq/plot@0.6.16/_esm.js";



export function hadChildrenAgesChart(data, lastAges, workYearsWithChildren, servedYearsWithChildren, {width}) {

  return Plot.plot({
  
    title: "The ages at which BN women had children, sorted by mothers' dates of birth",
    
    width,
    height: 1600,
    marginTop: 10,
    marginLeft: 180,
    
    x: {
    	grid: true, 
    	label: "age at birth of child", // why does this not show at top as well?
    	axis: "both" // "both" top and bottom. [null for nothing.]
    	},
    y: {label: null}, // this affects tooltip label too
    
    marks: [
      
      // horizontal guideline
      // age 15 to last event. 
      Plot.ruleY(lastAges, {
      	x1:15, x2: "last_age", // ?need to incorporate work ages into last_age...
      	y: "personLabel", 
      	stroke: "lightgray" , 
      	strokeWidth: 1,
      channels: {
      	yob: 'bn_dob_yr', 
      	year:"year"
      	}, 
      	sort: {y: 'yob'} // sort only needed once?
      }),
     	
      
      // horizontal thicker line first child to last child. 
        Plot.ruleY(data, {
      	x1:"start_age", x2: "last_age", // x1 to start this at 15 as well. need to incorporate work ages into last_age...
      	y: "personLabel", 
      	stroke: "lightgray" , 
      	strokeWidth: 3,
      channels: {
      	yob: 'bn_dob_yr', 
      	year:"year"
      	}, 
      	//sort: {y: 'yob'} // sort only needed once?
      }),
      
      // vertical ruled line
      // needs to come *after* leftmost ruleY
      Plot.ruleX([15]), // makes X start at 15. 
         
      // dots for work
    	Plot.dot(workYearsWithChildren , 
    		{
    			x:"work_age",
    			y:"personLabel",
    			strokeOpacity:0.7,
    			r:4,
    			title: "positions", // TODO better tips
    			//channels: {
    			//	"positions": "positions",
    			//},
    			tip: {
    			//format: {
      			  //y: false, // now need to exclude this explicitly
      			  //x: false
    			//},
    			anchor:"top", // tips below the line
    			}
    		}
    	)  ,

			// dots for served on
    	Plot.dot(servedYearsWithChildren , 
    		{
    			x:"served_age",
    			y:"personLabel",
    			strokeOpacity:0.7,
    			r:3.5,
    			symbol: "diamond",
    			title: "service", // TODO better tips
    
    			tip: {
    			//format: {
      			  //y: false, // now need to exclude this explicitly
      			  //x: false
    			//},
    			anchor:"top", // tips below the line
    			}
    		}
    	)  ,
    	   
    	// barcode style for birth years
      Plot.tickX(data, 
      	{
      		x: "age", 
      		y: "personLabel" , 
      		strokeWidth: 2,
      		tip:true,
      		channels: {
      			"child born":"year", 
      			child:"childLabel", 
      			"year of birth":"bn_dob_yr", 
      			//woman: "personLabel"
      		} , 
      	//sort: {y: 'yob'} , // sorting again doesn't seem to be needed
      	// tooltips
  			tip: {
    			format: {
    				//woman: true, // added channel for label.
      			y: false, // now need to exclude this explicitly
    				"year of birth": (d) => `${d}`,
      			"child born": (d) => `${d}`, // TODO proper date formatting?
      			x: true,
      			child:true
    			},
    			anchor:"bottom" // tips above the line
  		  } 
    	}), // /tick

    	
    ] // /marks
  }); // /plot
} // /function

// channels to reference more data variables; can be called anything
// i think you only need to do the sort once
// seems clunky to make y label empty then define same variable as a channel for tooltip then exclude y again! maybe there's a better way to keep y label for tooltip but omit from y axis...
