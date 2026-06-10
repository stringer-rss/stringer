import {Controller} from "@hotwired/stimulus";

/*
 * Mirrors the number of unread stories into the document title, e.g.
 * "(3) Stringer". The DOM is the source of truth: any story target without
 * the "read" class counts as unread. Target callbacks re-count when stories
 * are added or removed; read-state flips are announced by whoever owns them
 * (currently the Backbone StoryView) as a bubbling "story:read-changed"
 * event, routed here via data-action on the container.
 */
export default class extends Controller {
  static override targets = ["story"];

  static override values = {title: String};

  declare titleValue: string;

  override connect(): void {
    this.update();
  }

  storyTargetConnected(): void {
    this.update();
  }

  storyTargetDisconnected(): void {
    this.update();
  }

  update(): void {
    const unread = this.element.querySelectorAll(".story:not(.read)").length;

    if (unread === 0) {
      document.title = this.titleValue;
    } else {
      document.title = `(${unread}) ${this.titleValue}`;
    }
  }
}
