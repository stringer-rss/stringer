import {Controller} from "@hotwired/stimulus";

import {assert} from "javascript/helpers";

export default class extends Controller {
  static targets = ["click"];

  clickTargets!: HTMLElement[];

  indexedClickTargets = new Map<string, HTMLElement>();

  clickTargetConnected(element: HTMLElement): void {
    const {hotkey} = element.dataset;
    this.indexedClickTargets.set(assert(hotkey), element);
  }

  clickTargetDisconnected(element: HTMLElement): void {
    const {hotkey} = element.dataset;
    this.indexedClickTargets.delete(assert(hotkey));
  }

  handleKeydown(event: KeyboardEvent): void {
    const clickable = this.indexedClickTargets.get(event.key);

    if (clickable) { clickable.click(); }
  }
}
