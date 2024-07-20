---
theme: dashboard
title: Education
toc: false
---

# Timelines of higher education






```js
// toggle baby! 8-)
const makeToggleView = view(makeToggle);
```
<div class="grid grid-cols-1">
  <div class="card">
    ${makeChart(makeToggleView) }
  </div>
</div>








```js
// Import components
import {educatedAgesChart, educatedYearsChart} from "./components/education.js";
```

```js
// load data
const education = FileAttachment("data/l_dates_education/educated_degrees2.json").json({typed: true});
```


```js
// make the radio button for the toggle
const makeToggle =
		Inputs.radio(
			["dates", "ages"],  
			{
				label: "View by: ", 
				value:"dates", // preference
				}
			)


// toggle function
//i'd quite like less repetition in here but i can live with it.
const makeChart = (selection) => {
  return selection === "dates" ?  
  resize((width) => educatedYearsChart(education, {width})) : 
  resize((width) => educatedAgesChart(education, {width})) 
}


```
