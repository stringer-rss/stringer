import type { MockInstance } from "vitest";
import { bootStimulus, getController } from "support/stimulus";
import StoryListController from "controllers/story_list_controller";
import { ensure } from "helpers/ensure";

function setupDOM(): void {
  // Static test fixture — safe to use innerHTML
  document.body.innerHTML = [
    "<div id='stories'",
    "     data-controller='story-list'",
    "     data-action='story:opened->story-list#storyOpened'>",
    "  <ul>",
    "    <li class='story' data-story-list-target='story'>",
    "      <span class='story-title'>First</span>",
    "    </li>",
    "    <li class='story' data-story-list-target='story'>",
    "      <span class='story-title'>Second</span>",
    "    </li>",
    "    <li class='story' data-story-list-target='story'>",
    "      <span class='story-title'>Third</span>",
    "    </li>",
    "  </ul>",
    "</div>",
  ].join("\n");
}

async function setupController(): Promise<void> {
  setupDOM();
  await bootStimulus("story-list", StoryListController);
}

function stories(): HTMLElement[] {
  return Array.from(document.querySelectorAll<HTMLElement>("li.story"));
}

function story(index: number): HTMLElement {
  return ensure(stories()[index]);
}

function controller(): StoryListController {
  const element = ensure(document.querySelector<HTMLElement>("#stories"));

  return getController(element, "story-list", StoryListController);
}

function cursorIndexes(): number[] {
  return stories()
    .map((element, index) => {
      if (element.classList.contains("cursor")) {
        return index;
      }
      return -1;
    })
    .filter((index) => {
      return index >= 0;
    });
}

function listenOn(element: HTMLElement, eventName: string): MockInstance {
  const listener = vi.fn<(event: Event) => void>();
  element.addEventListener(eventName, listener);
  return listener;
}

describe("next", () => {
  it("puts the cursor on the first story when there is none", async () => {
    await setupController();

    controller().next();

    expect(cursorIndexes()).toStrictEqual([0]);
  });

  it("moves the cursor down", async () => {
    await setupController();

    controller().next();
    controller().next();

    expect(cursorIndexes()).toStrictEqual([1]);
  });

  it("wraps to the first story from the last", async () => {
    await setupController();

    controller().next();
    controller().next();
    controller().next();
    controller().next();

    expect(cursorIndexes()).toStrictEqual([0]);
  });

  it("scrolls the cursor story into view", async () => {
    await setupController();
    vi.spyOn(globalThis, "requestAnimationFrame")
      .mockImplementation((callback) => {
        callback(0);
        return 0;
      });
    const scrollSpy = vi.spyOn(story(0), "scrollIntoView");

    controller().next();

    expect(scrollSpy).toHaveBeenCalledExactlyOnceWith(
      { behavior: "instant", block: "start" },
    );
  });
});

describe("previous", () => {
  it("puts the cursor on the last story when there is none", async () => {
    await setupController();

    controller().previous();

    expect(cursorIndexes()).toStrictEqual([2]);
  });

  it("moves the cursor up", async () => {
    await setupController();

    controller().previous();
    controller().previous();

    expect(cursorIndexes()).toStrictEqual([1]);
  });

  it("wraps to the last story from the first", async () => {
    await setupController();

    controller().next();
    controller().previous();

    expect(cursorIndexes()).toStrictEqual([2]);
  });
});

describe("openNext and openPrevious", () => {
  it("moves the cursor down and asks that story to open", async () => {
    await setupController();
    const listener = listenOn(story(0), "story:open");

    controller().openNext();

    expect(cursorIndexes()).toStrictEqual([0]);
    expect(listener).toHaveBeenCalledExactlyOnceWith(expect.any(CustomEvent));
  });

  it("moves the cursor up and asks that story to open", async () => {
    await setupController();
    const listener = listenOn(story(2), "story:open");

    controller().openPrevious();

    expect(cursorIndexes()).toStrictEqual([2]);
    expect(listener).toHaveBeenCalledExactlyOnceWith(expect.any(CustomEvent));
  });
});

describe("toggleCurrent and openCurrentInTab", () => {
  it("asks the cursor story to toggle", async () => {
    await setupController();
    controller().next();
    controller().next();
    const listener = listenOn(story(1), "story:toggle");

    controller().toggleCurrent();

    expect(listener).toHaveBeenCalledExactlyOnceWith(expect.any(CustomEvent));
  });

  it("asks the first story to toggle when there is no cursor", async () => {
    await setupController();
    const listener = listenOn(story(0), "story:toggle");

    controller().toggleCurrent();

    expect(listener).toHaveBeenCalledExactlyOnceWith(expect.any(CustomEvent));
  });

  it("asks the cursor story to open in a tab", async () => {
    await setupController();
    controller().previous();
    const listener = listenOn(story(2), "story:open-in-tab");

    controller().openCurrentInTab();

    expect(listener).toHaveBeenCalledExactlyOnceWith(expect.any(CustomEvent));
  });
});

describe("storyOpened", () => {
  it("moves the cursor to the story that opened", async () => {
    await setupController();
    controller().next();

    const title = ensure(story(2).querySelector(".story-title"));
    title.dispatchEvent(new CustomEvent("story:opened", { bubbles: true }));

    expect(cursorIndexes()).toStrictEqual([2]);
  });
});

describe("with no stories", () => {
  it("does nothing", async () => {
    document.body.innerHTML = "<div data-controller='story-list'></div>";
    await bootStimulus("story-list", StoryListController);
    const element = ensure(document.querySelector<HTMLElement>("div"));
    const list = getController(element, "story-list", StoryListController);

    list.next();
    list.toggleCurrent();

    expect(element.querySelectorAll(".cursor")).toHaveLength(0);
  });
});
