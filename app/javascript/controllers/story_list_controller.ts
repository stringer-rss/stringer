import { Controller } from "@hotwired/stimulus";

import type StoryController from "controllers/story_controller";

/*
 * Owns the story cursor and the accordion: one story target has the "cursor"
 * class, moved with the keyboard and wrapping at either end, and opening a
 * story closes the others. Opening in a tab still belongs to the Backbone
 * StoryView, so it is requested with a "story:open-in-tab" event.
 */
export default class extends Controller {
  static override targets = ["story"];

  static override outlets = ["story"];

  declare storyTargets: HTMLElement[];

  declare storyOutlets: StoryController[];

  next(): void {
    this.moveCursor(1);
  }

  previous(): void {
    this.moveCursor(-1);
  }

  openNext(): void {
    this.next();
    this.currentStory()?.open();
  }

  openPrevious(): void {
    this.previous();
    this.currentStory()?.open();
  }

  toggleCurrent(): void {
    this.currentStory()?.toggle();
  }

  openCurrentInTab(): void {
    this.currentStory()?.element.dispatchEvent(
      new CustomEvent("story:open-in-tab"),
    );
  }

  storyOpened(event: Event): void {
    const story = this.storyTargets.find((target) => {
      return event.target instanceof Node && target.contains(event.target);
    });

    if (!story) {
      return;
    }

    this.setCursor(story);
    for (const outlet of this.storyOutlets) {
      if (outlet.element !== story) {
        outlet.close();
      }
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
  private currentStory(): StoryController | undefined {
    const story = this.storyTargets[this.cursorIndex()] ?? this.storyTargets[0];

    return this.storyOutlets.find((outlet) => {
      return outlet.element === story;
    });
  }
}
