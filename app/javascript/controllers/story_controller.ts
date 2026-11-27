import { Controller } from "@hotwired/stimulus";

import { updateStory } from "helpers/api";

interface KeepUnreadDetail { isRead: boolean; keepUnread: boolean }

/*
 * Owns a story's read state: the "read" class on its element, saving it to
 * the server, and announcing changes as a bubbling "story:read-changed" event.
 */
export default class extends Controller {
  static override values = { id: String, isRead: Boolean, keepUnread: Boolean };

  declare idValue: string;

  declare isReadValue: boolean;

  declare keepUnreadValue: boolean;

  markAsRead(): void {
    if (this.isReadValue || this.keepUnreadValue) {
      return;
    }

    this.isReadValue = true;
    this.element.classList.add("read");
    this.dispatch("read-changed");

    // Sample stories on the tutorial page have fake, non-positive ids.
    if (Number(this.idValue) <= 0) {
      return;
    }

    updateStory(this.idValue, { is_read: true }).catch(() => {
      // Optimistic UI — ignore server errors
    });
  }

  keepUnreadToggled(event: CustomEvent<KeepUnreadDetail>): void {
    this.isReadValue = event.detail.isRead;
    this.keepUnreadValue = event.detail.keepUnread;
    this.dispatch("read-changed");
  }
}
