import * as Plot from "npm:@observablehq/plot";
import * as d3 from "npm:d3";
import {html} from "npm:htl";


export function importantNote() {
  return html`
<p>This type of chart is exploratory and probabilistic rather than definitive: it can suggest connections and groupings among individuals for further investigation. It can be particularly useful for bringing less obvious connections to the surface. But it comes with the risk that apparent links may be illusory. </p>
<p>Various features of the charts are intended to help to assess the significance of such links:
<ul>
<li>the size of circles (aka nodes) reflects how many connections an individual has overall ("degree")</li>
<li>the width of the lines connecting nodes (aka links or edges) reflects the number of times a pair of individuals appeared together ("link weight")</li>
<li>the colour of nodes groups together algorithmically detected "clusters" (but has no other significance)</li>
<li>in the main chart, further information such as number of appearances can be viewed on hovering/clicking a node</li>
</ul>
</p>
<p>The smaller chart is currently not quite working as intended. It doesn't show the selected node's network as such, only its own links. Secondly, I'm not certain that everyone in the network appears in the dropdown. I don't know if I'll have time to fix this.</p>
 `;
}


// this seems to be pretty much identical across charts
export function drag(simulation) {

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

// don't seem to be able to make this a thingy in the function?
// need better colour function 
const color = d3.scaleOrdinal(d3.schemeCategory10);

//this seems to be fine except for invalidation.then

// but quite a few things you'd want to be able to adjust...

//.force("charge", d3.forceManyBody().strength(-620))
//      .force("center", d3.forceCenter(0, 0))
//      .force("x", d3.forceX())
//      .force("y", d3.forceY())
//      .force("collide", d3.forceCollide(40))
//			.attr("stroke-width", d => d.weight);
//      .attr("r", d => getRadius(d.degree)) // tweak
//      .attr("fill", d => color(d.grp_leading_eigen)) 
//  .text(function(d) { return d.id })

export function networkChart(data, width, height) {

  // The force simulation mutates links and nodes, so create a copy
  // so that re-evaluating this cell produces the same result.
  
    const links = data.links.map(d => Object.create(d));
    const nodes = data.nodes.map(d => Object.create(d));
     

  // Create a simulation with several forces. 
  const simulation = d3.forceSimulation(nodes)
      //.force("charge", d3.forceManyBody()) // why forceManyBody twice?
      .force("link", d3.forceLink(links).id(d => d.id))
      .force("charge", d3.forceManyBody().strength(-620))
      .force("center", d3.forceCenter(0, 0))
      .force("x", d3.forceX())
      .force("y", d3.forceY())
      .force("collide", d3.forceCollide(40))
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
      .attr("stroke-width", d => d.weight); // width of lines ? is this right?


	// circles
  const node = svg.append("g")
      .attr("stroke", "#fff")
      .attr("stroke-width", 1)
      .selectAll("circle")
      .data(nodes)
      .join("circle")
      .attr("r", d => getRadius(d.degree)) // tweak
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
  

  //invalidation.then(() => simulation.stop()); 
  // can't work out how to import invalidation, but it works without it...

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


// display and appearance related stuff

// make very big nodes a bit smaller and very small nodes a bit bigger.
// can do final tweaks inside chart code.
// my maths is a bit shaky here, probably need to check this
function getRadius(useCasesCount){
		var	m=useCasesCount/2
		var d=3/useCasesCount
  if(useCasesCount>=9){   
  	var radius = m+d  
    return radius
  }
  return 8
}

