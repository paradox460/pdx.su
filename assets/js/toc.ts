export default class Toc {

  static headersSelector = '#content :is(h2, h3, h4):has(a[id])';

  private observer: IntersectionObserver;
  private activeToc = new Set<string>();

  constructor() {
    this.observer = new IntersectionObserver(entries => {
      entries.forEach(entry => {
        const id = entry.target.querySelector('a[id]')?.getAttribute('id');
        if (!id) return;
        const { isIntersecting, intersectionRatio } = entry;
        if (isIntersecting && intersectionRatio >= 1) {
          this.activeToc.add(id);
        } else {
          this.activeToc.delete(id);

          for (const oldId of this.activeToc) {
            if (!this.isVisible(oldId)) {
              this.activeToc.delete(oldId);
            }
          }

          if (this.activeToc.size === 0) {
            const closest = this.findClosestOffscreenHeader()?.querySelector('a[id]')?.id;
            if (closest) { this.activeToc.add(closest); }
          }
        }

        this.updateTocLinks();
      })
    }, { threshold: 1, rootMargin: '10px' });

    document.querySelectorAll(Toc.headersSelector).forEach(header => {
      this.observer.observe(header);
    });
  }

  private isVisible(id: string) {
    return (document.getElementById(id)?.getBoundingClientRect()?.top ?? 0) >= 0;
  }

  private findClosestOffscreenHeader() {
    const headers = [...document.querySelectorAll(Toc.headersSelector)];

    const { closestHeader } = headers.reduce<{ top: number, closestHeader?: Element }>((acc, header) => {
      const { top, } = acc;

      const currentTop = header.getBoundingClientRect().top;
      if (currentTop >= 0) {
        return acc;
      }

      if (currentTop >= top) {
        return {
          top: currentTop,
          closestHeader: header
        }
      }
      return acc;
    }, { top: -Infinity, closestHeader: undefined })

    return closestHeader;
  }

  private updateTocLinks() {
    for (const link of document.querySelectorAll("#toc a") as NodeListOf<HTMLAnchorElement>) {
      const id = link.hash.replace("#", "");


      if (this.activeToc.has(id)) {
        link.dataset.active = "true";
      } else {
        delete link.dataset.active;
      }
    }
  }
}
