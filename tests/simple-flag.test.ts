import { describe, expect, it } from "vitest";

const accounts = simnet.getAccounts();
const address1 = accounts.get("wallet_1")!;
const address2 = accounts.get("wallet_2")!;

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

  it("should toggle flag from false to true", () => {
    simnet.callPublicFn(
      "simple-flag",
      "set-flag",
      [false],
      address1
    );
    
    const { result: toggleResult } = simnet.callPublicFn(
      "simple-flag",
      "toggle-flag",
      [],
      address1
    );
    expect(toggleResult).toBeOk(true);
    
    const { result: flagResult } = simnet.callReadOnlyFn(
      "simple-flag",
      "my-flag",
      [],
      address1
    );
    expect(flagResult).toBeBool(true);
  });

  it("should toggle flag from true to false", () => {
    simnet.callPublicFn(
      "simple-flag",
      "set-flag",
      [true],
      address1
    );
    
    const { result: toggleResult } = simnet.callPublicFn(
      "simple-flag",
      "toggle-flag",
      [],
      address1
    );
    expect(toggleResult).toBeOk(true);
    
    const { result: flagResult } = simnet.callReadOnlyFn(
      "simple-flag",
      "my-flag",
      [],
      address1
    );
    expect(flagResult).toBeBool(false);
  });

  it("should toggle flag when not set (defaults to false)", () => {
    const { result: toggleResult } = simnet.callPublicFn(
      "simple-flag",
      "toggle-flag",
      [],
      address1
    );
    expect(toggleResult).toBeOk(true);
    
    const { result: flagResult } = simnet.callReadOnlyFn(
      "simple-flag",
      "my-flag",
      [],
      address1
    );
    expect(flagResult).toBeBool(true);
  });

  it("should track flags separately for different users", () => {
    simnet.callPublicFn(
      "simple-flag",
      "set-flag",
      [true],
      address1
    );
    
    simnet.callPublicFn(
      "simple-flag",
      "set-flag",
      [false],
      address2
    );
    
    const { result: flag1 } = simnet.callReadOnlyFn(
      "simple-flag",
      "get-flag",
      [address1],
      address1
    );
    expect(flag1).toBeBool(true);
    
    const { result: flag2 } = simnet.callReadOnlyFn(
      "simple-flag",
      "get-flag",
      [address2],
      address1
    );
    expect(flag2).toBeBool(false);
  });

  it("should increment unique users count", () => {
    simnet.callPublicFn(
      "simple-flag",
      "set-flag",
      [true],
      address1
    );
    
    const { result } = simnet.callReadOnlyFn(
      "simple-flag",
      "get-total-unique-users",
      [],
      address1
    );
    expect(result).toBeUint(1);
  });

  it("should increment interactions count", () => {
    simnet.callPublicFn(
      "simple-flag",
      "set-flag",
      [true],
      address1
    );
    
    simnet.callPublicFn(
      "simple-flag",
      "toggle-flag",
      [],
      address1
    );
    
    simnet.callPublicFn(
      "simple-flag",
      "set-flag",
      [false],
      address1
    );
    
    const { result } = simnet.callReadOnlyFn(
      "simple-flag",
      "my-interactions",
      [],
      address1
    );
    expect(result).toBeUint(3);
  });

  it("should check if user has interacted", () => {
    const { result: before } = simnet.callReadOnlyFn(
      "simple-flag",
      "has-user-interacted",
      [address1],
      address1
    );
    expect(before).toBeBool(false);
    
    simnet.callPublicFn(
      "simple-flag",
      "set-flag",
      [true],
      address1
    );
    
    const { result: after } = simnet.callReadOnlyFn(
      "simple-flag",
      "has-user-interacted",
      [address1],
      address1
    );
    expect(after).toBeBool(true);
  });

  it("should allow multiple toggles", () => {
    simnet.callPublicFn(
      "simple-flag",
      "set-flag",
      [false],
      address1
    );
    
    simnet.callPublicFn(
      "simple-flag",
      "toggle-flag",
      [],
      address1
    );
    
    simnet.callPublicFn(
      "simple-flag",
      "toggle-flag",
      [],
      address1
    );
    
    simnet.callPublicFn(
      "simple-flag",
      "toggle-flag",
      [],
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
});
