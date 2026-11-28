import { bootStimulus } from "support/stimulus";
import TutorialStoriesController from "controllers/tutorial_stories_controller";
import { ensure } from "helpers/ensure";

// An unstarred star form, as the server renders it.
function starForm(id: string): string {
  return [
    `<form id='${id}' class='story-star-form'>`,
    "  <input type='hidden' name='starred' value='true'>",
    "  <button><i class='fa fa-star-o'></i></button>",
    "</form>",
  ].join("\n");
}

async function setupController(): Promise<void> {
  // Static test fixture — safe to use innerHTML
  document.body.innerHTML = [
    "<div data-controller='tutorial-stories'",
    "     data-action='submit->tutorial-stories#submitted'",
    "     data-tutorial-stories-star-label-value='Star'",
    "     data-tutorial-stories-unstar-label-value='Unstar'>",
    "  <li class='story'>",
    starForm("star-preview"),
    starForm("star-actions"),
    "    <form class='story-keep-unread-form' data-is-read='true'",
    "          data-keep-unread='false'>",
    "      <input type='hidden' name='keep_unread' value='true'>",
    "      <button><i class='fa fa-square-o'></i> Keep unread</button>",
    "    </form>",
    "    <form class='story-refresh-form'><button>Refresh</button></form>",
    "  </li>",
    "</div>",
  ].join("\n");

  await bootStimulus("tutorial-stories", TutorialStoriesController);
}

function form(selector: string): HTMLFormElement {
  return ensure(document.querySelector<HTMLFormElement>(selector));
}

function submit(selector: string): SubmitEvent {
  const event = new SubmitEvent("submit", { bubbles: true, cancelable: true });
  form(selector).dispatchEvent(event);
  return event;
}

function icon(selector: string): string {
  return ensure(form(selector).querySelector("i")).className;
}

describe("submitted", () => {
  it("cancels the submit", async () => {
    await setupController();

    expect(submit(".story-refresh-form").defaultPrevented).toBe(true);
  });
});

describe("submitted for a star form", () => {
  it("stars both of the story's star buttons", async () => {
    await setupController();

    submit("#star-preview");

    expect([icon("#star-preview"), icon("#star-actions")])
      .toStrictEqual(["fa fa-star", "fa fa-star"]);
  });

  it("asks to unstar next time, with a matching label", async () => {
    await setupController();

    submit("#star-preview");

    const starred = form("#star-actions");
    expect([
      ensure(starred.querySelector("input")).value,
      ensure(starred.querySelector("button")).getAttribute("aria-label"),
    ]).toStrictEqual(["false", "Unstar"]);
  });

  it("unstars on a second submit", async () => {
    await setupController();

    submit("#star-preview");
    submit("#star-actions");

    expect(icon("#star-preview")).toBe("fa fa-star-o");
  });
});

describe("submitted for the keep unread form", () => {
  it("swaps in a copy with the kept unread state", async () => {
    await setupController();
    const original = form(".story-keep-unread-form");

    submit(".story-keep-unread-form");

    const copy = form(".story-keep-unread-form");
    expect([copy === original, copy.dataset.isRead, copy.dataset.keepUnread])
      .toStrictEqual([false, "false", "true"]);
  });

  it("shows a check and asks to stop keeping it unread next", async () => {
    await setupController();

    submit(".story-keep-unread-form");

    const copy = form(".story-keep-unread-form");
    const input = ensure(copy.querySelector("input"));
    expect([icon(".story-keep-unread-form"), input.value])
      .toStrictEqual(["fa fa-check", "false"]);
  });
});

describe("submitted for the refresh form", () => {
  it("marks the form busy for a moment", async () => {
    vi.useFakeTimers();
    await setupController();

    submit(".story-refresh-form");
    const busy = form(".story-refresh-form").getAttribute("aria-busy");
    vi.runAllTimers();

    expect([busy, form(".story-refresh-form").hasAttribute("aria-busy")])
      .toStrictEqual(["true", false]);
  });
});
