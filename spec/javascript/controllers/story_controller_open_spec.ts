import {
  clickPreview,
  controller,
  element,
  isOpen,
  mockFetch,
  preview,
  setupController,
} from "support/story_fixture";
import { ensure } from "helpers/ensure";

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


describe("close and toggle", () => {
  it("toggles the story open and closed", async () => {
    await setupController();
    mockFetch();

    controller().toggle();
    expect(isOpen()).toBe(true);

    controller().toggle();
    expect(isOpen()).toBe(false);
  });

  it("does not scroll when closing", async () => {
    await setupController();
    mockFetch();
    controller().open();
    const scrollSpy = vi.spyOn(element(), "scrollIntoView");

    controller().close();

    expect(scrollSpy).not.toHaveBeenCalled();
  });
});

describe("previewClicked", () => {
  it("opens and closes the story", async () => {
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
});

describe("previewClicked on the star button", () => {
  it("leaves the story closed", async () => {
    await setupController();
    mockFetch();
    const button = ensure(element().querySelector<HTMLElement>("#star button"));

    button.dispatchEvent(new MouseEvent("click", { bubbles: true }));

    expect(isOpen()).toBe(false);
  });
});

describe("previewClicked with a modifier", () => {
  it.each([
    ["meta", { metaKey: true }],
    ["ctrl", { ctrlKey: true }],
    ["middle", { button: 1 }],
  ])("opens a tab on %s clicks and marks read", async (_name, options) => {
    await setupController();
    mockFetch();
    const openSpy = vi.spyOn(window, "open").mockReturnValue(null);
    const focusSpy = vi.spyOn(window, "focus").mockReturnValue();

    clickPreview(options);

    expect(openSpy).toHaveBeenCalledExactlyOnceWith("http://example.com/story");
    expect(focusSpy).toHaveBeenCalledExactlyOnceWith();
    expect(isOpen()).toBe(false);
    expect(element().classList.contains("read")).toBe(true);
  });
});

describe("frameMissing", () => {
  it("cancels Turbo's missing frame handling", async () => {
    await setupController();
    const event = new CustomEvent("turbo:frame-missing", {
      bubbles: true,
      cancelable: true,
    });

    preview().dispatchEvent(event);

    expect(event.defaultPrevented).toBe(true);
  });
});

describe("frameMissing from outside the story", () => {
  it("leaves the event alone", async () => {
    await setupController();
    const event = new CustomEvent("turbo:frame-missing", { cancelable: true });

    controller().frameMissing(event);

    expect(event.defaultPrevented).toBe(false);
  });
});
