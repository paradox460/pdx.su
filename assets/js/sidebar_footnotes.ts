import { debounce } from 'lodash';

export default class SidebarFootnotes {

  private footnotesElem: HTMLElement = document.querySelector('.footnotes')

  private matcher: MediaQueryList;

  constructor() {
    if (this.footnotesElem) {
      this.footnotesElem.dataset.sidebar = "";
      this.matcher = window.matchMedia("screen and (min-width: 86rem)");
      this.matcher.addEventListener('change', e => this.handleResize(e));
      this.handleResize(this.matcher);

      this.hoverHighlight();
    }
  }


  private sidebarFootnotes(enabled: boolean) {
    if (enabled) {
      this.footnotesElem.dataset.sidebar = "";
      let previousBottom = 0;
      for (let fn of (document.querySelectorAll(".footnotes li") as NodeListOf<HTMLElement>)) {
        const inlineNote = document.querySelector(`a[href='#${fn.id}']`)

        let top = window.scrollY + inlineNote.getBoundingClientRect().top;

        let { height } = fn.getBoundingClientRect();
        if (previousBottom > top) {
          top = previousBottom + 10;
        }

        fn.style.setProperty("--top", `${top}px`);

        previousBottom = top + height;
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
      const debouncedEnter = debounce(() => {
        footnote.dataset.hover = "";
      }, 100, { leading: true });
      const debouncedLeave = debounce(() => {
        delete footnote.dataset.hover;
      }, 100);
      el.addEventListener("mouseenter", () => {
        debouncedLeave.cancel();
        debouncedEnter();
      })
      el.addEventListener("mouseleave", () => {
        debouncedEnter.cancel();
        debouncedLeave();
      })
    }
  }

}
