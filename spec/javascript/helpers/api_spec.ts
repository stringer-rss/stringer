import {updateStory} from "helpers/api";

describe("updateStory", () => {
  // eslint-disable-next-line vitest/no-hooks
  afterEach(() => {
    vi.restoreAllMocks();
  });

  it("sends a PUT with JSON body and CSRF token", async () => {
    const mockResponse = new Response("", {status: 200});
    const fetchSpy = vi.spyOn(globalThis, "fetch").
      mockResolvedValue(mockResponse);

    const meta = document.createElement("meta");
    meta.name = "csrf-token";
    meta.content = "test-token";
    document.head.appendChild(meta);

    // eslint-disable-next-line camelcase
    await updateStory("42", {is_starred: true});

    expect(fetchSpy).toHaveBeenCalledWith("/stories/42", {
      // eslint-disable-next-line camelcase
      body: JSON.stringify({is_starred: true}),
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": "test-token",
      },
      method: "PUT",
    });

    meta.remove();
  });

  it("sends empty CSRF token when meta tag is missing", async () => {
    const fetchSpy = vi.spyOn(globalThis, "fetch").
      mockResolvedValue(new Response());

    // eslint-disable-next-line camelcase
    await updateStory("1", {is_starred: false});

    expect(fetchSpy).toHaveBeenCalledTimes(1);

    const {headers} = fetchSpy.mock.calls[0]?.[1] ?? {};

    expect(headers).toHaveProperty("X-CSRF-Token", "");
  });
});
