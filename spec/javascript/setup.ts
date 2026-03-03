// @ts-nocheck
/// <reference types="vitest/globals" />

import "jquery";

beforeEach(() => {
  expect.hasAssertions();
});

const jquery = window.jQuery;
globalThis.$ = jquery;
globalThis.jQuery = jquery;
