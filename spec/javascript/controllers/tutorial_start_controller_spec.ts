import { bootStimulus } from "support/stimulus";
import TutorialStartController from "controllers/tutorial_start_controller";
import { ensure } from "helpers/ensure";

async function setupController(): Promise<void> {
  vi.useFakeTimers();

  // Static test fixture — safe to use innerHTML
  document.body.innerHTML = [
    "<div data-controller='tutorial-start'",
    "     data-tutorial-start-delay-value='1000'",
    "     data-tutorial-start-ready-value='Ready!'>",
    "  <p id='cta' data-tutorial-start-target='cta'>Loading</p>",
    "  <a id='start' data-tutorial-start-target='start'",
    "     style='display: none'>Start</a>",
    "</div>",
  ].join("\n");

  await bootStimulus("tutorial-start", TutorialStartController);
}

function cta(): HTMLElement {
  return ensure(document.querySelector<HTMLElement>("#cta"));
}

function startButton(): HTMLElement {
  return ensure(document.querySelector<HTMLElement>("#start"));
}

describe("tutorial-start", () => {
  it("keeps the start button hidden before the delay", async () => {
    await setupController();

    vi.advanceTimersByTime(999);

    expect(startButton().style.display).toBe("none");
  });

  it("shows the ready text after the delay", async () => {
    await setupController();

    vi.advanceTimersByTime(1000);

    expect(cta().textContent).toBe("Ready!");
  });

  it("shows the start button after the delay", async () => {
    await setupController();

    vi.advanceTimersByTime(1000);

    expect(startButton().style.display).toBe("");
  });

  it("does nothing if disconnected before the delay", async () => {
    await setupController();

    const element = ensure(document.querySelector("[data-controller]"));
    element.removeAttribute("data-controller");
    await Promise.resolve();
    vi.advanceTimersByTime(1000);

    expect(startButton().style.display).toBe("none");
  });
});
