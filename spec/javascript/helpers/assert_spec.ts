import {assert} from "javascript/helpers";

describe("assert", () => {
  it("throws an error when the passed value is null", () => {
    expect(() => { assert(null); }).toThrow("value is null or undefined");
  });

  it("throws an error when the passed value is undefined", () => {
    expect(() => { assert(undefined); }).toThrow("value is null or undefined");
  });

  it("does not throw an error when the passed value is 0", () => {
    expect(() => { assert(0); }).not.toThrow();
  });

  it("does not throw an error when the passed value is false", () => {
    expect(() => { assert(false); }).not.toThrow();
  });

  it("does not throw an error when the passed value is empty string", () => {
    expect(() => { assert(""); }).not.toThrow();
  });

  it("returns the passed value", () => {
    expect(assert("blah")).toBe("blah");
    expect(assert(0)).toBe(0);

    const obj = {bloo: "blah"};

    expect(assert(obj)).toBe(obj);
  });
});
