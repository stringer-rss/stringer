import { bootStimulus, getController } from "support/stimulus";
import HotkeysController from "controllers/hotkeys_controller";
import { ensure } from "helpers/ensure";

async function setupController(html: string): Promise<void> {
  // Static test fixture — safe to use innerHTML
  document.body.innerHTML = html;

  await bootStimulus("hotkeys", HotkeysController);
}

async function setupSimple(): Promise<void> {
  await setupController(`
    <div data-controller="hotkeys">
      <button id="a" data-hotkeys-target="click" data-hotkey="a">A</button>
      <button id="bv" data-hotkeys-target="click" data-hotkey="b v">BV</button>
    </div>
  `);
}

function controller(): HotkeysController {
  const selector = "[data-controller='hotkeys']";
  const element = ensure(document.querySelector<HTMLElement>(selector));

  return getController(element, "hotkeys", HotkeysController);
}

function button(id: string): HTMLButtonElement {
  return ensure(document.querySelector<HTMLButtonElement>(`#${id}`));
}

function press(key: string, options: KeyboardEventInit = {}): void {
  controller().handleKeydown(new KeyboardEvent("keydown", { key, ...options }));
}

describe("handleKeydown", () => {
  it("clicks the target for the pressed key", async () => {
    await setupSimple();
    const clickSpy = vi.spyOn(button("a"), "click");

    press("a");

    expect(clickSpy).toHaveBeenCalledWith();
  });

  it("does nothing if there is no target for the pressed key", async () => {
    await setupSimple();
    const clickSpy = vi.spyOn(button("a"), "click");

    press("x");

    expect(clickSpy).not.toHaveBeenCalled();
  });

  it.each(["b", "v"])("clicks a multi-key target on %s", async (key) => {
    await setupSimple();
    const clickSpy = vi.spyOn(button("bv"), "click");

    press(key);

    expect(clickSpy).toHaveBeenCalledWith();
  });
});

describe("handleKeydown with modifiers", () => {
  it.each([
    ["ctrl", { ctrlKey: true }],
    ["meta", { metaKey: true }],
    ["alt", { altKey: true }],
  ])("ignores keys pressed with %s", async (_name, options) => {
    await setupSimple();
    const clickSpy = vi.spyOn(button("a"), "click");

    press("a", options);

    expect(clickSpy).not.toHaveBeenCalled();
  });

  it("still counts keys pressed with shift", async () => {
    await setupController(`
      <div data-controller="hotkeys">
        <button id="a" data-hotkeys-target="click" data-hotkey="A">A</button>
      </div>
    `);
    const clickSpy = vi.spyOn(button("a"), "click");

    press("A", { shiftKey: true });

    expect(clickSpy).toHaveBeenCalledWith();
  });
});

describe("with a scope", () => {
  async function setupScoped(): Promise<void> {
    await setupController(`
      <div data-controller="hotkeys" data-hotkeys-scope-value=".cursor">
        <div>
          <button id="first" data-hotkeys-target="click" data-hotkey="s">
          </button>
        </div>
        <div class="cursor">
          <button id="second" data-hotkeys-target="click" data-hotkey="s">
          </button>
        </div>
      </div>
    `);
  }

  it("clicks only the target inside the scope", async () => {
    await setupScoped();
    const firstSpy = vi.spyOn(button("first"), "click");
    const secondSpy = vi.spyOn(button("second"), "click");

    press("s");

    expect(firstSpy).not.toHaveBeenCalled();
    expect(secondSpy).toHaveBeenCalledWith();
  });

  it("does nothing when no target is inside the scope", async () => {
    await setupScoped();
    button("second").parentElement?.classList.remove("cursor");
    const firstSpy = vi.spyOn(button("first"), "click");

    press("s");

    expect(firstSpy).not.toHaveBeenCalled();
  });
});
