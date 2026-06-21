import {bootStimulus, getController} from "support/stimulus";
import Controller from "controllers/auto_submit_controller";
import {assert} from "helpers/assert";

function setupDOM(): void {
  document.body.innerHTML = `
    <form data-controller="auto-submit">
      <input type="file" data-action="change->auto-submit#submit" />
    </form>
  `;
}

async function setupController(): Promise<void> {
  setupDOM();

  await bootStimulus("auto-submit", Controller);
}

function element(): HTMLFormElement {
  const selector = "[data-controller='auto-submit']";

  return assert(document.querySelector<HTMLFormElement>(selector));
}

function controller(): Controller {
  return getController(element(), "auto-submit", Controller);
}

describe("submit", () => {
  it("submits the form", async () => {
    await setupController();
    const submitSpy = vi.spyOn(element(), "requestSubmit");

    controller().submit();

    expect(submitSpy).toHaveBeenCalledWith();
  });
});
