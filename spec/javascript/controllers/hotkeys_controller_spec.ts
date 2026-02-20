import {bootStimulus, getController} from "support/stimulus";
import HotkeysController from "controllers/hotkeys_controller";
import {assert} from "javascript/helpers";

function setupDOM(): void {
  document.body.innerHTML = `
    <div data-controller="hotkeys">
      <button data-hotkeys-target="click" data-hotkey="a">A</button>
    </div>
  `;
}

async function setupController(): Promise<void> {
  setupDOM();

  await bootStimulus("hotkeys", HotkeysController);
}

function element(): HTMLElement {
  const selector = "[data-controller='hotkeys']";

  return assert(document.querySelector<HTMLElement>(selector));
}

function controller(): HotkeysController {
  return getController(element(), "hotkeys", HotkeysController);
}

function button(): HTMLButtonElement {
  const selector = "button[data-hotkeys-target='click']";

  return assert(document.querySelector<HTMLButtonElement>(selector));
}

describe("clickTargetConnected", () => {
  it("indexes the connected click target by its hotkey", async () => {
    await setupController();

    expect(controller().indexedClickTargets.get("a")).toBe(button());
  });
});

describe("clickTargetDisconnected", () => {
  it("removes the disconnected click target from the index", async () => {
    await setupController();

    button().remove();

    await Promise.resolve();

    expect(controller().indexedClickTargets.get("a")).toBeUndefined();
  });
});

describe("handleKeydown", () => {
  it("clicks the target for the pressed key", async () => {
    await setupController();
    const clickSpy = vi.spyOn(button(), "click");

    controller().handleKeydown(new KeyboardEvent("keydown", {key: "a"}));

    expect(clickSpy).toHaveBeenCalledWith();
  });

  it("does nothing if there is no target for the pressed key", async () => {
    await setupController();
    const clickSpy = vi.spyOn(button(), "click");

    controller().handleKeydown(new KeyboardEvent("keydown", {key: "b"}));

    expect(clickSpy).not.toHaveBeenCalled();
  });
});
