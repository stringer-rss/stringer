import { Controller } from "@hotwired/stimulus";

import { updateStory } from "helpers/api";

interface KeepUnreadDetail { isRead: boolean; keepUnread: boolean }

// Cmd, ctrl and middle clicks open the story in a background tab.
function opensInTab(event: MouseEvent): boolean {
  return event.metaKey || event.ctrlKey || event.button === 1;
}

/*
 * Owns a story's open and read state: the "open" and "read" classes on its
 * element, saving read state to the server, and announcing changes as
 * bubbling "story:opened" and "story:read-changed" events.
 */
export default class extends Controller {
  static override values = { id: String, isRead: Boolean, keepUnread: Boolean };

  // The permalink sits inside the story's Turbo Frame, so a refresh updates it.
  static override targets = ["permalink"];

  declare idValue: string;

  declare permalinkTarget: HTMLAnchorElement;

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

  toggle(): void {
    if (this.isOpen) {
      this.close();
    } else {
      this.open();
    }
  }

  previewClicked(event: MouseEvent): void {
    // The preview's star button submits its own form.
    if (event.target instanceof Element && event.target.closest("form")) {
      return;
    }

    if (opensInTab(event)) {
      this.openInBackgroundTab();
      return;
    }

    const wasOpen = this.isOpen;
    this.toggle();
    // Closing by click keeps the story's top in view.
    if (wasOpen) {
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

    if (this.isSample()) {
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

  // Sample stories aren't saved, so their star and refresh forms do nothing.
  formSubmitted(event: Event): void {
    if (this.isSample()) {
      event.preventDefault();
    }
  }

  /*
   * A failed refresh can respond without the story's Turbo Frame, e.g. when
   * the story was deleted. Cancelling the event keeps the story as it was,
   * instead of Turbo's "Content missing".
   */
  frameMissing(event: Event): void {
    if (event.target instanceof Node && this.element.contains(event.target)) {
      event.preventDefault();
    }
  }

  // Sample stories on the tutorial page have fake, non-positive ids.
  private isSample(): boolean {
    return Number(this.idValue) <= 0;
  }

  private openInBackgroundTab(): void {
    window.open(this.permalinkTarget.href);
    window.focus();
    this.markAsRead();
  }

  private scrollIntoView(): void {
    this.element.scrollIntoView({ behavior: "instant", block: "start" });
  }
}
