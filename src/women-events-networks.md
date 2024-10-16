---
theme: dashboard
title: Events networks
---


# Women's events networks

An experimental interactive network graph created from the events data at [BN Notes events analysis](https://beyond-notability.github.io/bn_notes/posts/events-2024-02-26/).

Links are created between women on the basis of attendance *at the same event* instance (fuller nerdy explanation at the BN Notes post but this meant a one-off event like a named conference or one dated occurrence of a recurring event like an annual meeting). I will try to add date labels later.

Size of nodes (roughly) reflects a person's number of event attendances. Width of connecting lines reflects the number of connections between a pair. Node colours represent groups detected by R. I'm still experimenting a bit but most of the algorithms available seem to give very similar results. Completely isolated nodes were removed from the network.

Because labels are long and overlap a lot, only women with at least 10 event attendances have a visible name label, but you can see all the other names on hovering. 
 
It may be a bit small on a laptop screen if the sidebar menu is open, but will expand if you close the menu (click on the arrow). It's unlikely to look very nice on a phone!


```js
// https://observablehq.com/framework/lib/d3
// https://richardbrath.wordpress.com/2018/11/24/using-font-attributes-with-d3-js/
 
const width = 1200;
const height = 1200;
const color = d3.scaleOrdinal(d3.schemeCategory10);

  // The force simulation mutates links and nodes, so create a copy
  // so that re-evaluating this cell produces the same result.
  const links = data.links.map(d => ({...d}));
  const nodes = data.nodes.map(d => ({...d}));

  // Create a simulation with several forces.
  const simulation = d3.forceSimulation(nodes)
      .force("charge", d3.forceManyBody())
      .force("link", d3.forceLink(links).id(d => d.id))
      .force("charge", d3.forceManyBody().strength(-200)) // .distanceMin(10)
      .force("center", d3.forceCenter(0, 0))
      .force("x", d3.forceX())
      .force("y", d3.forceY());
      
      
     

  // Create the SVG container.
  const svg = d3.create("svg")
      .attr("width", width)
      .attr("height", height)
      .attr("viewBox", [-width / 2, -height / 2, width, height])
      .attr("style", "max-width: 100%; height: auto;");

  // Add a line for each link, and a circle for each node.
  const link = svg.append("g")
    .attr("stroke", "#999")
    .attr("stroke-opacity", 0.4)
    .selectAll("line")
    .data(links)
    .join("line")
    .attr("stroke-width", d => d.value); // width of lines

	// circles
  const node = svg.append("g")
    .attr("stroke", "gray")
    .attr("stroke-width", 1)
    .selectAll("circle")
    .data(nodes)
    .join("circle")
      .attr("r", d => getRadius(d.n_event))
      .attr("fill", d => color(d.grp3))   
      .style("fill-opacity", 0.5)
      .call(drag(simulation));


	// labels
  const text = svg.append("g")
    .attr("class", "labels")
    .selectAll("text")
    .data(nodes)
    .enter().append("text")
    .attr("dx", d => d.x)
    .attr("dy", d => d.y)
    .attr("opacity", 0.8)
    .attr("font-family", "Arial")
    .style("font-size","14px")
    .text(function(d) { return d.name_label })
    .call(drag(simulation));

  
  
  // tooltips
  node.append("title")
      .text(d => d.id);
      
  
  // Set the position attributes of links and nodes each time the simulation ticks.

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

  function zoomed() {
    node.attr("transform", d3.event.transform);
    link.attr("transform", d3.event.transform);
    text.attr("transform", d3.event.transform);
  }  
  
  display(svg.node() );
```


```js
// helper function for drag interaction

function drag(simulation) {

  function dragstarted(event) {
    if (!event.active) simulation.alphaTarget(0.3).restart();
    event.subject.fx = event.subject.x;
    event.subject.fy = event.subject.y;
  }

  function dragged(event) {
    event.subject.fx = event.x;
    event.subject.fy = event.y;
  }

  function dragended(event) {
    if (!event.active) simulation.alphaTarget(0);
    event.subject.fx = null;
    event.subject.fy = null;
  }

  return d3.drag()
      .on("start", dragstarted)
      .on("drag", dragged)
      .on("end", dragended);
}

```



```js

function getRadius(useCasesCount){
		var	m=useCasesCount/1.5
		var d=3/useCasesCount
  if(useCasesCount>=7){   
  	var radius = m+d  
    return radius
  }
  return 6
}
```

```js

// events data. group col is grp2, grp3, grp4 otherwise should match mis examples.
const data = FileAttachment("data/l_networks_events/bn-events.json").json();
```
