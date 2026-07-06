import {Controller} from "@hotwired/stimulus";

import {refreshStory} from "helpers/api";

export default class extends Controller {
  static override values = {id: String};

  declare idValue: string;

  async refresh(): Promise<void> {
    const response = await refreshStory(this.idValue);
    if (!response.ok) {
      throw new Error(`Failed to refresh story ${this.idValue}`);
    }

    const story: unknown = await response.json();
    this.dispatch("refreshed", {bubbles: true, detail: {story}});
  }
}
