import {Controller} from "@hotwired/stimulus";

import {updateStory} from "helpers/api";

export default class extends Controller {
  static override values = {id: String, starred: Boolean};

  static override targets = ["icon"];

  declare idValue: string;

  declare starredValue: boolean;

  iconTargets!: HTMLElement[];

  toggle(): void {
    this.starredValue = !this.starredValue;

    let icon = "fa fa-star-o";
    if (this.starredValue) { icon = "fa fa-star"; }

    for (const target of this.iconTargets) {
      target.className = icon;
    }

    // eslint-disable-next-line camelcase
    updateStory(this.idValue, {is_starred: this.starredValue}).catch(() => {
      // Optimistic UI — ignore server errors
    });
  }
}
