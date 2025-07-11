import Toc from "./toc";
import SidebarFootnotes from "./sidebar_footnotes";
import "./md-note";
import "./smart-time";
import "./pretty-code";
import { enhanceCodeBlocks } from "./pretty-code";

document.addEventListener("DOMContentLoaded", () => {
  new Toc();
  new SidebarFootnotes();
  enhanceCodeBlocks();
});
