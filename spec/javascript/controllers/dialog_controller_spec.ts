import {bootStimulus} from "support/stimulus";
import DialogController from "controllers/dialog_controller";

it("updates the text content of its element", async () => {
  document.body.innerHTML = "<div data-controller='dialog'></div>";
  await bootStimulus("dialog", DialogController);

  expect(document.body.textContent).toBe("Hello World!");
});
