import type { MockInstance } from "vitest";
import { bootStimulus, getController } from "support/stimulus";
import StoryController from "controllers/story_controller";
import { ensure } from "helpers/ensure";

// Shared fixture for the story controller specs.

interface Options { id?: string; isRead?: boolean; keepUnread?: boolean }

interface ReadState { isRead: boolean; keepUnread: boolean }

// The keep unread form, as the server renders it with the saved state.
function readStateHTML({ isRead, keepUnread }: ReadState): string {
  return [
    "<form class='story-keep-unread-form' data-story-target='readState'",
    `      data-is-read='${isRead}' data-keep-unread='${keepUnread}'>`,
    "  <button>Keep unread</button>",
    "</form>",
  ].join("\n");
}

function setupDOM({ id = "42", isRead = false, keepUnread = false }: Options):
void {
  // Static test fixture — safe to use innerHTML
  document.body.innerHTML = [
    "<li class='story'",
    "    data-controller='story'",
    "    data-action='submit->story#formSubmitted",
    "                 turbo:frame-missing->story#frameMissing'",
    `    data-story-id-value='${id}'`,
    `    data-story-is-read-value='${isRead}'`,
    `    data-story-keep-unread-value='${keepUnread}'>`,
    "  <div class='story-preview'",
    "       data-action='click->story#previewClicked'>",
    "    <form id='star'><button>Star</button></form>",
    "  </div>",
    "  <a href='http://example.com/story' data-story-target='permalink'></a>",
    "  <form action='/stories/refresh'><button>Refresh</button></form>",
    readStateHTML({ isRead, keepUnread }),
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

function preview(): HTMLElement {
  return ensure(element().querySelector<HTMLElement>(".story-preview"));
}

function clickPreview(options: MouseEventInit = {}): void {
  preview().dispatchEvent(
    new MouseEvent("click", { bubbles: true, ...options }),
  );
}

// Swaps in a new keep unread form, as a Turbo Stream response would.
async function replaceReadState(state: ReadState): Promise<void> {
  const form = ensure(element().querySelector(".story-keep-unread-form"));
  form.outerHTML = readStateHTML(state);
  await Promise.resolve();
}

function isOpen(): boolean {
  return element().classList.contains("open");
}

export {
  clickPreview,
  controller,
  element,
  isOpen,
  listenForReadChanged,
  mockFetch,
  preview,
  replaceReadState,
  setupController,
};
