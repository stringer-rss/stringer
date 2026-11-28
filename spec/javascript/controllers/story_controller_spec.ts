import {
  controller,
  element,
  listenForReadChanged,
  replaceReadState,
  setupController,
  submittedMarkRead,
} from "support/story_fixture";

describe("markAsRead", () => {
  it("asks the server to mark the story read", async () => {
    await setupController();

    controller().markAsRead();

    expect(submittedMarkRead()).toBe(true);
  });

  it("waits for the server before adding the read class", async () => {
    await setupController();
    const listener = listenForReadChanged();

    controller().markAsRead();

    expect([element().classList.contains("read"), listener.mock.calls])
      .toStrictEqual([false, []]);
  });

  it("does nothing when the story is already read", async () => {
    await setupController({ isRead: true });

    controller().markAsRead();

    expect(submittedMarkRead()).toBe(false);
  });

  it("does nothing when the story is kept unread", async () => {
    await setupController({ keepUnread: true });

    controller().markAsRead();

    expect(submittedMarkRead()).toBe(false);
  });
});

describe("readStateTargetConnected", () => {
  it("copies the saved state onto the story", async () => {
    await setupController({ isRead: true });

    await replaceReadState({ isRead: false, keepUnread: true });

    expect([...element().classList]).toStrictEqual(["story", "keepUnread"]);
  });

  it("announces the change", async () => {
    await setupController({ isRead: true });
    const listener = listenForReadChanged();

    await replaceReadState({ isRead: false, keepUnread: true });

    expect(listener).toHaveBeenCalledExactlyOnceWith(expect.any(CustomEvent));
  });

  it("does nothing when the state is unchanged", async () => {
    await setupController({ isRead: true });
    const listener = listenForReadChanged();

    await replaceReadState({ isRead: true, keepUnread: false });

    expect(listener).not.toHaveBeenCalled();
  });

  it("stops markAsRead while kept unread", async () => {
    await setupController({ isRead: true });

    await replaceReadState({ isRead: false, keepUnread: true });
    controller().markAsRead();

    expect(submittedMarkRead()).toBe(false);
  });

  it("lets markAsRead work again once no longer kept unread", async () => {
    await setupController({ keepUnread: true });

    await replaceReadState({ isRead: false, keepUnread: false });
    controller().markAsRead();

    expect(submittedMarkRead()).toBe(true);
  });
});
