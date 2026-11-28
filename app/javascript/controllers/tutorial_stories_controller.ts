import { Controller } from "@hotwired/stimulus";

// How long a pretend refresh spins its icon.
const REFRESH_MS = 600;

function keepUnreadIcon(kept: boolean): string {
  if (kept) {
    return "fa-check";
  }

  return "fa-square-o";
}

function hiddenValue(form: HTMLFormElement, name: string): HTMLInputElement {
  const input = form.querySelector<HTMLInputElement>(`input[name='${name}']`);
  if (!input) {
    throw new Error(`Missing ${name} input`);
  }

  return input;
}

function setIcon(form: HTMLFormElement, icon: string): void {
  const element = form.querySelector("i");
  if (element) {
    element.className = `fa ${icon}`;
  }
}

/*
 * Swaps in an updated copy of the keep unread form, like the keep unread
 * stream does. The story controller copies the new state onto the story
 * when the copy connects.
 */
function keepUnread(form: HTMLFormElement): void {
  const kept = hiddenValue(form, "keep_unread").value === "true";
  const copy = form.cloneNode(true);
  if (!(copy instanceof HTMLFormElement)) {
    return;
  }

  copy.dataset.keepUnread = String(kept);
  copy.dataset.isRead = String(!kept);
  hiddenValue(copy, "keep_unread").value = String(!kept);
  setIcon(copy, keepUnreadIcon(kept));
  form.replaceWith(copy);
}

// Spins the refresh icon for a moment, as a real refresh does.
function refresh(form: HTMLFormElement): void {
  form.setAttribute("aria-busy", "true");
  setTimeout(() => {
    form.removeAttribute("aria-busy");
  }, REFRESH_MS);
}

/*
 * Imitates the story forms on the tutorial page, whose sample stories have
 * nothing to save. It cancels each submit and makes the change the server's
 * Turbo Stream response would have made, so the tutorial behaves like the
 * real stories page.
 */
export default class extends Controller {
  static override values = { starLabel: String, unstarLabel: String };

  declare starLabelValue: string;

  declare unstarLabelValue: string;

  submitted(event: Event): void {
    const form = event.target;
    if (!(form instanceof HTMLFormElement)) {
      return;
    }

    event.preventDefault();

    if (form.classList.contains("story-star-form")) {
      this.star(form);
    } else if (form.classList.contains("story-keep-unread-form")) {
      keepUnread(form);
    } else if (form.classList.contains("story-refresh-form")) {
      refresh(form);
    }
  }

  // Updates both of the story's star buttons, like the star stream does.
  private star(form: HTMLFormElement): void {
    const starred = hiddenValue(form, "starred").value === "true";
    const story = form.closest("li.story") ?? form;
    const forms = story.querySelectorAll<HTMLFormElement>(".story-star-form");

    for (const starForm of forms) {
      hiddenValue(starForm, "starred").value = String(!starred);
      this.showStar(starForm, starred);
    }
  }

  private showStar(form: HTMLFormElement, starred: boolean): void {
    const button = form.querySelector("button");
    if (starred) {
      setIcon(form, "fa-star");
      button?.setAttribute("aria-label", this.unstarLabelValue);
    } else {
      setIcon(form, "fa-star-o");
      button?.setAttribute("aria-label", this.starLabelValue);
    }
  }
}
