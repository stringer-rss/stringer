import {bootStimulus, getController} from "support/stimulus";
import Controller from "controllers/mark_all_as_read_controller";
import {assert} from "helpers/assert";

const name = "mark-all-as-read";
const sel = `[data-controller='${name}']`;
const formSel = "form#mark-all-as-read";

// Static test fixture — safe to use innerHTML
function setupDOM(): void {
  document.body.innerHTML = `
    <div data-controller="${name}">
      <button data-action="click->${name}#submit">
        Mark all
      </button>
      <form id="mark-all-as-read"
            data-mark-all-as-read-target="form">
      </form>
    </div>
  `;
}

async function setupController(): Promise<void> {
  setupDOM();

  await bootStimulus(name, Controller);
}

function element(): HTMLElement {
  const el = document.querySelector<HTMLElement>(sel);

  return assert(el);
}

function controller(): Controller {
  return getController(element(), name, Controller);
}

function form(): HTMLFormElement {
  const el = document.querySelector<HTMLFormElement>(formSel);

  return assert(el);
}

describe("submit", () => {
  it("submits the form and prevents default", async () => {
    await setupController();
    const submitSpy = vi.spyOn(form(), "requestSubmit");
    const event = new Event("click", {cancelable: true});

    controller().submit(event);

    expect(event.defaultPrevented).toBe(true);
    expect(submitSpy).toHaveBeenCalledWith();
  });
});
