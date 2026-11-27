import { Controller } from "@hotwired/stimulus";

/*
 * Clicks a target when its hotkey is pressed. A target's data-hotkey can list
 * several keys separated by spaces. With a scope value, only targets inside
 * an element matching that selector count, e.g. ".story.cursor".
 *
 * Keys pressed with ctrl, cmd or alt are left to the browser, so shortcuts
 * like cmd+f and ctrl+v keep working. Shift still counts, for keys like "A".
 */
export default class extends Controller {
  static override targets = ["click"];

  static override values = { scope: String };

  declare clickTargets: HTMLElement[];

  declare scopeValue: string;

  handleKeydown(event: KeyboardEvent): void {
    if (event.ctrlKey || event.metaKey || event.altKey) {
      return;
    }

    this.targetFor(event.key)?.click();
  }

  private targetFor(key: string): HTMLElement | undefined {
    return this.clickTargets.find((target) => {
      const keys = (target.dataset.hotkey ?? "").split(" ");

      return keys.includes(key) && this.inScope(target);
    });
  }

  private inScope(target: HTMLElement): boolean {
    return this.scopeValue === "" || target.closest(this.scopeValue) !== null;
  }
}
