// @ts-nocheck

describe("Story", function () {
  it("should exist", function () {
    expect(Story).toBeDefined();
  });

  it("uses defaults", function () {
    var story = new Story();
    expect(story.get("open")).toBe(false);
    expect(story.get("selected")).toBe(false);
  });

  describe("open", function () {
    it("sets open and selected to true", function () {
      var story = new Story();
      story.open();
      expect(story.get("open")).toBe(true);
      expect(story.get("selected")).toBe(true);
    });

    it("calls closeOthers, unselectAll, setSelection on collection", function () {
      var story = new Story();
      var spy = (story.collection = {
        closeOthers: vi.fn(),
        setSelection: vi.fn(),
        unselectAll: vi.fn(),
      });
      story.open();
      expect(spy.closeOthers).toHaveBeenCalledWith(story);
      expect(spy.unselectAll).toHaveBeenCalledOnce();
      expect(spy.setSelection).toHaveBeenCalledWith(story);
    });
  });

  describe("close", function () {
    it("sets open to false", function () {
      var story = new Story();
      story.set("open", true);
      expect(story.get("open")).toBe(true);
      story.close();
      expect(story.get("open")).toBe(false);
    });
  });

  describe("select", function () {
    it("sets selected to true", function () {
      var story = new Story();
      story.select();
      expect(story.get("selected")).toBe(true);
    });

    it("calls unselectAll on collection", function () {
      var story = new Story();
      var spy = (story.collection = {
        unselectAll: vi.fn(),
      });
      story.select();
      expect(spy.unselectAll).toHaveBeenCalledOnce();
    });
  });

  describe("toggle", function () {
    it("calles open/close based on state", function () {
      var story = new Story();
      vi.spyOn(story, "open").mockImplementation(function () {});
      vi.spyOn(story, "close").mockImplementation(function () {});

      story.toggle();
      expect(story.open).toHaveBeenCalledOnce();
      expect(story.close).not.toHaveBeenCalled();

      story.set("open", true);
      story.toggle();
      expect(story.open).toHaveBeenCalledOnce();
      expect(story.close).toHaveBeenCalledOnce();
    });
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
