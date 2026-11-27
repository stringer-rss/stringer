import { bootStimulus, getController } from "support/stimulus";
import StoryController from "controllers/story_controller";
import StoryListController from "controllers/story_list_controller";
import { ensure } from "helpers/ensure";

// Sample ids skip saving read state, so these specs make no requests.
function storyHTML(title: string): string {
  return [
    "<li class='story'",
    "    data-controller='story'",
    "    data-story-id-value='-1'",
    "    data-story-list-target='story'>",
    `  <span class='story-title'>${title}</span>`,
    "</li>",
  ].join("\n");
}

function setupDOM(): void {
  // Static test fixture — safe to use innerHTML
  document.body.innerHTML = [
    "<div id='stories'",
    "     data-controller='story-list'",
    "     data-story-list-story-outlet='li.story'",
    "     data-action='story:opened->story-list#storyOpened'>",
    "  <ul>",
    storyHTML("First"),
    storyHTML("Second"),
    storyHTML("Third"),
    "  </ul>",
    "</div>",
  ].join("\n");
}

async function setupController(): Promise<void> {
  setupDOM();
  await bootStimulus("story", StoryController);
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

function indexesWithClass(className: string): number[] {
  return stories()
    .map((element, index) => {
      if (element.classList.contains(className)) {
        return index;
      }
      return -1;
    })
    .filter((index) => {
      return index >= 0;
    });
}

function cursorIndexes(): number[] {
  return indexesWithClass("cursor");
}

function openIndexes(): number[] {
  return indexesWithClass("open");
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
  it("moves the cursor down and opens that story", async () => {
    await setupController();

    controller().openNext();

    expect(cursorIndexes()).toStrictEqual([0]);
    expect(openIndexes()).toStrictEqual([0]);
  });

  it("moves the cursor up and opens that story", async () => {
    await setupController();

    controller().openPrevious();

    expect(cursorIndexes()).toStrictEqual([2]);
    expect(openIndexes()).toStrictEqual([2]);
  });

  it("closes the story it moves away from", async () => {
    await setupController();

    controller().openNext();
    controller().openNext();

    expect(openIndexes()).toStrictEqual([1]);
  });
});

describe("toggleCurrent", () => {
  it("toggles the cursor story", async () => {
    await setupController();
    controller().next();
    controller().next();

    controller().toggleCurrent();
    expect(openIndexes()).toStrictEqual([1]);

    controller().toggleCurrent();
    expect(openIndexes()).toStrictEqual([]);
  });

  it("toggles the first story when there is no cursor", async () => {
    await setupController();

    controller().toggleCurrent();

    expect(openIndexes()).toStrictEqual([0]);
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

  it("closes the other open stories", async () => {
    await setupController();
    story(0).classList.add("open");
    story(1).classList.add("open");

    story(2).dispatchEvent(new CustomEvent("story:opened", { bubbles: true }));

    expect(openIndexes()).toStrictEqual([]);
  });

  it("ignores events from outside any story", async () => {
    await setupController();
    story(0).classList.add("open");
    const list = ensure(document.querySelector("ul"));

    list.dispatchEvent(new CustomEvent("story:opened", { bubbles: true }));

    expect(openIndexes()).toStrictEqual([0]);
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
