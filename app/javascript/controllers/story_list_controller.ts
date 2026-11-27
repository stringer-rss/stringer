import { Controller } from "@hotwired/stimulus";

/*
 * Owns the story cursor: the "cursor" class on one story target, moved with
 * the keyboard and wrapping at either end. Opening, toggling and opening in a
 * tab still belong to the Backbone StoryView, so those are requested with
 * "story:open", "story:toggle" and "story:open-in-tab" events on the story.
 */
export default class extends Controller {
  static override targets = ["story"];

  declare storyTargets: HTMLElement[];

  next(): void {
    this.moveCursor(1);
  }

  previous(): void {
    this.moveCursor(-1);
  }

  openNext(): void {
    this.next();
    this.requestOnCurrent("story:open");
  }

  openPrevious(): void {
    this.previous();
    this.requestOnCurrent("story:open");
  }

  toggleCurrent(): void {
    this.requestOnCurrent("story:toggle");
  }

  openCurrentInTab(): void {
    this.requestOnCurrent("story:open-in-tab");
  }

  storyOpened(event: Event): void {
    const story = this.storyTargets.find((target) => {
      return event.target instanceof Node && target.contains(event.target);
    });

    if (story) {
      this.setCursor(story);
    }
  }

  private cursorIndex(): number {
    return this.storyTargets.findIndex((target) => {
      return target.classList.contains("cursor");
    });
  }

  private moveCursor(step: number): void {
    const count = this.storyTargets.length;
    let current = this.cursorIndex();

    // With no cursor yet, moving up lands on the last story.
    if (current === -1 && step < 0) {
      current = count;
    }

    const story = this.storyTargets[(current + step + count) % count];
    if (story) {
      this.setCursor(story);
    }
  }

  private setCursor(story: HTMLElement): void {
    for (const target of this.storyTargets) {
      target.classList.toggle("cursor", target === story);
    }

    requestAnimationFrame(() => {
      story.scrollIntoView({ behavior: "instant", block: "start" });
    });
  }

  // With no cursor yet, act on the first story.
  private requestOnCurrent(eventName: string): void {
    const story = this.storyTargets[this.cursorIndex()] ?? this.storyTargets[0];

    story?.dispatchEvent(new CustomEvent(eventName));
  }
}
