import { describe, expect, it } from "vitest";

const accounts = simnet.getAccounts();
const address1 = accounts.get("wallet_1")!;

describe("simple-claim-token tests", () => {
  it("ensures simnet is well initialised", () => {
    expect(simnet.blockHeight).toBeDefined();
  });

  it("should start with zero total supply", () => {
    const { result } = simnet.callReadOnlyFn(
      "simple-claim-token",
      "get-total-supply",
      [],
      address1
    );
    expect(result).toBeUint(0);
  });

  it("should return zero balance initially", () => {
    const { result } = simnet.callReadOnlyFn(
      "simple-claim-token",
      "get-balance",
      [],
      address1
    );
    expect(result).toBeUint(0);
  });

  it("should return false for has-claimed initially", () => {
    const { result } = simnet.callReadOnlyFn(
      "simple-claim-token",
      "has-claimed",
      [],
      address1
    );
    expect(result).toBeBool(false);
  });

  it("should return token name", () => {
    const { result } = simnet.callReadOnlyFn(
      "simple-claim-token",
      "get-name",
      [],
      address1
    );
    expect(result).toBe("Wizard Mana");
  });

  it("should return token symbol", () => {
    const { result } = simnet.callReadOnlyFn(
      "simple-claim-token",
      "get-symbol",
      [],
      address1
    );
    expect(result).toBe("MANA");
  });

  it("should return claim amount", () => {
    const { result } = simnet.callReadOnlyFn(
      "simple-claim-token",
      "get-claim-amount",
      [],
      address1
    );
    expect(result).toBeUint(1000000000);
  });

  it("should allow claiming tokens", () => {
    const { result } = simnet.callPublicFn(
      "simple-claim-token",
      "claim",
      [],
      address1
    );
    expect(result).toBeOk(true);
  });

  it("should update balance after claiming", () => {
    simnet.callPublicFn(
      "simple-claim-token",
      "claim",
      [],
      address1
    );
    
    const { result } = simnet.callReadOnlyFn(
      "simple-claim-token",
      "get-balance",
      [],
      address1
    );
    expect(result).toBeUint(1000000000);
  });

  it("should update total supply after claiming", () => {
    simnet.callPublicFn(
      "simple-claim-token",
      "claim",
      [],
      address1
    );
    
    const { result } = simnet.callReadOnlyFn(
      "simple-claim-token",
      "get-total-supply",
      [],
      address1
    );
    expect(result).toBeUint(1000000000);
  });

  it("should mark user as claimed after claiming", () => {
    simnet.callPublicFn(
      "simple-claim-token",
      "claim",
      [],
      address1
    );
    
    const { result } = simnet.callReadOnlyFn(
      "simple-claim-token",
      "has-claimed",
      [],
      address1
    );
    expect(result).toBeBool(true);
  });

  it("should not allow claiming twice", () => {
    simnet.callPublicFn(
      "simple-claim-token",
      "claim",
      [],
      address1
    );
    
    const { result } = simnet.callPublicFn(
      "simple-claim-token",
      "claim",
      [],
      address1
    );
    expect(result).toBeErr(1);
  });
});
