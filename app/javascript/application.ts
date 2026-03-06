import "@hotwired/turbo-rails";
import "@rails/activestorage";
import "jquery";
// @ts-expect-error — Bootstrap 3 has no type declarations
import "bootstrap";

import "./controllers/index";

declare global {
  interface JQuery {
    modal: (action: string) => JQuery;
  }
}

Turbo.session.drive = false;

document.addEventListener("keydown", (event: KeyboardEvent) => {
  if (event.key === "?") {
    jQuery("#shortcuts").modal("toggle");
  }
});
