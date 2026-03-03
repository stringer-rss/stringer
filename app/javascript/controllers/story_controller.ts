import {Controller} from "@hotwired/stimulus";

import {updateStory} from "helpers/api";

function closeStory(story: Element): void {
  story.classList.remove("open");
  const sel = "[data-story-target='lead']";
  const lead = story.querySelector<HTMLElement>(sel);
  if (lead) { lead.style.display = ""; }
}

interface ToggleDetail {
  isRead: boolean;
  keepUnread: boolean;
}

export default class extends Controller {
  static override values = {
    id: String,
    isRead: Boolean,
    keepUnread: Boolean,
    permalink: String,
  };

  static override targets = ["body", "lead"];

  declare idValue: string;

  declare isReadValue: boolean;

  declare keepUnreadValue: boolean;

  declare permalinkValue: string;

  bodyTarget!: HTMLElement;

  leadTarget!: HTMLElement;

  toggle(event: MouseEvent): void {
    if (event.metaKey || event.ctrlKey || event.button === 1) {
      this.openInBackgroundTab();
      return;
    }

    if (this.element.classList.contains("open")) {
      this.close();
    } else {
      this.open();
    }
  }

  open(): void {
    this.closeOthers();
    this.element.classList.add("open");
    this.leadTarget.style.display = "none";
    this.element.scrollIntoView({block: "start"});

    if (!this.keepUnreadValue) {
      this.markAsRead();
    }
  }

  close(): void {
    this.element.classList.remove("open");
    this.leadTarget.style.display = "";
  }

  keepUnreadToggleToggled(event: CustomEvent<ToggleDetail>): void {
    this.keepUnreadValue = event.detail.keepUnread;
    this.isReadValue = event.detail.isRead;
  }

  private openInBackgroundTab(): void {
    const tab = window.open(this.permalinkValue);
    // eslint-disable-next-line @typescript-eslint/no-deprecated
    if (tab) { tab.blur(); }
    window.focus();

    if (!this.keepUnreadValue) {
      this.markAsRead();
    }
  }

  private markAsRead(): void {
    if (this.isReadValue) { return; }
    this.isReadValue = true;
    this.element.classList.add("read");

    /* eslint-disable camelcase */
    updateStory(this.idValue, {is_read: true}).catch(() => {
      // Optimistic UI — ignore server errors
    });
    /* eslint-enable camelcase */

    this.dispatch("read", {bubbles: true});
  }

  private closeOthers(): void {
    const selector = "[data-controller~='story-list']";
    const list = this.element.closest(selector);
    if (!list) { return; }

    for (const story of list.querySelectorAll("li.story.open")) {
      if (story !== this.element) {
        closeStory(story);
      }
    }
  }
}
