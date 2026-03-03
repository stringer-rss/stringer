import {Controller} from "@hotwired/stimulus";

import {updateStory} from "helpers/api";

export default class extends Controller {
  static override values = {id: String, isRead: Boolean, keepUnread: Boolean};

  static override targets = ["icon"];

  declare idValue: string;

  declare isReadValue: boolean;

  declare keepUnreadValue: boolean;

  iconTargets!: HTMLElement[];

  toggle(): void {
    this.keepUnreadValue = !this.keepUnreadValue;
    this.isReadValue = !this.keepUnreadValue;

    let icon = "fa fa-square-o";
    if (this.keepUnreadValue) { icon = "fa fa-check"; }

    for (const target of this.iconTargets) {
      target.className = icon;
    }

    this.updateStoryElement();
    this.dispatch("toggled", {
      bubbles: true,
      detail: {isRead: this.isReadValue, keepUnread: this.keepUnreadValue},
    });
    this.persistState();
  }

  private updateStoryElement(): void {
    const storyEl = this.element.closest("li.story");
    storyEl?.classList.toggle("keepUnread", this.keepUnreadValue);
    storyEl?.classList.toggle("read", this.isReadValue);
  }

  private persistState(): void {
    /* eslint-disable camelcase */
    const attrs = {
      is_read: this.isReadValue,
      keep_unread: this.keepUnreadValue,
    };
    /* eslint-enable camelcase */
    updateStory(this.idValue, attrs).catch(() => {
      // Optimistic UI — ignore server errors
    });
  }
}
