function csrfToken(): string {
  const tag =
    document.querySelector<HTMLMetaElement>("meta[name='csrf-token']");

  return tag?.content ?? "";
}

async function updateStory(
  id: string,
  attributes: {[key: string]: unknown},
): Promise<Response> {
  return fetch(`/stories/${id}`, {
    body: JSON.stringify(attributes),
    headers: {
      "Content-Type": "application/json",
      "X-CSRF-Token": csrfToken(),
    },
    method: "PUT",
  });
}

export {updateStory};
