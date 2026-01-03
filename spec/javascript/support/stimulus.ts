import {afterEach} from "vitest";
import type {Context, Controller} from "@hotwired/stimulus";
import {Application} from "@hotwired/stimulus";

import {assert} from "javascript/helpers";

let application: Application | null = null;

type ControllerClass<T> = new (context: Context) => T;

async function bootStimulus<T extends Controller>(
  name: string,
  controller: ControllerClass<T>,
): Promise<void> {
  application ??= Application.start();

  application.register(name, controller);
  application.handleError = (error: Error): void => { throw error; };

  await Promise.resolve();
}

function getController<T extends Controller>(
  element: HTMLElement,
  name: string,
  controllerClass: ControllerClass<T>,
): T {
  const controller =
    assert(application).getControllerForElementAndIdentifier(element, name);

  if (controller instanceof controllerClass) {
    return controller;
  } else if (controller) {
    throw new Error("Controller class does not match");
  }

  throw new Error("Controller not found");
}

afterEach(() => {
  if (application) { application.stop(); }

  application = null;
});

export {bootStimulus, getController};
