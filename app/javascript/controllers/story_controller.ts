import { Controller } from "@hotwired/stimulus";

import { updateStory } from "helpers/api";

interface KeepUnreadDetail { isRead: boolean; keepUnread: boolean }

// Cmd, ctrl and middle clicks open the story in a background tab instead.
function opensInTab(event: Event): boolean {
  if (!(event instanceof MouseEvent)) {
    return false;
  }

  return event.metaKey || event.ctrlKey || event.button === 1;
}

/*
 * Owns a story's open and read state: the "open" and "read" classes on its
 * element, saving read state to the server, and announcing changes as
 * bubbling "story:opened" and "story:read-changed" events.
 */
export default class extends Controller {
  static override values = { id: String, isRead: Boolean, keepUnread: Boolean };

  declare idValue: string;

  declare isReadValue: boolean;

  declare keepUnreadValue: boolean;

  get isOpen(): boolean {
    return this.element.classList.contains("open");
  }

  open(): void {
    this.element.classList.add("open");
    this.markAsRead();
    this.dispatch("opened");
    this.scrollIntoView();
  }

  close(): void {
    this.element.classList.remove("open");
  }

  /*
   * Called with a click event from the story preview, or with no event from
   * the story list's keyboard shortcuts.
   */
  toggle(event?: Event): void {
    if (event && opensInTab(event)) {
      return;
    }

    if (!this.isOpen) {
      this.open();
      return;
    }

    this.close();
    // Closing by click keeps the story's top in view.
    if (event) {
      this.scrollIntoView();
    }
  }

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

  private scrollIntoView(): void {
    this.element.scrollIntoView({ behavior: "instant", block: "start" });
  }
}
