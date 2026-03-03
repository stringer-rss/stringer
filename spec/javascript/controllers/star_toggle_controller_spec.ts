import {bootStimulus, getController} from "support/stimulus";
import StarToggleController from "controllers/star_toggle_controller";
import {assert} from "helpers/assert";

function starClass(starred: boolean): string {
  if (starred) { return "fa-star"; }

  return "fa-star-o";
}

function setupDOM(starred = false): void {
  const cls = starClass(starred);

  // Static test fixture — safe to use innerHTML
  document.body.innerHTML = [
    "<li class='story'",
    "    data-controller='star-toggle'",
    "    data-star-toggle-id-value='42'",
    `    data-star-toggle-starred-value='${starred}'>`,
    "  <div class=\"story-starred\"",
    "       data-action=\"click->star-toggle#toggle:stop\">",
    `    <i class="fa ${cls}"`,
    "       data-star-toggle-target=\"icon\"></i>",
    "  </div>",
    "  <div class=\"story-starred\"",
    "       data-action=\"click->star-toggle#toggle:stop\">",
    `    <i class="fa ${cls}"`,
    "       data-star-toggle-target=\"icon\"></i>",
    "  </div>",
    "</li>",
  ].join("\n");
}

async function setupController(starred = false): Promise<void> {
  setupDOM(starred);
  await bootStimulus("star-toggle", StarToggleController);
}

const sel = "[data-controller='star-toggle']";
const iconSel = "[data-star-toggle-target='icon']";

function element(): HTMLElement {
  return assert(document.querySelector<HTMLElement>(sel));
}

function controller(): StarToggleController {
  return getController(element(), "star-toggle", StarToggleController);
}

function iconTargets(): HTMLElement[] {
  return Array.from(document.querySelectorAll<HTMLElement>(iconSel));
}

describe("toggle", () => {
  // eslint-disable-next-line vitest/no-hooks
  afterEach(() => {
    vi.restoreAllMocks();
  });

  it("flips icons from unstarred to starred", async () => {
    await setupController(false);
    vi.spyOn(globalThis, "fetch").mockResolvedValue(new Response());

    controller().toggle();

    for (const icon of iconTargets()) {
      expect(icon.className).toBe("fa fa-star");
    }
  });

  it("flips icons from starred to unstarred", async () => {
    await setupController(true);
    vi.spyOn(globalThis, "fetch").mockResolvedValue(new Response());

    controller().toggle();

    for (const icon of iconTargets()) {
      expect(icon.className).toBe("fa fa-star-o");
    }
  });

  it("calls fetch with the correct payload", async () => {
    await setupController(false);
    const fetchSpy = vi.spyOn(globalThis, "fetch").
      mockResolvedValue(new Response());

    controller().toggle();

    expect(fetchSpy).toHaveBeenCalledWith(
      "/stories/42",
      expect.objectContaining({
        // eslint-disable-next-line camelcase
        body: JSON.stringify({is_starred: true}),
        method: "PUT",
      }),
    );
  });
});
