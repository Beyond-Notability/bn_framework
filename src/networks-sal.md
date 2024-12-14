---
theme: dashboard
title: SAL elections
toc: false
---


# SAL Elections Networks


Explore connections between FSA candidates, proposers and (personal) signers. Read alongside [analyses at the other blog](https://beyond-notability.github.io/bn_notes/blog.html#category=SAL).


<div class="card">
${importantNote()}
</div>


The complete network contains 439 people (nodes) and 4468 pairs, which makes it very difficult to read. But many of those people appeared in only one election, so the default view for the minimum link weight slider has been set at 2. This will effectively remove anyone who was only involved in one election as well as single occurrence pairs.

It's an *association network*: a connection is assumed when two people appear in the same election as candidate, proposer or signers. There might not be any direct connection between signers in particular. However, they are linked by knowing the candidate, and including them can help to tease out less visible connections. This is another reason to filter out pairs that co-occur only once; the more often a pair co-occur the more likely it is that there's a significant link between them. 

(Also note that it's an "undirected" network, meaning that all links are treated as equal. I'd like to have made it a *directed* network that would better reflect the differences in the relationships, but unfortunately my skill levels weren't quite up to that yet.)
  

Overview
-------

interactions:

- hover over a node to temporarily highlight its network
- click on node to fix highlighting
- click outside nodes to reset

hover/click can be a bit temperamental, but they do work in this version!



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




```js
chartHighlight(weightData)
```



## Individuals

Select names in the dropdown to see their personal networks.


```js 
//filter method  //https://observablehq.com/@asgersp/d3-force-directed-graph-with-input
//
const filterId = view(
		Inputs.select(
				//["All"].concat(data.nodes.map(d => d.id)),
				weightData.nodes.map((d) => d.id ),
				{
				label: "node", 
				//sort: true, 
				unique: true, 
				}
				)
		)
```



```js 
//slider2 - link weights. 
// problem with doing weight first: this is always for the network, not the individual

// get min and max for slider range
const minWeight2 = d3.min(data.links.map(d => d.weight));
const maxWeight2 = d3.max(data.links.map(d => d.weight))

const weightConnections2 = view(
	Inputs.range(
		[minWeight2, maxWeight2], {
  		label: "minimum link weight",
  		step: 1,
  		value: 2 // default to min 2
		}
	)
)
```





```js
chartSelect(selectData)
```





```js
  
// data for chartSelect. 

// try to start with weight filter then > select...
// what if you made this an appearances filter rather than weight? would be a node filter though

const weightLinks2 = data.links.filter(l => l.weight >= weightConnections2);
const weightNodes2 = data.nodes.filter((n) =>
    weightLinks2.some((l) => l.source === n.id || l.target === n.id)
  );
const weightData2 = {nodes: weightNodes2, links: weightLinks2};



//individuals dropdown (with "All"; it's irrelevant here, but might not always be). output = selectData.

  let selectLinks = []
  let selectNodes = []
  
  if(filterId === "All"){
  
     selectLinks = weightData2.links.map(d => ({...d}) ) ; 
     selectNodes = weightData2.nodes.map(d => ({...d}) );
     
  } else {
  
    selectLinks = weightData2.links.filter(d => d.source == filterId || d.target == filterId).map(d => ({...d}));
    const otherPersons = selectLinks.map(d => d.source !== filterId ? d.source : d.target)
    selectNodes = weightData2.nodes.filter(d => d.id == filterId || otherPersons.indexOf(d.id) >= 0).map(d => ({...d}));
  }
  
  const selectData = {nodes: selectNodes, links: selectLinks};
  
```





```js

function chartSelect(chartSelectData) {

const height = 500;

  // The force simulation mutates links and nodes, so create a copy
  // so that re-evaluating this cell produces the same result.
  
  const links = chartSelectData.links.map(d => Object.create(d)); 
  const nodes = chartSelectData.nodes.map(d => Object.create(d));


  // Create a simulation with several forces. 
  
  const simulation = d3.forceSimulation(nodes)
      .force("link", d3.forceLink(links).id(d => d.id))
      .force("charge", d3.forceManyBody().strength(-300))
      .force("center", d3.forceCenter(0, 0))
      .force("x", d3.forceX())
      .force("y", d3.forceY())
      .force("collide", d3.forceCollide(40).iterations(2))
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
      .attr("r", d => getRadius(d.degree/5)) // tweak
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

function chartHighlight(chartData) {

const height = 800;

  const links = chartData.links.map(d => Object.create(d));
  const nodes = chartData.nodes.map(d => Object.create(d));
  
    // Create the SVG container.
  
  const svg = d3.create("svg")
      .attr("width", width)
      .attr("height", height)
      .attr("viewBox", [-width / 2, -height / 2, width, height])
      .attr("style", "max-width: 100%; height: auto;");
  
  
  // create link reference
  let linkedByIndex = {};
  chartData.links.forEach(d => {
    linkedByIndex[`${d.source},${d.target}`] = true;
  });
  
  // nodes map
  let nodesById = {};
  chartData.nodes.forEach(d => {
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

// overlap/collide etd: check https://observablehq.com/@d3/collision-detection/2?collection=@d3/d3-force 
// https://observablehq.com/@d3/forcecenter-strength?collection=@d3/d3-force
// https://observablehq.com/@d3/clustered-bubbles?collection=@d3/d3-force

// .force("link", d3.forceLink(links).id(d => d.id).distance(30).strength(0.25))

  const simulation = d3.forceSimulation()
    .force("link", d3.forceLink().id( function(d) { return d.id; } ).strength(0.3)) 
		.force("charge", d3.forceManyBody().strength(-400) ) //
		.force("center", d3.forceCenter(0,0))
		
		// avoid (or reduce) overlap. 
		.force("collide", d3.forceCollide().radius(d => getRadius(d) + 20).iterations(2))  
     
      .force("x", d3.forceX())
      .force("y", d3.forceY());
		

  const link = baseGroup.append("g")
      .selectAll("line")
      .data(links)
      .join("line")
      //.classed('link', true) // aha now width works.
      .attr("stroke", "#bdbdbd") 
      .attr("stroke-opacity", 0.4) // is this working? works with attr instead of style
      .attr("stroke-width", d => d.value) ;
          
      
  

  const node = baseGroup.append("g")
      .selectAll("circle")
      .data(nodes)
      .join("circle")
      .classed('node', true)
      .attr("r", d => getRadius(d.degree/5)) // can tweak this
      .attr("fill", d => color(d.grp_leading_eigen))  
      .style("fill-opacity", 0.6)  
      .call(drag(simulation)); // this is what was missing for drag...
       


    
  // text labels 
  // stuff has to be added in several places after this to match node and link.
 
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
        const content = `${d.id}<br/>${d.nn} elections`;
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
// shared between the charts


function getRadius(useCasesCount){
		var	m=useCasesCount/1.5
		var d=3/useCasesCount
  if(useCasesCount>=9){   
  	var radius = m+d  
    return radius
  }
  return 8
}

const color = d3.scaleOrdinal(d3.schemeCategory10);
```






```js
//function drag(simulation) {}
```


```js
const tooltip = d3.select("body").append("div")
  .attr("class", "svg-tooltip")
    .style("position", "absolute")
    .style("visibility", "hidden")
    .text("I'm a circle!");
```










```js 
html
`<style>         
    .node {
        stroke: #f0f0f0;
        stroke-width: 1px;
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
// data for chartHighlight. slider.  output = weightData

const weightLinks = data.links.filter(l => l.weight >= weightConnections);
const weightNodes = data.nodes.filter((n) =>
    weightLinks.some((l) => l.source === n.id || l.target === n.id)
  );
const weightData = {nodes: weightNodes, links: weightLinks}
```






```js
// data
const data = FileAttachment("./data/l_networks_sal_elections_v2/bn-sal-elections_v2.json").json();

```





```js
// Import components
import {drag, importantNote} from "./components/networks.js";
```


```js



```

