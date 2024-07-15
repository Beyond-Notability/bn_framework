import * as Plot from "npm:@observablehq/plot";
import * as d3 from "npm:d3";

const color_time = Plot.scale({
		color: {
			range: ["#1f77b4", "#ff7f0e", "#2ca02c", "#d62728", "lightgray"], 
			domain: ["point_in_time", "start_time", "end_time", "latest_date", "filled"]
		}
	});

export function educatedYearsChart(data, {width}) {

  return Plot.plot({
  
    title: "higher education chronology, sorted by date of birth",
    
    width,
    height: 6000,
    marginTop: 10,
    marginLeft: 180,
    	//TODO a bit more space between top X axis labels and first rule?
    	//TODO year of event label at both top and bottom?
    	//TODO custom shapes
    	
    x: {
    	grid: true, 
    	label: "year of event", 
    	tickFormat: d3.format('d'),
    	axis: "both" // "both" top and bottom of graph. null for nothing.
    	}, 
    y: {label: null}, // this affects tooltip label too  
    
    symbol: {legend:true, range: ["diamond", "triangle", "wye", "star", "square"], 
		domain: ["point_in_time", "start_time", "end_time", "latest_date", "filled"]},	
    color: color_time,
    
    marks: [
    	
    	// RULES
      
    	// turn into separate rule for education? needs separate year_last as well
    	
    	// TODO split rule so that first segment between 1830 and birth is de-emphasised but still acts as a guide. just thinner atm but will look at other possible styling.
    	
      Plot.ruleY(data, {
      	// x1 to start this at 1830 as well. 
      	x1:1830, // TODO variable not hard coding?
      	x2:"bn_dob_yr", 
      	y: "person_label", 
      	//dy:-6, // if separate
      	stroke: "lightgray" , 
      	strokeWidth: 1,
      channels: {yob: 'bn_dob_yr', "year":"year"}, sort: {y: 'yob'} // only need to do this once?
      }),
      
      Plot.ruleY(data, {
      	// x1 to start this at 1830 as well. 
      	x1:"bn_dob_yr", // TODO variable not hard coding
      	x2:"year_last", 
      	y: "person_label", 
      	//dy:-6, // if separate
      	stroke: "lightgray" , 
      	strokeWidth: 2,
      //channels: {yob: 'bn_dob_yr', "year":"year"}, sort: {y: 'yob'} // you only need to do this once?
      }),
      
      // make separate rule for degrees? would need separate year_last - if no degrees, don't want it to draw anything
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
    
    	// this should be *after* left-most Y rule 
      Plot.ruleX([1830]), // makes X start at 1830. TODO earliest_year rather than hard coded? but needs to be 0 or 5. leave it for the moment.
      
    // 1920 etc highlight? hmm. 1878=UoL degrees. need tip/label of some sort.
     // Plot.ruleX([1878], {stroke:"pink"}),
     
      Plot.ruleX([1920], {stroke: "lightgreen"}),
    //  Plot.ruleX([1948], {stroke: "lightblue"}),
      
      
      // DOTS
      
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
			// can include filled years, but easier to control appearance separately
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

      // tooltip stuff removed

    	}), // /plot.dot
    	
    	// year of birth dot 
    	Plot.dot(
      	data, {
      	x: "bn_dob_yr", 
      	y: "person_label" , 
      	//dx: 6, // oops putting this here moves the dot not the tip!
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
  				dx: -3,
  		  }
    	}), // /dot
    	
    	// only show one tip at a time, less mess. but if you have educated/degree in the same year it only shows degree. 
    	// try X or Y variant. NOT X! bad things! Y doesn't solve the problem and behaviour can be slightly confusing. pointer without X/Y is most precise, just not quite precise enough...
    	// separated but... 
    	// could filter and have separate educated/degrees? (might want that inthe end anyway...) but will almost certainly have collision problems again.
    	// it could be something unintuitive like options for the point mark (padding/margin etc), not the tip/pointer. "only the point closest to the pointer is rendered" - so where it thinks the edges of the point are might be crucial
      // is the problem how far around a dot the tip works; could padding/margin be reduced? if so then might be fixable within dot and not need separate pointer stuff at all. but i don't think it is. in examples, precision is tight.
      // maybe the problem is what it thinks is the middle spot. think about where it puts the pointer arrow. it's not the offset dots. even if you use dx. could ?px work instead?
      //have a feeling i tried to use dy with a variable and it didn't work. it moves with a fixed number so if you separate the degrees/education into different tips you *might* fix this problem. ?
      // i think it's working better now you've got the anchors pointing different directions as well. only thing is when there's two they hide the timeline itself what if you move them up as well? but too much space makes confusing situations... i wonder if more dx would be good or bad... overlaps; apart from the weirdness it doesn't really solve the problem because now you can see there are two tips but you can still only read the top one ok change anchor position fixes that. is it possible to get rid of the pointy bit? that sort of makes you expect the point to be next to the dot it refers to. the px/py example doesn't have pointy bits or a box either... ahh it's just Pointer, not Tip. hmm.
      // The px and py channels may be used to specify pointing target positions independent of the displayed mark. px and py = completely fixed. but cna use px and y / x and py. however i think not quite right for this chart
      //they seem sort of confused almost? can get them showing when nowehre near the dot (will show for dots on person above or below, even when nowhere near on X axis). and sometimes seem to freeze. and they didn't do that when single.
      
      // TOOLTIPS
      
      // tip degrees
    	Plot.tip(data, Plot.pointer({
    			x: "year", 
    			y: "person_label", // can you really not give this a label?
    			//title: "person_label", // *only* shows person_label.
      	filter: (d) =>  d.year_type !="filled"  &	d.src=="degrees", 
    			//filter: (d) => d.year_type !="filled", // no tips on filled years!
    			anchor:"top-left",
    			//frameAnchor:"right",
    			dx:6,
    			dy:6,
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
      
      // tip education negative offset
    	Plot.tip(data, Plot.pointer({
    			x: "year", 
    			y: "person_label", // can you really not give this a label?
    			//title: "person_label", // *only* shows person_label.
      	  filter: (d) =>  d.year_type !="filled"  &	d.src=="educated", 
    			//filter: (d) => d.year_type !="filled", // no tips on filled years!
    			anchor:"top-right",
    			dx:-6,
    			dy:-6,
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
};



export function educatedAgesChart(data, {width}) {
  return Plot.plot({
    title: "higher education and age, sorted by date of birth",
    width,
    height: 6000,
    marginTop: 10,
    marginLeft: 180,
    x: {
    	grid: true, 
    	//padding:20,
    	label: "age at event", // TODO only showing at bottom, why? year version shows both. or does it.
    	axis: "both" // "both" top and bottom of graph. null for nothing.
    	}, 
    y: {label: null}, // this affects tooltip label too  
    symbol: {legend:true, 
    				range: ["triangle", "diamond2", "diamond2", "star", "square"], 
						domain: ["point_in_time", "start_time", "end_time", "latest_date", "filled"]},
    color: color_time,
    marks: [
    	
       
      Plot.ruleY(data, {
      	// x1 to start this at 0 as well. maybe you need an age_first as well as last. but then what happens to women with only one event?
      	x1:0, 
      	x2:"age_last", 
      	y: "person_label", 
      	stroke: "lightgray" , 
      	strokeWidth: 2,
      channels: {yob: 'bn_dob_yr', "year":"year"}, sort: {y: 'yob'}
      }),
      
      // this should be after (on top of) leftmost ruleY
      Plot.ruleX([0]), // makes X start at 0.
 
 			// educated at fill years, no tips. draw before single points.
      Plot.dot(
      	data, {
      	x: "age", 
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



// channels to reference more data variables; can be called anything
// seems clunky to make y label empty then define same variable as a channel for tooltip then exclude y again! 