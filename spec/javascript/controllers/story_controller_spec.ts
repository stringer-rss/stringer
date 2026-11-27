import {
  controller,
  element,
  listenForReadChanged,
  mockFetch,
  setupController,
} from "support/story_fixture";

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
