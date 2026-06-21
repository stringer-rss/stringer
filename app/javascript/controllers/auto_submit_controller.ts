import {Controller} from "@hotwired/stimulus";

export default class extends Controller<HTMLFormElement> {
  submit(): void {
    this.element.requestSubmit();
  }
}
