/**
 * The id a TOC link targets for a heading: Markdown headings carry it themselves,
 * Djot headings take it from their wrapping `<section>`.
 */
function headingId(heading: Element | undefined): string | undefined {
  return heading?.id || heading?.closest("section[id]")?.id;
}

export default class Toc {
  static headersSelector = "#content :is(h2, h3, h4):is([id], section[id] > *)";

  private observer: IntersectionObserver;
  private activeToc = new Set<string>();

  constructor() {
    this.observer = new IntersectionObserver(
      (entries) => {
        entries.forEach((entry) => {
          const id = headingId(entry.target);
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
              const closest_id = headingId(this.findClosestOffscreenHeader());
              if (closest_id) {
                this.activeToc.add(closest_id);
              }
            }
          }

          this.updateTocLinks();
        });
      },
      { threshold: 1, rootMargin: "10px" },
    );

    document.querySelectorAll(Toc.headersSelector).forEach((header) => {
      this.observer.observe(header);
    });
  }

  private isVisible(id: string) {
    return (
      (document.getElementById(id)?.getBoundingClientRect()?.top ?? 0) >= 0
    );
  }

  private findClosestOffscreenHeader() {
    const headers = [...document.querySelectorAll(Toc.headersSelector)];

    const { closestHeader } = headers.reduce<{
      top: number;
      closestHeader?: Element;
    }>(
      (acc, header) => {
        const { top } = acc;

        const currentTop = header.getBoundingClientRect().top;
        if (currentTop >= 0) {
          return acc;
        }

        if (currentTop >= top) {
          return {
            top: currentTop,
            closestHeader: header,
          };
        }
        return acc;
      },
      { top: -Infinity, closestHeader: undefined },
    );

    return closestHeader;
  }

  private updateTocLinks() {
    for (const link of document.querySelectorAll(
      "#toc a",
    ) as NodeListOf<HTMLAnchorElement>) {
      const id = link.hash.replace("#", "");

      if (this.activeToc.has(id)) {
        link.dataset.active = "true";
      } else {
        delete link.dataset.active;
      }
    }
  }
}
