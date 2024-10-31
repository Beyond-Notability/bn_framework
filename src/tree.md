---
theme: default
title: BN categories tree
toc: false
---

# 'Instance of' tree diagram

Does anything look out of place?

```js
const io = FileAttachment("./data/instance_of_tree.json").json();
```



```js
Plot.plot({
  axis: null,
  height: 1000,
  margin: 10,
  marginLeft: 70,
  marginRight: 100,
  marks: [
    Plot.tree(io, {textStroke: "white"})
  ]
})

// tree seems a more easily understandable layout for this data.
// cluster > Like tree, except sets the treeLayout option to d3.cluster, aligning leaf nodes, and defaults the textLayout option to mirrored.
```