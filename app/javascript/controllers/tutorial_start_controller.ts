import { Controller } from "@hotwired/stimulus";

/*
 * On the tutorial page, waits for the first feeds to have a chance to fetch,
 * then swaps in the "ready" text and shows the start button.
 */
export default class extends Controller {
  static override targets = ["cta", "start"];

  static override values = { delay: Number, ready: String };

  declare ctaTarget: HTMLElement;

  declare startTarget: HTMLElement;

  declare delayValue: number;

  declare readyValue: string;

  declare timeout: ReturnType<typeof setTimeout>;

  override connect(): void {
    this.timeout = setTimeout(() => {
      this.reveal();
    }, this.delayValue);
  }

  override disconnect(): void {
    clearTimeout(this.timeout);
  }

  reveal(): void {
    this.ctaTarget.textContent = this.readyValue;
    this.startTarget.style.display = "";
  }
}
