---
theme: dashboard
title: The big network of everything
toc: false
draft: true
---


# Women's networks


- Size of nodes reflects a person's connectedness (degree) 
- Width of connecting lines reflects the number of connections between a pair (link weight)
- Node colours represent automatically-detected clusters.


## Overview

interactions:

- hover over a node to highlight its connections
- click to make it stick so you can take a closer look
- click again in the chart outside nodes to reset.

(hover and click can be slightly temperamental)



```js 
//slider - link weights. 

// get min and max for slider range
const minWeight = d3.min(data.links.map(d => d.weight));
const maxWeight = d3.max(data.links.map(d => d.weight))

const weightConnections = view(
	Inputs.range(
		[minWeight, maxWeight], {
  		label: "Minimum link weight",
  		step: 1,
  		value: 2 // default to min 2
		}
	)
)
```

agents checkbox has equiv of groupNames (linkLabels) in the checkbox, using value: instead of key: is config:relationships which is just labels as well.

so how does it then connect to the data?

```js
//checkbox - groups
//using d3.group and then flat
// this is different... not sure i can work this...
/**/
const checkGroup = view(
	Inputs.checkbox(
			//d3.group(newdata.nodes, (d) => d.meta ), { // change data source here
			nodesData, {
			label: "group:",
			//key: ["Events", "Excavations", "RAI elections"],
			//value: groupNames, // 
			value: ["Events", "Excavations", "RAI elections"],
			sort: true
			}
)
)

```


```js echo
nodesData
```

```js
// make array of distinct values from group col. yes! 

const nodesData = [
  ...new Set(
    data.nodes  // change data source here as necessary
      .flatMap((n) => n.meta )
      .sort()
  )
]

```








```js
// data for slider.  output = weightData

const weightLinks = data.links.filter(l => l.weight >= weightConnections);
const weightNodes = data.nodes.filter((n) =>
    weightLinks.some((l) => l.source === n.id || l.target === n.id)
  );
const weightData = {nodes: weightNodes, links: weightLinks}
```




```js
chartHighlight()
```



## Individuals

Select names in the dropdown to see personal networks.


```js 
//filter method  //https://observablehq.com/@asgersp/d3-force-directed-graph-with-input
//
const filterId = view(
		Inputs.select(
				//["All"].concat(data.nodes.map(d => d.id)),
				data.nodes.map((d) => d.id ),
				{
				label: "node", 
				//sort: true, 
				unique: true, 
				}
				)
		)
```



```js
chartSelect(selectData)
```







```js
function chartHighlight() {

const height = 900

	  const links = weightData.links.map(d => Object.create(d));
	  const nodes = weightData.nodes.map(d => Object.create(d));

  //const links = data.links.map(d => Object.create(d));
  //const nodes = data.nodes.map(d => Object.create(d));
  
  const svg = d3.create("svg")
     .attr("viewBox", [-width / 2, -height / 2, width, height]); 
  
  
  // create link reference
  let linkedByIndex = {};
  data.links.forEach(d => {
    linkedByIndex[`${d.source},${d.target}`] = true;
  });
  
  // nodes map
  let nodesById = {};
  data.nodes.forEach(d => {
    nodesById[d.id] = {...d};
  })

  const isConnectedAsSource = (a, b) => linkedByIndex[`${a},${b}`];
  const isConnectedAsTarget = (a, b) => linkedByIndex[`${b},${a}`];
  const isConnected = (a, b) => isConnectedAsTarget(a, b) || isConnectedAsSource(a, b) || a === b;
  const isEqual = (a, b) => a === b;
  // todo?
  //const nodeRadius = d => 15 * d.support;


// not quite sure what the significance of baseGroup is...
  const baseGroup = svg.append("g");
  
  function zoomed() {
    baseGroup.attr("transform", d3.zoomTransform(this));
  }

  const zoom = d3.zoom()
    .scaleExtent([0.2, 8])
    .on("zoom", zoomed);
  
  svg.call(zoom);
  
  let ifClicked = false;

  const simulation = d3.forceSimulation()
    .force("link", d3.forceLink().id( function(d) { return d.id; } ).strength(0.3)) 
		.force("charge", d3.forceManyBody().strength(-400))
		.force("center", d3.forceCenter(0,0))
		// avoid (or reduce) overlap.  
		.force("collide", d3.forceCollide().radius(d => getRadius(d) + 20).iterations(2))  // what exactly is d?
      .force("x", d3.forceX())
      .force("y", d3.forceY());
		
		
  

  const link = baseGroup.append("g")
      .selectAll("line")
      .data(links)
      .join("line")
      //.classed('link', true) // aha now width works.
      .attr("stroke", "#bdbdbd") 
      .attr("stroke-opacity", 0.5) // is this working?
      .attr("stroke-width", d => d.weight) ;
      


  const node = baseGroup.append("g")
      .selectAll("circle")
      .data(nodes)
      .join("circle")
      .classed('node', true)
      .attr("r", d => getRadius(d.degree))
      .attr("fill", d => color(d.grp_leading_eigen))  
      .style("fill-opacity", 0.5)  
      .call(drag(simulation)); // this was what was missing for drag...
       
  
  
    
  // text labels - i think working correctly.
  // have to be added in several places after this to match node and link.
 
 	const text = baseGroup.append("g")
    //.attr("class", "labels")
    .selectAll("text")
    .data(nodes)
    .join("text")
    .attr("dx", d => d.x)
    .attr("dy", d => d.y)
    
    .attr("opacity", 0.8)
    .attr("font-family", "Arial")
    .style("font-size","13px")
    .text(function(d) { return d.id })
    .call(drag(simulation));
     
  
  function ticked() {
    link
        .attr("x1", function(d) { return d.source.x; })
        .attr("y1", function(d) { return d.source.y; })
        .attr("x2", function(d) { return d.target.x; })
        .attr("y2", function(d) { return d.target.y; });

    node
        .attr("cx", function(d) { return d.x; })
        .attr("cy", function(d) { return d.y; });    
    
    text 
        .attr("dx", d => d.x)
        .attr("dy", d => d.y);
        
  }


  simulation
      .nodes(nodes)
      .on("tick", ticked);

  simulation.force("link")
      .links(links);
  
  
  const mouseOverFunction = (event, d) => {
    tooltip.style("visibility", "visible")
    .html(() => {
        const content = `${d.id}<br/>${d.nnn} events`;
        return content;
      });

    if (ifClicked) return;

    node
      .transition(500)
        .style('opacity', o => {
          const isConnectedValue = isConnected(o.id, d.id);
          if (isConnectedValue) {
            return 1.0;
          }
          return 0.1;
        });

    link
      .transition(500)
        .style('stroke-opacity', o => {
        console.log(o.source === d)
      return (o.source === d || o.target === d ? 1 : 0.1)})
        .transition(500)
        .attr('marker-end', o => (o.source === d || o.target === d ? 'url(#arrowhead)' : 'url()'));
        
    text
      .transition(500)
        .style('opacity', o => {
          const isConnectedValue = isConnected(o.id, d.id);
          if (isConnectedValue) {
            return 1.0;
          }
          return 0.1;
        });
        
  };

  const mouseOutFunction = (event, d) => {
  
    tooltip.style("visibility", "hidden");

    if (ifClicked) return;

    node
      .transition(500)
      .style('opacity', 1);

    link
      .transition(500)
      .style("stroke-opacity", o => {
        console.log(o.value)
      });

	 	text
      .transition(500)
      .style('opacity', 1);




  };
  
  
  const mouseClickFunction = (event, d) => {
  
    // we don't want the click event bubble up to svg
    event.stopPropagation();
    
    ifClicked = true;
    
    node
      .transition(500)
      .style('opacity', 1)

    link
      .transition(500);
      
    text
      .transition(500)
      .style('opacity', 1)
 
 
    node
      .transition(500)
        .style('opacity', o => {
          const isConnectedValue = isConnected(o.id, d.id);
          if (isConnectedValue) {
            return 1.0;
          }
          return 0.1
        })

    text
      .transition(500)
        .style('opacity', o => {
          const isConnectedValue = isConnected(o.id, d.id);
          if (isConnectedValue) {
            return 1.0;
          }
          return 0.1
        })


    link
      .transition(500)
        .style('stroke-opacity', o => (o.source === d || o.target === d ? 1 : 0.1))
        .transition(500)
        .attr('marker-end', o => (o.source === d || o.target === d ? 'url(#arrowhead)' : 'url()'));
        
  };
  
  
  node.on('mouseover', mouseOverFunction)
      .on('mouseout', mouseOutFunction)
      .on('click', mouseClickFunction)
      .on('mousemove', (event) => tooltip.style("top", (event.pageY-10)+"px").style("left",(event.pageX+10)+"px"));
  
  svg.on('click', () => {
    ifClicked = false;
    node
      .transition(500)
      .style('opacity', 1);

    link
      .transition(500)
      .style("stroke-opacity", 0.5)

    text
      .transition(500)
      .style('opacity', 1);
    
    
  });

  invalidation.then(() => simulation.stop());

  return svg.node();
}

```








```js

function chartSelect(chartData) {

const height = 500


  // The force simulation mutates links and nodes, so create a copy
  // so that re-evaluating this cell produces the same result.

  const links = chartData.links.map(d => Object.create(d)); 
  const nodes = chartData.nodes.map(d => Object.create(d));


  // Create a simulation with several forces. 
  const simulation = d3.forceSimulation(nodes)
      .force("link", d3.forceLink(links).id(d => d.id))
      .force("charge", d3.forceManyBody().strength(-400))
      .force("center", d3.forceCenter(0, 0))
      .force("x", d3.forceX())
      .force("y", d3.forceY())
      .force("collide", d3.forceCollide(30))
      ;
     

  // Create the SVG container. 
  const svg = d3.create("svg")
      .attr("viewBox", [-width / 2, -height / 2, width, height]);


  // Add a line for each link, and a circle for each node.
  const link = svg.append("g")
      .attr("stroke", "#999")
      .attr("stroke-opacity", 0.4)
      .selectAll("line")
      .data(links)
      // https://www.createwithdata.com/d3-has-just-got-easier/
      .join("line")
      
      //.attr("stroke-width", d => Math.sqrt(d.value));
      .attr("stroke-width", d => d.weight); // width of lines


	// circles
  const node = svg.append("g")
      .attr("stroke", "#fff")
      .attr("stroke-width", 1)
      .selectAll("circle")
      .data(nodes)
      .join("circle")
      .attr("r", d => getRadius(d.nnn)) // tweak
      .attr("fill", d => color(d.grp_leading_eigen))  
      .style("fill-opacity", 0.6)
      .attr("stroke", "black")
      .style("stroke-width", 1)
        
      .call(drag(simulation));
  
  
  // labels
  var text = svg.append("g")
    .attr("class", "labels")
    .selectAll("text")
    .data(nodes)
    .enter().append("text")
    .attr("dx", d => d.x)
    .attr("dy", d => d.y)
    
    .attr("opacity", 0.8)
    .attr("font-family", "Arial")
    .style("font-size","14px")
    .text(function(d) { return d.id })

    .call(drag(simulation));

  
  
  node.append("title")
      .text(d => d.id);
      
  

  simulation.on("tick", () => {
    link
        .attr("x1", d => d.source.x)
        .attr("y1", d => d.source.y)
        .attr("x2", d => d.target.x)
        .attr("y2", d => d.target.y);

    node
        .attr("cx", d => d.x)
        .attr("cy", d => d.y);
    
    text
        .attr("dx", d => d.x)
        .attr("dy", d => d.y);
  });
  

  invalidation.then(() => simulation.stop());

  svg.call(d3.zoom()
      .extent([[0, 0], [width, height]])
      .scaleExtent([0.2, 10])
      .on("zoom", zoomed));

// https://stackoverflow.com/a/71011116/7281022
// zoomTransform(this) rather than transform 
  function zoomed() {
  	//svg.attr("transform", d3.zoomTransform(this));
    node.attr("transform", d3.zoomTransform(this));
    link.attr("transform", d3.zoomTransform(this));
    text.attr("transform", d3.zoomTransform(this));
  }  
  
  return svg.node();

}

```








```js
// data for individuals dropdown (with "All"; it's irrelevant here, but might not always be). output = selectData.

// apparently these are necessary in this if/else setup, though idk why
  let selectLinks = []
  let selectNodes = []
  
  if(filterId === "All"){
     selectLinks = data.links.map(d => ({...d}) ) ; 
     selectNodes = data.nodes.map(d => ({...d}) );
     
  } else {
  
    selectLinks = data.links.filter(d => d.source == filterId || d.target == filterId).map(d => ({...d}));
    const otherPersons = selectLinks.map(d => d.source !== filterId ? d.source : d.target)
    selectNodes = data.nodes.filter(d => d.id == filterId || otherPersons.indexOf(d.id) >= 0).map(d => ({...d}));
  }
  
  const selectData = {nodes: selectNodes, links: selectLinks};
```





```js
const tooltip = d3.select("body").append("div")
  .attr("class", "svg-tooltip")
    .style("position", "absolute")
    .style("visibility", "hidden")
    .text("I'm a circle!");
```





```js

function getRadius(useCasesCount){
		var	m=useCasesCount/3
		var d=3/useCasesCount
  if(useCasesCount>=6){   
  	var radius = m+d  
    return radius
  }
  return 6
}


const color = d3.scaleOrdinal(d3.schemeCategory10);
```



```js
//function drag(simulation) {}
```




```js 
html
`<style>         
    .node {
        stroke: #f0f0f0;
        stroke-width: 0px;
    }

    .link {
        stroke: #999;
        stroke-opacity: .4;
        stroke-width: 0.5;
    }

    .group {
        stroke: #fff;
        stroke-width: 1.5px;
        fill: #fff;
        opacity: 0.05;
    }
    .svg-tooltip {
     // font-family: -apple-system, system-ui, BlinkMacSystemFont, "Segoe UI", Helvetica, Arial, sans-serif, "Apple   Color Emoji", "Segoe UI Emoji", "Segoe UI Symbol";
      background: rgba(69,77,93,.9);
      border-radius: .1rem;
      color: #fff;
      display: block;
      font-size: 12px;
      max-width: 320px;
      padding: .2rem .4rem;
      position: absolute;
      text-overflow: ellipsis;
      white-space: pre;
      z-index: 300;
      visibility: hidden;
    }

    svg {
       // background-color: #333;
    }
</style>`
```




```js
// events data. 
const data = FileAttachment("./data/l_networks_grouped/bn-grouped-network.json").json();
```




```js
// Import components
import {drag} from "./components/networks.js";
```




 
```js 
// = agents `data` from `raw`. may need this if meta gets more complex, but dont at the moment. keep for reference...
/*Normalise the data
* Transform person {config.title.toLowerCase()} with no gender into unknown gender.
* Flatten the meta information. agents has different types of meta, which you don't at the moment
* Remove nodes with no links.
* Copy the meta information into the links for easier filtering. - do that in R if you want it.

const newnodes = data.nodes
    .map((n) => {
      
      n.meta =
        n.meta !== undefined ? Object.values(n.meta).flatMap((m) => m) : [];

      return n;
    })
    .filter((n) =>
      data.links.some((e) => e.source === n.id || e.target == n.id)
    );

  const newlinks = data.links
  .map( (e) => {
    const nodes = data.nodes.filter(
      (n) => n.id === e.source || n.id === e.target
    );
    e.meta = nodes.flatMap((n) => (n.meta !== undefined ? n.meta : []));

    return e;
  });

  const newdata = {nodes:newnodes, links:newlinks};
*/


```
