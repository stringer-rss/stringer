import type {MockInstance} from "vitest";
import {bootStimulus, getController} from "support/stimulus";
import StoryRefreshController from "controllers/story_refresh_controller";
import {assert} from "helpers/assert";

function setupDOM(): void {
  // Static test fixture — safe to use innerHTML
  document.body.innerHTML = [
    "<li class='story'",
    "    data-controller='story-refresh'",
    "    data-story-refresh-id-value='42'>",
    "  <div class=\"story-refresh\"",
    "       data-action=\"click->story-refresh#refresh:stop\">",
    "    <i class=\"fa fa-refresh\"></i>",
    "  </div>",
    "</li>",
  ].join("\n");
}

async function setupController(): Promise<void> {
  setupDOM();
  await bootStimulus("story-refresh", StoryRefreshController);
}

const sel = "[data-controller='story-refresh']";

function element(): HTMLElement {
  return assert(document.querySelector<HTMLElement>(sel));
}

function controller(): StoryRefreshController {
  return getController(element(), "story-refresh", StoryRefreshController);
}

function mockFetch(status = 200, body = "{}"): MockInstance {
  return vi.spyOn(globalThis, "fetch").
    mockResolvedValue(new Response(body, {status}));
}

function captureRefreshDetails(): unknown[] {
  const details: unknown[] = [];
  function listener(event: Event): void {
    if (event instanceof CustomEvent) {
      const detail: unknown = event.detail;
      details.push(detail);
    }
  }
  element().addEventListener("story-refresh:refreshed", listener);
  return details;
}

describe("refresh", () => {
  afterEach(() => {
    vi.restoreAllMocks();
  });

  it("posts to the refresh endpoint", async () => {
    await setupController();
    const fetchSpy = mockFetch();

    await controller().refresh();

    expect(fetchSpy).toHaveBeenCalledWith(
      "/stories/42/refresh",
      expect.objectContaining({method: "POST"}),
    );
  });

  it("dispatches a refreshed event with the story", async () => {
    await setupController();
    const story = {enclosure_url: "https://example.com/new.mp3", id: 42};
    mockFetch(200, JSON.stringify(story));
    const details = captureRefreshDetails();

    await controller().refresh();

    expect(details).toStrictEqual([{story}]);
  });

  it("throws when the request fails", async () => {
    await setupController();
    mockFetch(500);
    const details = captureRefreshDetails();

    await expect(controller().refresh()).
      rejects.toThrow("Failed to refresh story 42");

    expect(details).toStrictEqual([]);
  });
});
