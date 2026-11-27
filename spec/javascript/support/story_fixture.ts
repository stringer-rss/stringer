import type { MockInstance } from "vitest";
import { bootStimulus, getController } from "support/stimulus";
import StoryController from "controllers/story_controller";
import { ensure } from "helpers/ensure";

// Shared fixture for the story controller specs.

interface Options { id?: string; isRead?: boolean; keepUnread?: boolean }

function setupDOM({ id = "42", isRead = false, keepUnread = false }: Options):
void {
  // Static test fixture — safe to use innerHTML
  document.body.innerHTML = [
    "<li class='story'",
    "    data-controller='story'",
    "    data-action='keep-unread-toggle:toggled->story#keepUnreadToggled",
    "                 submit->story#refreshSubmitted",
    "                 turbo:frame-missing->story#frameMissing'",
    `    data-story-id-value='${id}'`,
    `    data-story-is-read-value='${isRead}'`,
    `    data-story-keep-unread-value='${keepUnread}'>`,
    "  <div class='story-preview'",
    "       data-action='click->story#previewClicked'></div>",
    "  <a href='http://example.com/story' data-story-target='permalink'></a>",
    "  <form action='/stories/refresh'><button>Refresh</button></form>",
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
  setupController,
};
