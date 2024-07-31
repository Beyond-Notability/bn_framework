import MarkdownItFootnote from "markdown-it-footnote";

// See https://observablehq.com/framework/config for documentation.
export default {
  // The project’s title; used in the sidebar and webpage titles.
  title: "Beyond Notability",
	cleanUrls: false,  

  // The pages and sections in the sidebar. If you don’t specify this option,
  // all pages will be listed in alphabetical order. Listing pages explicitly
  // lets you organize them into sections and have unlisted pages.
  // not essential if the cleanUrls setting works (not available in early versions)
  
//  pages: [
//    {
//      name: "Pages",
//      pages: [
//      //  {name: "Events", path: "/example-dashboard"},
//        {name: "Women at Events", path: "/women-event-types.html"},
//        {name: "Event Types", path: "/event-types.html"}
//      ]
//    }
//  ],


  // Some additional configuration options and their defaults:
  // theme: "default", // try "light", "dark", "slate", etc.
  // header: "", // what to show in the header (HTML)
  // footer: "Built with Observable.", // what to show in the footer (HTML)
  // toc: true, // whether to show the table of contents
  // pager: true, // whether to show previous & next links in the footer
  
  root: "src", // path to the source root for preview
  output: "docs", // path to the output root for build
  
  // search: true, // activate search

	// markdown extension
  markdownIt: (md) => md.use(MarkdownItFootnote)

};