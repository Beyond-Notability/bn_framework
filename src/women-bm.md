---
theme: dashboard
title: BM Reading Room and Education
toc: false
---

# In the BM Reading Room




<div class="grid grid-cols-1">
  <div class="card">
    ${resize((width) => bmYearsChart(education, {width}))}
  </div>
</div>





```js
// load data

const education = FileAttachment("./data/l_bm/educated.csv").csv({typed: true});
const bm = FileAttachment("./data/l_bm/bm.csv").csv({typed: true});


```




```js
// TODO componentise this properly

// can't get image to load; not sure what i'm doing wrong.
// Waldir, CC BY-SA 3.0 <https://creativecommons.org/licenses/by-sa/3.0>, via Wikimedia Commons
//const book_img = FileAttachment("./data/img/Black_book_icon.svg").image({width: 25})
// https://commons.wikimedia.org/wiki/File:Black_book_icon.svg

const colorTime = Plot.scale({
		color: {
			range: ["#1f77b4", "#ff7f0e", "#2ca02c", "#d62728", "lightgray"], 
			domain: ["point in time", "start time", "end time", "latest date", "filled"]
		}
	});

	
const plotHeight = 1500;
const plotMarginTop = 10;
const plotMarginLeft = 180;


// BY DATE   	
function bmYearsChart(data, {width}) {

  return Plot.plot({
  
    title: "BM Reading Room and Education",
    
    width,
    height: plotHeight,
    marginTop: plotMarginTop,
    marginLeft: plotMarginLeft,

    	
    x: {
    	grid: true, 
    	tickFormat: d3.format('d'),
    	
    	}, 
    	
    y: {label: null}, // this affects tooltip label too  
       
    symbol: {legend:true, 
    				range: ["triangle", "diamond2", "diamond2", "star", "square"], 
						domain: ["point in time", "start time", "end time", "latest date", "filled"]
		} ,
    color: colorTime,
    
    marks: [
     
      Plot.axisX({anchor: "top", 
      						label: "year of event", 
      						tickFormat: d3.format('d')}
      						),
      Plot.axisX({anchor: "bottom", 
      						label: "year of event", 
      						tickFormat: d3.format('d')}
      						),
      
      
    	// GUIDE LINES
      
    	// turn into separate rule for education? needs separate year_last as well
    	
    	// TODO split rule so that first segment between 1830 and birth is de-emphasised but still acts as a guide. just thinner atm but will look at other possible styling.
    	
      Plot.ruleY(bm, { 
      	x1:1870, // TODO variable earliest_year for when the data expands.(for the whole dataset) needs to be 0 (or 5). and has to be earliest of *either* education *or* BM. so earliest_bm doesn't work for this. 
      	x2:1920, 
      	y: "person_label", 
      	stroke: "lightgray" , 
      	strokeWidth: 1,
      channels: {"first": 'earliest_bm', "year":"year"}, 
      sort: {y: 'first'} // only need to do this once
      }),
      
      
    
    //  VERTICAL RULES
    
    	// this should be *after* left-most Y rule 
      Plot.ruleX([1870]), // makes X start at 1830. 
      //TODO variable earliest_year as above
      
      
      // DOTS
      
 			// educated at fill years for start/end pairs. draw BEFORE single points.
 			// Q is there any way to do this so the fill looks like joined up lines rather than dots?
 			
      Plot.dot(
      	data, {
      	x: "year", 
      	y: "person_label" , 
      	filter: (d) => d.year_type=="filled",
      	dy:6,
      	symbol: "year_type",
      	fill:"year_type",
      	r:4,
      	tip:false, // don't want tooltips for these!
       }
      ),
    	
    	
			// educated at single points (point in time, start/end, latest)
      Plot.dot(
      	data, {
      	x: "year", 
      	y: "person_label" , 
      	fill: "year_type",
      	symbol: "year_type",
      	filter: (d) =>  d.year_type !="filled"  &	d.src=="educated", 
      	dy:6, // vertical offset. negative=above line.
      	// tips moved to Plot.tip
    	}), // /dot
 
    	
    	// BM dot  . want to use Plot.image with book icon but it won't work!
    	Plot.dot(
      	bm, {
      	x: "year", 
      	y: "person_label" , 
      	//src: book_img, // can't get this to work.
      	symbol:"wye",
      	dy: -6, // moves the dot
      	channels: {
      		"BM year":"year", 
      		} , 
      // tooltip
  			tip: {
    			format: {
    				"BM year": (d) => `${d}`, // added channel for label. why oh why can't I just give x a different label?
    				x: false,
      			y: false, // now need to exclude this explicitly
    				
    			},
  				anchor: "bottom-left", 
  				dx: 6,
  				dy: -6
  		  }
    	}), // /dot

      
      // TOOLTIPS
            
      // tip education negative offset
    	Plot.tip(data, Plot.pointer({
    			x: "year", 
    			y: "person_label", // can you really not give this a label?
      	  filter: (d) =>  d.year_type !="filled",  // no tips on filled years!
    			anchor:"top-right",
    			dx:-6,
    			dy:6,
    			channels: {
      		//woman: "person_label",
    			//"event type":"src",
    			"education year": "year",
      		//"year of birth":"bn_dob_yr", 
      		//"age at event":"age",
      		where:"by_label",
      		qualification:"degree_label", 
      		} , 
      		format: {
      			x:false, 
      			y:false,
      			//woman: true,
      			// make these go first, do formatting
      			//"event type":true,
      			"education year": (d) => `${d}`, 
      			//"year of birth": (d) => `${d}`,
      			}
    			}
    		)	
    	), // /tip
    ]  // /marks
  });
};



```





