import {Controller} from "@hotwired/stimulus";

import {updateStory} from "helpers/api";

export default class extends Controller {
  static override values = {id: String, starred: Boolean};

  static override targets = ["icon"];

  declare idValue: string;

  declare starredValue: boolean;

  iconTargets!: HTMLElement[];

  async toggle(): Promise<void> {
    const starred = !this.starredValue;

    // eslint-disable-next-line camelcase
    const response = await updateStory(this.idValue, {is_starred: starred});
    if (!response.ok) {
      throw new Error(`Failed to star story ${this.idValue}`);
    }

    this.starredValue = starred;

    let icon = "fa fa-star-o";
    if (starred) { icon = "fa fa-star"; }

    for (const target of this.iconTargets) {
      target.className = icon;
    }
  }
}
