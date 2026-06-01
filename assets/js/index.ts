import "./custom-elements/md-note";
import "./custom-elements/smart-time";
import { enhanceCodeBlocks } from "./custom-elements/pretty-code";
import SidebarFootnotes from "./enhancements/sidebar-footnotes";
import Toc from "./enhancements/toc";

document.addEventListener("DOMContentLoaded", () => {
  new Toc();
  new SidebarFootnotes();
  enhanceCodeBlocks();
});
