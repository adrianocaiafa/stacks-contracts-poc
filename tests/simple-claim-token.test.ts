import { describe, expect, it } from "vitest";

const accounts = simnet.getAccounts();
const address1 = accounts.get("wallet_1")!;
const address2 = accounts.get("wallet_2")!;
const address3 = accounts.get("wallet_3")!;

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

  it("should allow transferring tokens", () => {
    simnet.callPublicFn(
      "simple-claim-token",
      "claim",
      [],
      address1
    );
    
    const { result } = simnet.callPublicFn(
      "simple-claim-token",
      "transfer",
      [address2, 500000000],
      address1
    );
    expect(result).toBeOk(true);
  });

  it("should update balances after transfer", () => {
    simnet.callPublicFn(
      "simple-claim-token",
      "claim",
      [],
      address1
    );
    
    simnet.callPublicFn(
      "simple-claim-token",
      "transfer",
      [address2, 300000000],
      address1
    );
    
    const { result: balance1 } = simnet.callReadOnlyFn(
      "simple-claim-token",
      "get-balance-of",
      [address1],
      address1
    );
    expect(balance1).toBeUint(700000000);
    
    const { result: balance2 } = simnet.callReadOnlyFn(
      "simple-claim-token",
      "get-balance-of",
      [address2],
      address1
    );
    expect(balance2).toBeUint(300000000);
  });

  it("should not allow transferring more than balance", () => {
    simnet.callPublicFn(
      "simple-claim-token",
      "claim",
      [],
      address1
    );
    
    const { result } = simnet.callPublicFn(
      "simple-claim-token",
      "transfer",
      [address2, 2000000000],
      address1
    );
    expect(result).toBeErr(3);
  });

  it("should not allow transferring zero tokens", () => {
    simnet.callPublicFn(
      "simple-claim-token",
      "claim",
      [],
      address1
    );
    
    const { result } = simnet.callPublicFn(
      "simple-claim-token",
      "transfer",
      [address2, 0],
      address1
    );
    expect(result).toBeErr(2);
  });

  it("should track multiple users claiming", () => {
    simnet.callPublicFn(
      "simple-claim-token",
      "claim",
      [],
      address1
    );
    
    simnet.callPublicFn(
      "simple-claim-token",
      "claim",
      [],
      address2
    );
    
    simnet.callPublicFn(
      "simple-claim-token",
      "claim",
      [],
      address3
    );
    
    const { result: supply } = simnet.callReadOnlyFn(
      "simple-claim-token",
      "get-total-supply",
      [],
      address1
    );
    expect(supply).toBeUint(3000000000);
    
    const { result: balance1 } = simnet.callReadOnlyFn(
      "simple-claim-token",
      "get-balance-of",
      [address1],
      address1
    );
    expect(balance1).toBeUint(1000000000);
    
    const { result: balance2 } = simnet.callReadOnlyFn(
      "simple-claim-token",
      "get-balance-of",
      [address2],
      address1
    );
    expect(balance2).toBeUint(1000000000);
  });

  it("should allow multiple transfers", () => {
    simnet.callPublicFn(
      "simple-claim-token",
      "claim",
      [],
      address1
    );
    
    simnet.callPublicFn(
      "simple-claim-token",
      "transfer",
      [address2, 200000000],
      address1
    );
    
    simnet.callPublicFn(
      "simple-claim-token",
      "transfer",
      [address3, 300000000],
      address1
    );
    
    const { result: balance1 } = simnet.callReadOnlyFn(
      "simple-claim-token",
      "get-balance-of",
      [address1],
      address1
    );
    expect(balance1).toBeUint(500000000);
    
    const { result: balance2 } = simnet.callReadOnlyFn(
      "simple-claim-token",
      "get-balance-of",
      [address2],
      address1
    );
    expect(balance2).toBeUint(200000000);
    
    const { result: balance3 } = simnet.callReadOnlyFn(
      "simple-claim-token",
      "get-balance-of",
      [address3],
      address1
    );
    expect(balance3).toBeUint(300000000);
  });

  it("should increment unique users count", () => {
    simnet.callPublicFn(
      "simple-claim-token",
      "claim",
      [],
      address1
    );
    
    const { result } = simnet.callReadOnlyFn(
      "simple-claim-token",
      "get-total-unique-users",
      [],
      address1
    );
    expect(result).toBeUint(1);
  });

  it("should increment interactions count", () => {
    simnet.callPublicFn(
      "simple-claim-token",
      "claim",
      [],
      address1
    );
    
    simnet.callPublicFn(
      "simple-claim-token",
      "transfer",
      [address2, 100000000],
      address1
    );
    
    const { result } = simnet.callReadOnlyFn(
      "simple-claim-token",
      "my-interactions",
      [],
      address1
    );
    expect(result).toBeUint(2);
  });

  it("should check if user has interacted", () => {
    const { result: before } = simnet.callReadOnlyFn(
      "simple-claim-token",
      "has-user-interacted",
      [address1],
      address1
    );
    expect(before).toBeBool(false);
    
    simnet.callPublicFn(
      "simple-claim-token",
      "claim",
      [],
      address1
    );
    
    const { result: after } = simnet.callReadOnlyFn(
      "simple-claim-token",
      "has-user-interacted",
      [address1],
      address1
    );
    expect(after).toBeBool(true);
  });

  it("should maintain correct supply after multiple claims", () => {
    simnet.callPublicFn(
      "simple-claim-token",
      "claim",
      [],
      address1
    );
    
    simnet.callPublicFn(
      "simple-claim-token",
      "claim",
      [],
      address2
    );
    
    simnet.callPublicFn(
      "simple-claim-token",
      "claim",
      [],
      address3
    );
    
    const { result: supply } = simnet.callReadOnlyFn(
      "simple-claim-token",
      "get-total-supply",
      [],
      address1
    );
    expect(supply).toBeUint(3000000000);
  });

  it("should allow transfer after claiming", () => {
    simnet.callPublicFn(
      "simple-claim-token",
      "claim",
      [],
      address1
    );
    
    simnet.callPublicFn(
      "simple-claim-token",
      "claim",
      [],
      address2
    );
    
    simnet.callPublicFn(
      "simple-claim-token",
      "transfer",
      [address3, 500000000],
      address1
    );
    
    simnet.callPublicFn(
      "simple-claim-token",
      "transfer",
      [address1, 200000000],
      address2
    );
    
    const { result: balance1 } = simnet.callReadOnlyFn(
      "simple-claim-token",
      "get-balance-of",
      [address1],
      address1
    );
    expect(balance1).toBeUint(700000000);
    
    const { result: balance2 } = simnet.callReadOnlyFn(
      "simple-claim-token",
      "get-balance-of",
      [address2],
      address1
    );
    expect(balance2).toBeUint(500000000);
    
    const { result: balance3 } = simnet.callReadOnlyFn(
      "simple-claim-token",
      "get-balance-of",
      [address3],
      address1
    );
    expect(balance3).toBeUint(500000000);
  });
});
