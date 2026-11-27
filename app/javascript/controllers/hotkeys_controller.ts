import { Controller } from "@hotwired/stimulus";

import { ensure } from "helpers/ensure";

export default class extends Controller {
  static override targets = ["click"];

  clickTargets!: HTMLElement[];

  indexedClickTargets = new Map<string, HTMLElement>();

  clickTargetConnected(element: HTMLElement): void {
    const { hotkey } = element.dataset;
    this.indexedClickTargets.set(ensure(hotkey), element);
  }

  clickTargetDisconnected(element: HTMLElement): void {
    const { hotkey } = element.dataset;
    this.indexedClickTargets.delete(ensure(hotkey));
  }

  handleKeydown(event: KeyboardEvent): void {
    const clickable = this.indexedClickTargets.get(event.key);

    if (clickable) { clickable.click(); }
  }
}
