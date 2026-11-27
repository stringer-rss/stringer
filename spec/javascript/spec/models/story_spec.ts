// @ts-nocheck

describe("Story", function () {
  it("should exist", function () {
    expect(Story).toBeDefined();
  });

  describe("openInTab", function () {
    it("opens a new window", function () {
      var story = new Story({ permalink: "http://localhost" });
      const openSpy = vi.spyOn(window, "open").mockImplementation(() => {});

      story.openInTab();
      expect(openSpy).toHaveBeenCalledWith("http://localhost", "_blank");
    });
  });
});
