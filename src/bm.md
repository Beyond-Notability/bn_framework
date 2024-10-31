---
theme: dashboard
title: BM Reading Room and Education
toc: false
---

# In the BM Reading Room




<div class="grid grid-cols-1">
  <div class="card">
    ${resize((width) => bmYearsChart(bm, education, {width}))}
  </div>
</div>





```js
// load data
const education = FileAttachment("./data/l_bm/educated.csv").csv({typed: true});
const bm = FileAttachment("./data/l_bm/bm.csv").csv({typed: true});
```



```js
// TODO componentise this properly

// why does fy:group not work ... should it be fx: ?

const colorTime = Plot.scale({
		color: {
			range: ["#1f77b4", "#ff7f0e", "#2ca02c", "#d62728", "lightgray"], 
			domain: ["point in time", "start time", "end time", "latest date", "filled"]
		}
	});

	
const plotHeight = 2000;
const plotMarginTop = 10;
const plotMarginLeft = 180;


// BY DATE   	
function bmYearsChart(bm, education, {width}) {

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
						// symbolStar not working in range here; why not???
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
      
      
    	// GUIDE LINES. a bit tricky if it can start with either bm or education. hmm.
      
    	
      Plot.ruleY(bm, { 
      	x1:1865, // TODO variable earliest_year for when the data expands.(for the whole dataset) needs to be 0 (or 5). and has to be earliest of *either* education *or* BM. so earliest_bm doesn't work for this. 
      	x2:1920, 
      	y: "person_label", 
      	stroke: "lightgray" , 
      	strokeWidth: 1,
      channels: {"first": 'earliest_bm', "year":"year"}, 
      sort: {y: 'first'} // only need to do this once
      }),
      
      
    
    //  VERTICAL RULES
    
    	// this should be *after* left-most Y rule 
      Plot.ruleX([1865]), // makes X start at 1865. 
      //TODO variable earliest_year as above
      
      // DOTS
      
 			// educated at fill years for start/end pairs. draw BEFORE single points.
 			// Q is there any way to do this so the fill looks like joined up lines rather than dots?
 			
      Plot.dot(
      	education, {
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
      	education, {
      	x: "year", 
      	y: "person_label" , 
      	fill: "year_type",
      	symbol: "year_type",
      	filter: (d) =>  d.year_type !="filled"  &	d.src=="educated", 
      	dy:6, // vertical offset. negative=above line.
      	// tips moved to Plot.tip
    	}), // /dot
 
    	
    	// BM book icon. :-)
    	Plot.image(
      	bm, {
      	x: "year", 
      	y: "person_label" , 
      	src: bookImg, 
      	//symbol:"wye",
      	dy: -6, // moves the dot
      	channels: {
      		"BM year":"year", 
      		"age": "age",
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
    	Plot.tip(education, Plot.pointer({
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
      		"age":"age",
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







```js

const bookImg = FileAttachment("./data/img/Black_book_icon.svg.png").url();

// Waldir, CC BY-SA 3.0 <https://creativecommons.org/licenses/by-sa/3.0>, via Wikimedia Commons
// https://commons.wikimedia.org/wiki/File:Black_book_icon.svg

```



