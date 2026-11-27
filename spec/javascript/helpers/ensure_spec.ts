import { ensure } from "helpers/ensure";

describe("ensure", () => {
  it("throws an error when the passed value is null", () => {
    expect(() => { ensure(null); }).toThrow("value is null or undefined");
  });

  it("throws an error when the passed value is undefined", () => {
    expect(() => { ensure(undefined); }).toThrow("value is null or undefined");
  });

  it("does not throw an error when the passed value is 0", () => {
    expect(() => { ensure(0); }).not.toThrow();
  });

  it("does not throw an error when the passed value is false", () => {
    expect(() => { ensure(false); }).not.toThrow();
  });

  it("does not throw an error when the passed value is empty string", () => {
    expect(() => { ensure(""); }).not.toThrow();
  });

  it("returns the passed value", () => {
    expect(ensure("blah")).toBe("blah");
    expect(ensure(0)).toBe(0);

    const obj = { bloo: "blah" };

    expect(ensure(obj)).toBe(obj);
  });
});
