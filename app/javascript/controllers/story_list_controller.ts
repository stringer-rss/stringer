import {Controller} from "@hotwired/stimulus";

declare global {
  interface Window {
    i18n?: {titleName?: string};
  }
}

function isVisible(element: HTMLElement): boolean {
  const rect = element.getBoundingClientRect();

  return rect.top >= 0 &&
    rect.bottom <= window.innerHeight;
}

function isInputTarget(event: KeyboardEvent): boolean {
  const {target} = event;
  if (!(target instanceof HTMLElement)) { return false; }

  const tagName = target.tagName.toLowerCase();

  return tagName === "input" ||
    tagName === "textarea" ||
    tagName === "select" ||
    target.isContentEditable;
}

export default class extends Controller {
  static override targets = ["story"];

  declare storyTargets: HTMLElement[];

  cursorPosition = -1;

  private baseTitleName = "";

  private get maxPosition(): number {
    return this.storyTargets.length - 1;
  }

  override connect(): void {
    this.baseTitleName = window.i18n?.titleName ?? "";
  }

  storyTargetConnected(): void {
    this.updateTitle();
  }

  storyTargetDisconnected(): void {
    this.updateTitle();
  }

  handleKeydown(event: KeyboardEvent): void {
    if (isInputTarget(event)) { return; }
    if (!this.handleKey(event.key.toLowerCase())) { return; }

    event.preventDefault();
  }

  storyRead(): void {
    this.updateTitle();
  }

  private handleKey(key: string): boolean {
    switch (key) {
      case "j":
        this.moveCursorDown();
        this.openCurrent();
        return true;
      case "k":
        this.moveCursorUp();
        this.openCurrent();
        return true;
      case "n":
        this.moveCursorDown();
        return true;
      case "p":
        this.moveCursorUp();
        return true;
      case "o":
      case "enter":
        this.toggleCurrent();
        return true;
      case "b":
      case "v":
        this.viewInTab();
        return true;
      case "m":
        this.clickCurrentAction(".story-keep-unread");
        return true;
      case "s":
        this.clickCurrentAction(".story-starred");
        return true;
      default:
        return false;
    }
  }

  private moveCursorDown(): void {
    if (this.storyTargets.length === 0) { return; }

    this.clearCursor();

    if (this.cursorPosition < this.maxPosition) {
      this.cursorPosition += 1;
    } else {
      this.cursorPosition = 0;
    }

    this.applyCursor();
  }

  private moveCursorUp(): void {
    if (this.storyTargets.length === 0) { return; }

    this.clearCursor();

    if (this.cursorPosition > 0) {
      this.cursorPosition -= 1;
    } else {
      this.cursorPosition = this.maxPosition;
    }

    this.applyCursor();
  }

  private openCurrent(): void {
    const story = this.currentStory();
    if (!story) { return; }

    const preview =
      story.querySelector<HTMLElement>(".story-preview");
    preview?.click();
  }

  private toggleCurrent(): void {
    if (this.cursorPosition < 0) {
      this.cursorPosition = 0;
    }

    const story = this.currentStory();
    if (!story) { return; }

    this.clearCursor();
    this.applyCursor();

    const preview =
      story.querySelector<HTMLElement>(".story-preview");
    preview?.click();
  }

  private viewInTab(): void {
    if (this.cursorPosition < 0) {
      this.cursorPosition = 0;
    }

    const story = this.currentStory();
    if (!story) { return; }

    const permalink =
      story.dataset.storyPermalinkValue ?? "";
    if (permalink !== "") {
      window.open(permalink, "_blank");
    }
  }

  private clickCurrentAction(selector: string): void {
    if (this.cursorPosition < 0) {
      this.cursorPosition = 0;
    }

    const story = this.currentStory();
    if (!story) { return; }

    story.querySelector<HTMLElement>(selector)?.click();
  }

  private currentStory(): HTMLElement | undefined {
    return this.storyTargets[this.cursorPosition];
  }

  private clearCursor(): void {
    for (const story of this.storyTargets) {
      story.classList.remove("cursor");
    }
  }

  private applyCursor(): void {
    const story = this.currentStory();
    if (!story) { return; }

    story.classList.add("cursor");

    if (!isVisible(story)) {
      story.scrollIntoView({block: "start"});
    }
  }

  private updateTitle(): void {
    const unread = this.storyTargets.filter((story) => {
      return !story.classList.contains("read");
    });
    const unreadCount = unread.length;

    if (unreadCount === 0) {
      document.title = this.baseTitleName;
    } else {
      document.title =
        `(${unreadCount}) ${this.baseTitleName}`;
    }
  }
}
