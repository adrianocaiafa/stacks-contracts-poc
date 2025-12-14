import { describe, expect, it } from "vitest";

const accounts = simnet.getAccounts();
const address1 = accounts.get("wallet_1")!;

describe("simple-flag tests", () => {
  it("ensures simnet is well initialised", () => {
    expect(simnet.blockHeight).toBeDefined();
  });

  it("should start with zero unique users", () => {
    const { result } = simnet.callReadOnlyFn(
      "simple-flag",
      "get-total-unique-users",
      [],
      address1
    );
    expect(result).toBeUint(0);
  });

  it("should return false for unset flag", () => {
    const { result } = simnet.callReadOnlyFn(
      "simple-flag",
      "my-flag",
      [],
      address1
    );
    expect(result).toBeBool(false);
  });

  it("should allow setting flag to true", () => {
    const { result } = simnet.callPublicFn(
      "simple-flag",
      "set-flag",
      [true],
      address1
    );
    expect(result).toBeOk(true);
  });

  it("should return true after setting flag to true", () => {
    simnet.callPublicFn(
      "simple-flag",
      "set-flag",
      [true],
      address1
    );
    
    const { result } = simnet.callReadOnlyFn(
      "simple-flag",
      "my-flag",
      [],
      address1
    );
    expect(result).toBeBool(true);
  });

  it("should allow setting flag to false", () => {
    simnet.callPublicFn(
      "simple-flag",
      "set-flag",
      [true],
      address1
    );
    
    const { result } = simnet.callPublicFn(
      "simple-flag",
      "set-flag",
      [false],
      address1
    );
    expect(result).toBeOk(true);
    
    const { result: flagResult } = simnet.callReadOnlyFn(
      "simple-flag",
      "my-flag",
      [],
      address1
    );
    expect(flagResult).toBeBool(false);
  });
});
