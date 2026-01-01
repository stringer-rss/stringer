import {afterEach} from "vitest";
import type {Context, Controller} from "@hotwired/stimulus";
import {Application} from "@hotwired/stimulus";

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

afterEach(() => {
  if (application) { application.stop(); }

  application = null;
});

export {bootStimulus};
