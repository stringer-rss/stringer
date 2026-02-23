import {bootStimulus} from "support/stimulus";
import EnclosureDownloadController from "controllers/enclosure_download_controller";

function buildLink(format: string): HTMLAnchorElement {
  const link = document.createElement("a");
  link.href = "https://example.com/episodes/episode-42.mp3";
  link.className = "story-enclosure";
  link.setAttribute("data-controller", "enclosure-download");
  link.setAttribute("data-enclosure-download-title-value", "Episode 42");
  link.setAttribute("data-enclosure-download-source-value", "My Podcast");
  link.setAttribute("data-enclosure-download-date-value", "Feb 22, 10:00");
  link.setAttribute("data-enclosure-download-format-value", format);

  const icon = document.createElement("i");
  icon.className = "fa fa-download";
  link.appendChild(icon);

  document.body.appendChild(link);
  return link;
}

afterEach(() => {
  document.body.innerHTML = "";
});

describe("EnclosureDownloadController", () => {
  describe('when format is "original"', () => {
    it("does not prevent default link behavior", async () => {
      const link = buildLink("original");
      await bootStimulus("enclosure-download", EnclosureDownloadController);

      const event = new MouseEvent("click", {bubbles: true, cancelable: true});
      link.dispatchEvent(event);

      expect(event.defaultPrevented).toBe(false);
    });
  });

  describe('when format is "date_source_title"', () => {
    it("fetches the file and triggers a download", async () => {
      const link = buildLink("date_source_title");
      await bootStimulus("enclosure-download", EnclosureDownloadController);

      const blob = new Blob(["audio"], {type: "audio/mpeg"});
      const mockResponse = new Response(blob, {status: 200});
      const fetchSpy = vi
        .spyOn(globalThis, "fetch")
        .mockResolvedValue(mockResponse);

      const revokeObjectURL = vi
        .spyOn(URL, "revokeObjectURL")
        .mockImplementation(() => {});
      const createObjectURL = vi
        .spyOn(URL, "createObjectURL")
        .mockReturnValue("blob:http://localhost/fake");

      const clickedLinks: HTMLAnchorElement[] = [];
      vi.spyOn(HTMLAnchorElement.prototype, "click").mockImplementation(
        function (this: HTMLAnchorElement) {
          clickedLinks.push(this);
        },
      );

      const event = new MouseEvent("click", {bubbles: true, cancelable: true});
      link.dispatchEvent(event);

      expect(event.defaultPrevented).toBe(true);
      expect(fetchSpy).toHaveBeenCalledWith(link.href);

      await vi.waitFor(() => {
        expect(clickedLinks).toHaveLength(1);
      });

      const downloadLink = clickedLinks[0]!;
      expect(downloadLink.download).toBe(
        "Feb 22, 10_00 - My Podcast - Episode 42.mp3",
      );
      expect(downloadLink.href).toBe("blob:http://localhost/fake");
      expect(createObjectURL).toHaveBeenCalledOnce();
      expect(revokeObjectURL).toHaveBeenCalledWith("blob:http://localhost/fake");
    });

    it("falls back to window.open on fetch failure", async () => {
      const link = buildLink("date_source_title");
      await bootStimulus("enclosure-download", EnclosureDownloadController);

      vi.spyOn(globalThis, "fetch").mockRejectedValue(
        new TypeError("Failed to fetch"),
      );
      const openSpy = vi
        .spyOn(window, "open")
        .mockImplementation(() => null);

      const event = new MouseEvent("click", {bubbles: true, cancelable: true});
      link.dispatchEvent(event);

      await vi.waitFor(() => {
        expect(openSpy).toHaveBeenCalledWith(link.href);
      });
    });
  });
});
