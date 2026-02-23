import {Controller} from "@hotwired/stimulus";

function sanitizeFilename(name: string): string {
  return name.replace(/[<>:"/\\|?*\x00-\x1F]/g, "_").trim();
}

function extractExtension(url: string): string {
  try {
    const pathname = new URL(url).pathname;
    const match = pathname.match(/\.(\w+)$/);
    return match ? `.${match[1]}` : "";
  } catch {
    return "";
  }
}

const MAX_FILENAME_LENGTH = 200;

export default class extends Controller {
  static values = {title: String, source: String, date: String, format: String};

  declare titleValue: string;
  declare sourceValue: string;
  declare dateValue: string;
  declare formatValue: string;

  connect(): void {
    this.element.addEventListener("click", this.handleClick);
  }

  disconnect(): void {
    this.element.removeEventListener("click", this.handleClick);
  }

  handleClick = (event: Event): void => {
    if (this.formatValue !== "date_source_title") return;

    event.preventDefault();

    const href = (this.element as HTMLAnchorElement).href;
    const ext = extractExtension(href);
    const basename = sanitizeFilename(
      `${this.dateValue} - ${this.sourceValue} - ${this.titleValue}`,
    );
    const filename =
      basename.slice(0, MAX_FILENAME_LENGTH - ext.length) + ext;

    fetch(href)
      .then((response) => {
        if (!response.ok) throw new Error(`HTTP ${response.status}`);
        return response.blob();
      })
      .then((blob) => {
        const objectUrl = URL.createObjectURL(blob);
        const link = document.createElement("a");
        link.href = objectUrl;
        link.download = filename;
        document.body.appendChild(link);
        link.click();
        link.remove();
        URL.revokeObjectURL(objectUrl);
      })
      .catch(() => {
        window.open(href);
      });
  };
}
