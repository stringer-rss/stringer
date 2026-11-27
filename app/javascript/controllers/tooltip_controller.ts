import { Controller } from "@hotwired/stimulus";
import { Tooltip } from "bootstrap";

/*
 * Attaches a Bootstrap tooltip to the element, using its `title` attribute
 * as the text.
 */
export default class extends Controller<HTMLElement> {
  declare tooltip: Tooltip;

  override connect(): void {
    this.tooltip = new Tooltip(this.element);
  }

  override disconnect(): void {
    this.tooltip.dispose();
  }
}
