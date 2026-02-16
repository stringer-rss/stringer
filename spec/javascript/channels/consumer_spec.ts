import consumer from "channels/consumer";

it("is defined", () => {
  expect(consumer.url).toBe("ws://test.host/cable");
});
