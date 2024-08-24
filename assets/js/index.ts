import Toc from "./toc";
import SidebarFootnotes from "./sidebar_footnotes";
import "./md-note";
import "./smart-time";

document.addEventListener("DOMContentLoaded", () => {
  new Toc();
});

window.addEventListener("load", () => {
  new SidebarFootnotes();
})
