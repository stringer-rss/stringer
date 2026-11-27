import type { MockInstance } from "vitest";
import { bootStimulus, getController } from "support/stimulus";
import StoryController from "controllers/story_controller";
import { ensure } from "helpers/ensure";

interface Options { id?: string; isRead?: boolean; keepUnread?: boolean }

function setupDOM({ id = "42", isRead = false, keepUnread = false }: Options):
void {
  // Static test fixture — safe to use innerHTML
  document.body.innerHTML = [
    "<li class='story'",
    "    data-controller='story'",
    "    data-action='keep-unread-toggle:toggled->story#keepUnreadToggled'",
    `    data-story-id-value='${id}'`,
    `    data-story-is-read-value='${isRead}'`,
    `    data-story-keep-unread-value='${keepUnread}'>`,
    "  <div class='story-preview' data-action='click->story#toggle'></div>",
    "</li>",
  ].join("\n");
}

async function setupController(options: Options = {}): Promise<void> {
  setupDOM(options);
  await bootStimulus("story", StoryController);
}

function element(): HTMLElement {
  return ensure(document.querySelector<HTMLElement>("li.story"));
}

function controller(): StoryController {
  return getController(element(), "story", StoryController);
}

function mockFetch(): MockInstance {
  return vi.spyOn(globalThis, "fetch")
    .mockResolvedValue(new Response(null, { status: 204 }));
}

function listenForReadChanged(): MockInstance {
  const listener = vi.fn<(event: Event) => void>();
  element().addEventListener("story:read-changed", listener);
  return listener;
}

describe("markAsRead", () => {
  it("adds the read class", async () => {
    await setupController();
    mockFetch();

    controller().markAsRead();

    expect(element().classList.contains("read")).toBe(true);
  });

  it("announces the change", async () => {
    await setupController();
    mockFetch();
    const listener = listenForReadChanged();

    controller().markAsRead();

    expect(listener).toHaveBeenCalledExactlyOnceWith(expect.any(CustomEvent));
  });

  it("saves is_read to the server", async () => {
    await setupController();
    const fetchSpy = mockFetch();

    controller().markAsRead();

    expect(fetchSpy).toHaveBeenCalledWith(
      "/stories/42",
      expect.objectContaining({
        body: JSON.stringify({ is_read: true }),
        method: "PUT",
      }),
    );
  });
});

describe("markAsRead when it should not save", () => {
  it("does nothing when the story is already read", async () => {
    await setupController({ isRead: true });
    const fetchSpy = mockFetch();
    const listener = listenForReadChanged();

    controller().markAsRead();

    expect(fetchSpy).not.toHaveBeenCalled();
    expect(listener).not.toHaveBeenCalled();
  });

  it("does nothing when the story is kept unread", async () => {
    await setupController({ keepUnread: true });
    const fetchSpy = mockFetch();

    controller().markAsRead();

    expect(fetchSpy).not.toHaveBeenCalled();
    expect(element().classList.contains("read")).toBe(false);
  });

  it("does not save sample stories with fake ids", async () => {
    await setupController({ id: "-5" });
    const fetchSpy = mockFetch();

    controller().markAsRead();

    expect(fetchSpy).not.toHaveBeenCalled();
    expect(element().classList.contains("read")).toBe(true);
  });

  it("ignores server errors", async () => {
    await setupController();
    vi.spyOn(globalThis, "fetch").mockRejectedValue(new Error("offline"));

    controller().markAsRead();
    await Promise.resolve();

    expect(element().classList.contains("read")).toBe(true);
  });
});

describe("keepUnreadToggled", () => {
  function toggle(detail: { isRead: boolean; keepUnread: boolean }): void {
    element().dispatchEvent(
      new CustomEvent("keep-unread-toggle:toggled", { bubbles: true, detail }),
    );
  }

  it("announces the change", async () => {
    await setupController({ isRead: true });
    const listener = listenForReadChanged();

    toggle({ isRead: false, keepUnread: true });

    expect(listener).toHaveBeenCalledExactlyOnceWith(expect.any(CustomEvent));
  });

  it("stops markAsRead while kept unread", async () => {
    await setupController({ isRead: true });
    const fetchSpy = mockFetch();

    toggle({ isRead: false, keepUnread: true });
    controller().markAsRead();

    expect(fetchSpy).not.toHaveBeenCalled();
  });

  it("lets markAsRead work again once no longer kept unread", async () => {
    await setupController({ keepUnread: true });
    mockFetch();

    toggle({ isRead: false, keepUnread: false });
    controller().markAsRead();

    expect(element().classList.contains("read")).toBe(true);
  });
});

function preview(): HTMLElement {
  return ensure(element().querySelector<HTMLElement>(".story-preview"));
}

function clickPreview(options: MouseEventInit = {}): void {
  preview().dispatchEvent(
    new MouseEvent("click", { bubbles: true, ...options }),
  );
}

function isOpen(): boolean {
  return element().classList.contains("open");
}

describe("open", () => {
  it("adds the open class and marks the story read", async () => {
    await setupController();
    mockFetch();

    controller().open();

    expect(isOpen()).toBe(true);
    expect(element().classList.contains("read")).toBe(true);
  });

  it("announces that it opened", async () => {
    await setupController();
    mockFetch();
    const listener = vi.fn<(event: Event) => void>();
    element().addEventListener("story:opened", listener);

    controller().open();

    expect(listener).toHaveBeenCalledExactlyOnceWith(expect.any(CustomEvent));
  });

  it("scrolls the story into view", async () => {
    await setupController();
    mockFetch();
    const scrollSpy = vi.spyOn(element(), "scrollIntoView");

    controller().open();

    expect(scrollSpy).toHaveBeenCalledExactlyOnceWith(
      { behavior: "instant", block: "start" },
    );
  });
});

describe("close", () => {
  it("removes the open class", async () => {
    await setupController();
    mockFetch();
    controller().open();

    controller().close();

    expect(isOpen()).toBe(false);
  });
});

describe("toggle", () => {
  it("opens and closes the story when the preview is clicked", async () => {
    await setupController();
    mockFetch();

    clickPreview();
    expect(isOpen()).toBe(true);

    clickPreview();
    expect(isOpen()).toBe(false);
  });

  it("scrolls the story into view when closed by a click", async () => {
    await setupController();
    mockFetch();
    controller().open();
    const scrollSpy = vi.spyOn(element(), "scrollIntoView");

    clickPreview();

    expect(scrollSpy).toHaveBeenCalledExactlyOnceWith(
      { behavior: "instant", block: "start" },
    );
  });

  it("does not scroll when closed without a click", async () => {
    await setupController();
    mockFetch();
    controller().open();
    const scrollSpy = vi.spyOn(element(), "scrollIntoView");

    controller().toggle();

    expect(scrollSpy).not.toHaveBeenCalled();
  });

  it.each([
    ["meta", { metaKey: true }],
    ["ctrl", { ctrlKey: true }],
    ["middle", { button: 1 }],
  ])("ignores %s clicks, which open a tab instead", async (_name, options) => {
    await setupController();
    mockFetch();

    clickPreview(options);

    expect(isOpen()).toBe(false);
  });
});
