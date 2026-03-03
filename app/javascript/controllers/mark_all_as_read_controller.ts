import {Controller} from "@hotwired/stimulus";

import {assert} from "helpers/assert";

export default class extends Controller {
  static override targets = ["form"];

  formTarget!: HTMLFormElement;

  submit(event: Event): void {
    event.preventDefault();

    assert(this.formTarget).requestSubmit();
  }
}
