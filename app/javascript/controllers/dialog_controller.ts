import {Controller} from "@hotwired/stimulus";

export default class extends Controller {
  override connect(): void {
    this.element.textContent = "Hello World!";
  }
}
