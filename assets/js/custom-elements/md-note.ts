import { LitElement, html, css } from "lit";
import { customElement, property } from "lit/decorators.js";
import { styleMap } from "lit/directives/style-map.js";

@customElement("md-note")
export class MdNote extends LitElement {
  static styles = css`
    :host {
      margin: inherit -1px;
    }
    .note {
      background: var(--base02);
      border: 1px solid var(--base03);
      border-radius: 5px;
      display: grid;
      align-items: center;
      grid-template-columns: 35px auto;
      gap: 10px;
      padding: 0 10px;
    }
    .icon {
      justify-self: center;
      align-self: center;
      font-size: 25px;
    }
  `;
  @property()
  icon?: string = "💡";

  @property()
  color?: string;

  customColor() {
    if (!this.color) {
      return {};
    }

    const colors: Record<string, string> = {
      red: "base08",
      orange: "base09",
      yellow: "base0a",
      green: "base0b",
      cyan: "base0c",
      blue: "base0d",
      purple: "base0e",
      brown: "base0f",
    };

    let color = this.color.toLowerCase();
    color = color.match(/base0\p{Hex_Digit}/) ? color : colors[color];

    return {
      background: `color-mix(in srgb, var(--${color}) 25%, transparent)`,
      borderColor: `color-mix(in srgb, var(--${color}) 75%, transparent)`,
    };
  }

  render() {
    return html`
      <aside class="note" style=${styleMap(this.customColor())}>
        <div class="icon">${this.icon}</div>
        <div class="content"><slot></slot></div>
      </aside>
    `;
  }
}
