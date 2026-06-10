import {bootStimulus} from "support/stimulus";
import UnreadCountController from "controllers/unread_count_controller";
import {assert} from "helpers/assert";

function storyItem(read: boolean): string {
  if (read) {
    return "<li class='story read' data-unread-count-target='story'></li>";
  }

  return "<li class='story' data-unread-count-target='story'></li>";
}

async function setupController(stories: boolean[]): Promise<void> {
  // Static test fixture — safe to use innerHTML
  document.body.innerHTML = [
    "<div id='stories'",
    "     data-controller='unread-count'",
    "     data-action='story:read-changed->unread-count#update'",
    "     data-unread-count-title-value='Stringer'>",
    "  <ul id='story-list'>",
    ...stories.map(storyItem),
    "  </ul>",
    "</div>",
  ].join("\n");

  await bootStimulus("unread-count", UnreadCountController);
}

function storyList(): HTMLElement {
  return assert(document.querySelector<HTMLElement>("#story-list"));
}

async function targetsObserved(): Promise<void> {
  await new Promise((resolve) => { setTimeout(resolve, 0); });
}

function markRead(story: Element): void {
  story.classList.add("read");
  story.dispatchEvent(new CustomEvent("story:read-changed", {bubbles: true}));
}

describe("unread-count", () => {
  it("shows the unread count in the title on connect", async () => {
    await setupController([false, false, true]);

    expect(document.title).toBe("(2) Stringer");
  });

  it("shows the plain title when all stories are read", async () => {
    await setupController([true, true]);

    expect(document.title).toBe("Stringer");
  });

  it("clears the count when a story announces read-changed", async () => {
    await setupController([false, true]);

    markRead(assert(storyList().querySelector(".story:not(.read)")));

    expect(document.title).toBe("Stringer");
  });

  it("counts stories added after connect", async () => {
    await setupController([]);
    expect(document.title).toBe("Stringer");

    storyList().insertAdjacentHTML("beforeend", storyItem(false));
    await targetsObserved();

    expect(document.title).toBe("(1) Stringer");
  });
});
