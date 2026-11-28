import { Controller } from "@hotwired/stimulus";

// Cmd, ctrl and middle clicks open the story in a background tab.
function opensInTab(event: MouseEvent): boolean {
  return event.metaKey || event.ctrlKey || event.button === 1;
}

/*
 * Owns a story's open and read state: the "open" and "read" classes on its
 * element, and bubbling "story:opened" and "story:read-changed" events.
 * Saving goes through forms in the story's Turbo Frame; the controller never
 * talks to the server itself.
 */
export default class extends Controller {
  static override values = { isRead: Boolean, keepUnread: Boolean };

  /*
   * The permalink sits inside the story's Turbo Frame, so a refresh updates
   * it. The markRead form saves read state when the story opens. The
   * readState target is the keep unread form, which the server replaces with
   * the saved read and keep unread state.
   */
  static override targets = ["permalink", "markRead", "readState"];

  declare permalinkTarget: HTMLAnchorElement;

  declare markReadTarget: HTMLFormElement;

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

  /*
   * Asks the server to mark the story read. The response replaces the
   * readState target, which applies the "read" class once it's saved.
   */
  markAsRead(): void {
    if (this.isReadValue || this.keepUnreadValue) {
      return;
    }

    this.markReadTarget.requestSubmit();
  }

  // Copies the saved state from a newly rendered keep unread form.
  readStateTargetConnected(target: HTMLElement): void {
    const isRead = target.dataset.isRead === "true";
    const keepUnread = target.dataset.keepUnread === "true";
    if (isRead === this.isReadValue && keepUnread === this.keepUnreadValue) {
      return;
    }

    this.isReadValue = isRead;
    this.keepUnreadValue = keepUnread;
    this.element.classList.toggle("read", isRead);
    this.element.classList.toggle("keepUnread", keepUnread);
    this.dispatch("read-changed");
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

  private openInBackgroundTab(): void {
    window.open(this.permalinkTarget.href);
    window.focus();
    this.markAsRead();
  }

  private scrollIntoView(): void {
    this.element.scrollIntoView({ behavior: "instant", block: "start" });
  }
}
