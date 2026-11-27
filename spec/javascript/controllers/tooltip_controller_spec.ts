import { Tooltip } from "bootstrap";

import { bootStimulus } from "support/stimulus";
import TooltipController from "controllers/tooltip_controller";
import { ensure } from "helpers/ensure";

async function setupController(): Promise<HTMLElement> {
  // Static test fixture — safe to use innerHTML
  document.body.innerHTML =
    "<i id='icon' data-controller='tooltip' title='Success!'></i>";

  await bootStimulus("tooltip", TooltipController);

  return ensure(document.querySelector<HTMLElement>("#icon"));
}

async function mutationsObserved(): Promise<void> {
  await new Promise((resolve) => {
    setTimeout(resolve, 0);
  });
}

describe("tooltip", () => {
  it("attaches a Bootstrap tooltip on connect", async () => {
    const icon = await setupController();

    expect(Tooltip.getInstance(icon)).toBeInstanceOf(Tooltip);
  });

  it("removes the tooltip on disconnect", async () => {
    const icon = await setupController();

    icon.remove();
    await mutationsObserved();

    expect(Tooltip.getInstance(icon)).toBeNull();
  });
});
