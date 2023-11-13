import { LitElement, html, css } from 'lit';
import { customElement, property } from 'lit/decorators.js';
import type { ComplexAttributeConverter } from 'lit';

const timestampConverter = (): ComplexAttributeConverter<Date> => {
  return {
    toAttribute: (date: Date) => {
      return date.toISOString();
    },
    fromAttribute: (value: string) => {
      return new Date(value);
    }
  }
}

@customElement('smart-time')
export class SmartTime extends LitElement {
  @property({
    converter: timestampConverter(),
    reflect: true,
  })
  t = new Date();

  @property({ type: Boolean, attribute: 'show-timestamp' })
  timestamp?= false;

  @property({ type: Boolean, attribute: 'hover' })
  hoverTimestamp?= false;


  niceTimestamp() {
    return (new Intl.DateTimeFormat(navigator.language, { dateStyle: "short", timeStyle: this.timestamp ? "short" : undefined })).format(this.t)
  }

  fullTimestamp() {
    return (new Intl.DateTimeFormat(navigator.language, { dateStyle: "full", timeStyle: (this.hoverTimestamp || this.timestamp) ? "full" : undefined })).format(this.t)
  }

  render() {
    return html`
    <time datetime = "${this.timestamp}" title = "${this.fullTimestamp()}" > ${this.niceTimestamp()} </time>
      `
  }
}
