---
theme: dashboard
title: Events networks + highlight connections
---


# Women's events networks

An experimental interactive network graph created from the events data at [BN Notes events analysis](https://beyond-notability.github.io/bn_notes/posts/events-2024-02-26/).

see events networks page for explanatory notes about the network and graph basics. It has zoom, pan, drag, etc, coloured groups plus:

- click once on a node to highlight connected nodes (click again to revert)

**but** it doesn't work properly for *some* nodes, usually people at the edge of networks or very small groups (most obvious with groups of two people) and I don't understand enough of the code to work out why (yet)... it also happens to a few nodes in the original Observable notebook so I don't think it's my fault!


Based on code in this [Observable notebook](https://observablehq.com/@maliky/force-directed-graph-a-to-z).



```js
chart()
```


```js

const cscale = d3.scaleOrdinal(d3.schemeCategory10);

//TODO probably a better way to do this...
/*color = {
  const colorscale = d3.scaleOrdinal(d3.schemeCategory10);
  const color = d => colorscale(d.group);
  //return d => scale(d.group);
}*/
const height = 900;
const color = d3.scaleOrdinal(d3.schemeCategory10);

```


```js
// functionify the chart

function chart() {

  var neighList, cycleList, toggle=0;
  
  // don't have the Object.create lines here. 

  // The force simulation mutates links and nodes, so create a copy
  // so that re-evaluating this cell produces the same result.
  //const links = data.links.map(d => ({...d}));
  //const nodes = data.nodes.map(d => ({...d}));

  // Create a simulation with several forces.
  const simulation = d3.forceSimulation(nodes)
      .force("charge", d3.forceManyBody())
      .force("link", d3.forceLink(links).id(d => d.id))
      .force("charge", d3.forceManyBody().strength(-300)) // .distanceMin(10)
      .force("center", d3.forceCenter(0, 0))
      .force("x", d3.forceX())
      .force("y", d3.forceY());
      
      
     

  // Create the SVG container.
  const svg = d3.create("svg")
      .attr("viewBox", [-width / 2, -height / 2, width, height]) ;
      // .attr("viewBox", [0, 0, width, height]); possibly

  // Add a line for each link, and a circle for each node.

  const linkG = svg.append('g').attr('id', 'links')
  .attr("stroke", "#999")
  .attr("stroke-opacity", 0.3)
  .selectAll("line")
  .data(links)
  .join("line")
  .attr('class','link')
  //.attr("stroke-width", d => Math.sqrt(d.value))
   .attr("stroke-width", d => d.value)


	// circles
  const nodeG = svg.append('g').attr('id', 'nodes')
  .selectAll('.node')
  .data(nodes).enter().append('g')
  .attr('class', 'node')
    
  .call(drag(simulation));


  nodeG.on('click', connectedNodes);

  nodeG.append('circle')
    .attr("stroke", "#fff")
    .attr("stroke-width", 1)
  //v1 node. check it works here.
    .attr("r", d => getRadius(d.n_event))
    //.attr("r", 6)
    .style("fill-opacity", 0.5)
    // was getting that thing where colours change when you manually refresh! why???? i think because you did color twice...
    .attr("fill", d=>cscale(d.grp3));

  // labels needed dx/dy in simulation.on instead of x/y to put them in the right place. 

	// labels
  /*
  v1 code
  const text = svg.append("g")
    .attr("class", "labels")
    .selectAll("text")
    .data(nodes)
    .enter().append("text")
    .attr("dx", d => d.x)
    .attr("dy", d => d.y)
    .attr("opacity", 0.8)
    .attr("font-family", "Arial")
    .style("font-size","13px")
    .text(function(d) { return d.name_label })
    .call(drag(simulation));
    */
    
   nodeG.append('text')
    .attr('dx', d=> d.x )
    .attr('dy', d=> d.y )
    .attr('fill', "#000")
    .attr('font-size', "13px")
    .attr("font-family", "Arial")
    .text(d=>d.name_label) //; 
 // not sure if it makes any difference...
    //.text(function(d) { return d.name_label }) 
    .call(drag(simulation))  ;
   

  // tooltips TODO make these nicer!
  nodeG.append("title").text(d => d.id);

      
  
  // Set the position attributes of links and nodes each time the simulation ticks.

// slight diffs from v1

  simulation.on("tick", () => {
    linkG
      .attr("x1", d => d.source.x)
      .attr("y1", d => d.source.y)
      .attr("x2", d => d.target.x)
      .attr("y2", d => d.target.y);

    d3.selectAll('circle')
      .attr("cx", d => d.x)
      .attr("cy", d => d.y);

    d3.selectAll('text')
      .attr("dx", d => d.x)
      .attr("dy", d => d.y);
  });
  


// additional functions for the highlight from here

  neighList = get_neighList(nodes, links);
  cycleList = get_cycleList(nodes, links, neighList);

  function connectedNodes() {
    if (toggle == 0) {
      //Reduce the opacity of all but the neighbouring nodes
      let cv = d3.select(this).node().__data__; //current node
      nodeG.style("opacity", function (v) {
        let neighbours = neighList[cv.index];
        // debugger; 
        if  (typeof neighbours === 'undefined'){
          return 0.1;
        } else{
          return neighbours.includes(v.index)? 1 : 0.1;
        }
      });
      
      linkG.style("opacity", function (e) {
        return (cv.index === e.source.index)? 1: 0.1;
      });
      //Reduce the op
      toggle = 1;
    } else {
      //Put them back to opacity=1
      nodeG.style("opacity", 1);
      linkG.style("opacity", 1);
      toggle = 0;
    }
  }

  function connectedCycles() {
    if (toggle == 0) {
      // debugger;
      //Reduce the opacity of all but the nodes in cycles
      let cv = d3.select(this).node().__data__; //current node
      let cyclebours = cycleList[cv.index];
      nodeG.style("opacity", function (ov) {
        return (is_node_in_cyclebours(cyclebours, ov))? 1:.1;
      });

      linkG.style("opacity", function (e) {
        return (is_edge_in_cyclebours(cyclebours, e))? 1: .1;
      });
      //Reduce the op
      toggle = 1;
    } else {
      //Put them back to opacity=1
      nodeG.style("opacity", 1);
      linkG.style("opacity", 1);
      toggle = 0;
    }
  }

// end of highlight functions. 


// add zoom as in v1


  invalidation.then(() => simulation.stop());

  svg.call(d3.zoom()
      .extent([[0, 0], [width, height]])
      .scaleExtent([0.2, 10])
      .on("zoom", zoomed));

// https://stackoverflow.com/a/71011116/7281022
// zoomTransform(this) rather than transform 
  function zoomed() {
  	//svg.attr("transform", d3.zoomTransform(this));
    nodeG.attr("transform", d3.zoomTransform(this));
    linkG.attr("transform", d3.zoomTransform(this));
    //text.attr("transform", d3.zoomTransform(this));
  }  
  
  //display(svg.node() );
  
  return svg.node();
}
```



```js
// helper functions for highlight

function get_neighList(nodes, links){
    // build the list of neighbours for each nodes of the graph
    // returns an array of indexed by nodes
    
    let neighList = new Array(nodes.length);
    for (let node in nodes){
	  let neighbours = new Array();
	    // on ajoute le noeud de départ par défaut
	   neighbours.push(+node);
	   for (let i=0; i<links.length; i++){
	      if (links[i].source.index === +node){
		  neighbours.push(links[i].target.index);
	    }
	  }
	// filter out empty
	 if (neighbours.length > 1) neighList[node] = neighbours;
    
  }
    //    neighList = neighList.filter(d=>typeof d !== 'undefined');

    return neighList;
    
}
```

```js
function get_cycleList(nodes, links, neighList){
    // build the list of cyclebours for each nodes of the graph
    // returns an array of indexed by nodes
    // debugger;
    
    let cycleList = new Array(nodes.length);
    //    debugger;
    for (const node of nodes){
			let cyclebours = new Array();
			let neighbours = neighList[+node.index];
				//	cyclebours.push(+node);
			for (let len=2; len < 5; len++){
	  	  let cycles = get_cycles(len, +node.index, neighList);
	    	if (typeof cycles[0] !== []){
			cycles.map((cycle) => cyclebours.push(cycle));
	    } 
	}
	if (cyclebours.length) cycleList[node.index] = cyclebours;
    }
    //    cycleList = cycleList.filter(d=>typeof d !== 'undefined');
    return cycleList;
}
```

```js
function get_cycles(longueur, vertex, neighList){
    // renvois les cycles commençant en vertex et de longueur définie
    // debugger;
    let paths = get_voisinage_rec(longueur, new Array([vertex]), neighList);
    let cycles = new Array();
    if (typeof paths !== 'undefined'){
				paths.forEach(function(path){
	    	if (path.slice(-1)[0] === vertex) cycles.push(path.slice(0,-1));
			});
    }
    return cycles;
}
```

```js
function get_voisinage_rec(distance, voisinages, neighList){
    // Une fonction réccursive qui renvois les chemins exactement de longueur distances
    
    if (distance === 0)	return voisinages;
    let new_voisinages = new Array();
    
    for(let i in voisinages){
			let voisinage = voisinages[i];
			let cv = voisinage.slice(-1)[0];  // current vertex
			let voisins = neighList[cv];
	
			if (typeof voisins !== 'undefined'){
	  	  voisins.forEach(function(new_voize){
					if (new_voize != cv){
		    // ajoute au nouveau voisinage l'ancier plus le nouveau voisin
		    		new_voisinages.push(voisinage.concat([new_voize]));
					}
	    	});
	    	distance--;
	    return get_voisinage_rec(distance, new_voisinages, neighList);
	    };
    }
}



function is_node_in_cyclebours(cyclebours, vertex){
    // on parcours les cycle de la nodes touché
    if (typeof cyclebours === "undefined") return false;
    for (const cycle of cyclebours){
	// si la node en question est dans l'un des cycles c'est ok
	if (cycle.includes(vertex.index)) return true;
    }
    return false;
}



function is_edge_in_cyclebours(cyclebours, edge){
    // on parcours les cycle de la nodes touché
    let source = edge.source.index;
    let target = edge.target.index;
    if (typeof cyclebours === "undefined") return false;
    for (const cycle of cyclebours){
	// si la node en question est dans l'un des cycles c'est ok
	let i = cycle.indexOf(source);
	if (i < cycle.length -1){
	    if (cycle[i+1]  === target) return true;
	    /* else if last of list 
	    (which does not contain le first element but we know
	    is a cycle) */
		} else if (cycle[0] === target) return true;
  }
  return false;
}




const toggle = 0 // keeps track of higlight on or off
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
		//var	m=useCasesCount/1.5
		//var d=3/useCasesCount
  if(useCasesCount>=6){   
  	//var radius = m+d  
    //return radius
    return useCasesCount
  }
  return 5
}
```




```js
// this is the drag() function in the original notebook which didn't seem to quite work

function drag__original(simulation) {
  
  function dragstarted(d) {
    if (!d3.event.active) simulation.alphaTarget(0.3).restart();
    d.fx = d.x;
    d.fy = d.y;
  }
  
  function dragged(d) {
    d.fx = d3.event.x;
    d.fy = d3.event.y;
  }
  
  function dragended(d) {
    if (!d3.event.active) simulation.alphaTarget(0);
    d.fx = null;
    d.fy = null;
  }
  
  return d3.drag()
      .on("start", dragstarted)
      .on("drag", dragged)
      .on("end", dragended);
}


```







```js
// data stuff
const nodes = data.nodes.map(d => Object.create(d));


const links = data.links.map(createO);

function createO(d){
    let o = Object.create(d);
    //debugger;
    return o;
  }
```



```js

// events data. group col is grp2, grp3, grp4 otherwise should match mis examples.
const data = FileAttachment("data/l_networks_events/bn-events.json").json();
```

