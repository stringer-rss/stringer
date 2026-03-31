import "javascript/application";
import {session} from "@hotwired/turbo";

it("disables Turbo", () => {
  expect(session.drive).toBe(false);
});
