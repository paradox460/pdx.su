import { LitElement, html, css } from "lit";
import { customElement, queryAssignedElements, state } from "lit/decorators.js";
import { classMap } from "lit/directives/class-map.js";
import { styleMap } from "lit/directives/style-map.js";

/**
 * Enhances code blocks by wrapping them with a custom "pretty-code" LitElement.
 * This function iterates through all "pre.athl code" elements in the document,
 * creates a new "pretty-code" element, and inserts it before each code block.
 * It also sets the "pre.athl" element's "codeBlock" dataset attribute, so you
 * can style wrapped codeblocks and unwrapped ones differently
 */
export function enhanceCodeBlocks() {
  for (const codeBlock of document.querySelectorAll("pre.athl code")) {
    const litContainer = document.createElement("pretty-code");
    codeBlock.insertAdjacentElement("beforebegin", litContainer);
    litContainer.insertAdjacentElement("afterbegin", codeBlock);
    (codeBlock.closest("pre.athl") as HTMLPreElement).dataset.codeBlock = "";
  }
}

interface LineInfo {
  height: string;
  highlight: boolean;
}

@customElement("pretty-code")
export class PrettyCode extends LitElement {
  @state()
  protected lineHeights: LineInfo[] = [];

  @queryAssignedElements()
  codeElems!: Array<HTMLElement>;

  _onSlotChange(e) {
    // Annoyingly complex calculation of line heights, due to subpixel heights
    for (const line of e.target.assignedNodes()[0].querySelectorAll(".line")) {
      const boxHeight = line.getBoundingClientRect().height;
      const lineHeight = getComputedStyle(line).lineHeight;
      const lineHeightNum = parseFloat(lineHeight);
      let outHeight: string = lineHeight;
      if (boxHeight > lineHeightNum) {
        outHeight = `${Math.round(boxHeight / lineHeightNum) * lineHeightNum}px`;
      }
      this.lineHeights.push({
        height: outHeight,
        highlight: line.classList.contains("cursorline"),
      });
    }
    this.requestUpdate();
  }

  async copyCode(e) {
    try {
      await navigator.clipboard.writeText(this.codeElems[0].innerText);
    } catch (err) {
      console.error("Failed to copy: ", err);
    }
  }

  static styles = css`
    :host {
      display: flex;
      padding: var(--padding-y) var(--padding-x);
      padding-left: 0;
    }

    .line-numbers {
      margin: calc(-1 * var(--padding-y)) 1em;
      text-align: right;
      color: var(--base02);
      user-select: none;
      border-right: 1px solid var(--base01);
      padding-block: var(--padding-y);
      padding-inline: 0 0.5em;
    }

    .line-number {
      height: var(--height, 1em);
      background: var(--background);
      overflow: hidden;
    }

    .line-number.highlight {
      color: var(--base05);
    }

    .copy-button {
      display: none;
      position: absolute;
      inset: var(--padding-y) var(--padding-x) auto auto;
      cursor: pointer;
      padding: 5px;
      border: 1px solid var(--base01);
      border-radius: 5px;
      background-color: oklch(from var(--background) l c h / 0.5);
      box-shadow: 0px 3px 3px 2px hsl(0 0 0 / 0.2);
      backdrop-filter: blur(10px);
    }

    .copy-button-icon {
      width: 20px;
      height: 20px;
      background-color: var(--base03);
      mask: url("/content-copy.svg");
      transition: background-color 0.1s linear;
    }

    .copy-button:hover .copy-button-icon {
      background-color: var(--base05);
    }

    :host(:hover) .copy-button {
      display: block;
    }

    .copy-button:active .copy-button-icon {
      background-color: var(--base02);
    }
  `;

  render() {
    const lineNumbers = [];

    for (const [
      i,
      { height: lineHeight, highlight },
    ] of this.lineHeights.entries()) {
      lineNumbers.push(
        html`<div
          class="line-number ${classMap({ highlight })}"
          style="${styleMap({ "--height": lineHeight })}"
        >
          ${i + 1}
        </div>`,
      );
    }

    return html`
      <div class="line-numbers">${lineNumbers}</div>
      <slot @slotchange="${this._onSlotChange}"></slot>
      <div
        class="copy-button"
        @click="${this.copyCode}"
        role="button"
        aria-label="Copy"
        title="Copy"
      >
        <div class="copy-button-icon"></div>
      </div>
    `;
  }
}
