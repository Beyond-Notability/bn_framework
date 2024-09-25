---
theme: dashboard
title: Todo
toc: true
---

Summary of pages
------

1. All the dates data, with filters for categories
2. Childbirth and other activities before and after
3. Higher education and degrees timeline 
4. Something about residence and gaps in it [WIP] 
6. Networks around excavation; if there is enough data. [analysis WIP] 

Other pages retained (for now) for reference. 

Updated 12/8/24 to use Github Actions.


All the dates
------------
 
- category filters



Childbirth
----------

- try to get toggle for activity types working! (high priority)
- Plot.axis to show label at both top and bottom is not working (cf education) and Idk why (lowish priority: not essential but desirable given that it's a tall chart, and for consistency between similar charts)

notes

- work includes `employed as` (only about 3 instances?) - maybe separate these out
- named children included (if they have a date of birth) as well as `had child in`
- upper age cutoff at 70; v few data points beyond this, doesn't significantly change interpretation but does make chart less readable (because it's trying to squish more into the same space)
- handling more than one activity in the same year:
	- there's been some reduction in preprocessing, so that only one activity per type per year is included in chart (doesn't remove that many instances)
	- if there's more than one type of activity in the same year, all symbols are visible but *only one tooltip* (order of priority: work / served / spoke)


Education
--------

- custom d3 shapes? (esp for start/end pairs)
- more sharing code between the two tables 


Residence
--------

- some viz on people with only residence data for early or late in life; 
- examples of people with gaps: look at place data between those gaps, does it help explain absent residence data? 

notes
- make sure all this chimes with history of inward migration, socio-economic class dynamics [town/country, family homes], etc


Networks
-------

- will need d3 for any network graphs... could avoid having network graphs at all... :-0
- analysis of SAL elections started but work to do on change over time (excavation networks mostly done)
