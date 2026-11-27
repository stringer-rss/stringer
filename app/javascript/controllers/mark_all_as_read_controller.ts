import {Controller} from "@hotwired/stimulus";

import {ensure} from "helpers/ensure";

export default class extends Controller {
  static override targets = ["form"];

  formTarget!: HTMLFormElement;

  submit(event: Event): void {
    event.preventDefault();

    ensure(this.formTarget).requestSubmit();
  }
}
