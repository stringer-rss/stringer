/// <reference types="vitest/globals" />

beforeEach(() => {
  expect.hasAssertions();
});

// Specs that call vi.useFakeTimers() get real timers back afterward.
afterEach(() => {
  vi.useRealTimers();
});

// jsdom doesn't implement scrolling; story controllers scroll stories into view.
window.HTMLElement.prototype.scrollIntoView = (): void => {
  // noop
};
