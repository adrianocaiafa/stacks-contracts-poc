import { describe, expect, it } from "vitest";

const accounts = simnet.getAccounts();
const address1 = accounts.get("wallet_1")!;

describe("simple-token tests", () => {
  it("ensures simnet is well initialised", () => {
    expect(simnet.blockHeight).toBeDefined();
  });

  it("should start with zero total supply", () => {
    const { result } = simnet.callReadOnlyFn(
      "simple-token",
      "get-total-supply",
      [],
      address1
    );
    expect(result).toBeUint(0);
  });

  it("should return zero balance initially", () => {
    const { result } = simnet.callReadOnlyFn(
      "simple-token",
      "get-balance",
      [],
      address1
    );
    expect(result).toBeUint(0);
  });

  it("should return token name", () => {
    const { result } = simnet.callReadOnlyFn(
      "simple-token",
      "get-name",
      [],
      address1
    );
    expect(result).toBe("Simple Token");
  });

  it("should return token symbol", () => {
    const { result } = simnet.callReadOnlyFn(
      "simple-token",
      "get-symbol",
      [],
      address1
    );
    expect(result).toBe("STK");
  });

  it("should allow minting tokens", () => {
    const { result } = simnet.callPublicFn(
      "simple-token",
      "mint",
      [address1, 1000],
      address1
    );
    expect(result).toBeOk(true);
  });

  it("should update balance after minting", () => {
    simnet.callPublicFn(
      "simple-token",
      "mint",
      [address1, 500],
      address1
    );
    
    const { result } = simnet.callReadOnlyFn(
      "simple-token",
      "get-balance",
      [],
      address1
    );
    expect(result).toBeUint(500);
  });

  it("should update total supply after minting", () => {
    simnet.callPublicFn(
      "simple-token",
      "mint",
      [address1, 200],
      address1
    );
    
    const { result } = simnet.callReadOnlyFn(
      "simple-token",
      "get-total-supply",
      [],
      address1
    );
    expect(result).toBeUint(200);
  });

  it("should not allow minting zero tokens", () => {
    const { result } = simnet.callPublicFn(
      "simple-token",
      "mint",
      [address1, 0],
      address1
    );
    expect(result).toBeErr(3);
  });
});
