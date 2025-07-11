import { LitElement, html, css } from "lit";
import { customElement, queryAssignedElements, state } from "lit/decorators.js";

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

@customElement("pretty-code")
export class PrettyCode extends LitElement {
  @state()
  protected lineHeights: string[] = [];

  @queryAssignedElements()
  codeElems!: Array<HTMLElement>;

  _onSlotChange(e) {
    for (const line of e.target.assignedNodes()[0].querySelectorAll(".line")) {
      const lineHeight = line.getBoundingClientRect().height;
      this.lineHeights.push(`${lineHeight}px`);
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
      padding-right: 2em;
    }

    .line-numbers {
      margin: 0 1em;
      text-align: right;
      color: var(--base02);
      user-select: none;
    }

    .line-number {
      height: var(--height, 1em);
    }

    .copy-button {
      display: none;
      position: absolute;
      inset: 20px 20px auto auto;
      cursor: pointer;
      width: 20px;
      height: 20px;
      background-color: var(--base03);
      mask: url("/content-copy.svg");
      transition: background-color 0.1s linear;
    }

    .copy-button:hover {
      background-color: var(--base05);
    }

    :host(:hover) .copy-button {
      display: block;
    }

    .copy-button:active {
      background-color: var(--base02);
    }
  `;

  render() {
    const lineNumbers = [];

    for (const [i, lineHeight] of this.lineHeights.entries()) {
      lineNumbers.push(
        html`<div class="line-number" style="--height: ${lineHeight}px">
          ${i + 1}
        </div>`,
      );
    }

    return html`
      <div class="line-numbers">${lineNumbers}</div>
      <slot @slotchange="${this._onSlotChange}"></slot>
      <div
        @click="${this.copyCode}"
        class="copy-button"
        role="button"
        aria-label="Copy"
        title="Copy"
      ></div>
    `;
  }
}
