export default class SidebarFootnotes {

  private footnotesElem: HTMLElement = document.querySelector('.footnotes')

  private matcher: MediaQueryList;

  constructor() {
    this.matcher = window.matchMedia("screen and (min-width: 86rem)");
    this.matcher.addEventListener('change', e => this.handleResize(e));
    this.handleResize(this.matcher);

    this.hoverHighlight();
  }


  private sidebarFootnotes(enabled: boolean) {
    console.log("Sidebar footnotes");
    if (enabled) {
      this.footnotesElem.dataset.sidebar = "";
      for (let fn of (document.querySelectorAll(".footnotes li") as NodeListOf<HTMLElement>)) {
        const inlineNote = document.querySelector(`a[href='#${fn.id}']`)

        const top = window.scrollY + inlineNote.getBoundingClientRect().top;

        fn.style.setProperty("--top", `${top}px`);
      }

      return;
    }
    delete this.footnotesElem.dataset.sidebar;
  }

  private handleResize({ matches }) {
    this.sidebarFootnotes(matches);
  }


  private hoverHighlight() {
    for (let el of document.querySelectorAll(".footnote-ref a")) {
      const footnoteId = el.getAttribute("href");
      const footnote: HTMLElement = document.querySelector(footnoteId);
      el.addEventListener("mouseenter", () => {
        footnote.dataset.hover = "";
      })
      el.addEventListener("mouseleave", () => {
        delete footnote.dataset.hover;
      })
    }
  }

}
