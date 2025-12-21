import { describe, expect, it } from "vitest";

const accounts = simnet.getAccounts();
const address1 = accounts.get("wallet_1")!;
const address2 = accounts.get("wallet_2")!;
const address3 = accounts.get("wallet_3")!;

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

  it("should allow transferring tokens", () => {
    simnet.callPublicFn(
      "simple-token",
      "mint",
      [address1, 1000],
      address1
    );
    
    const { result } = simnet.callPublicFn(
      "simple-token",
      "transfer",
      [address2, 300],
      address1
    );
    expect(result).toBeOk(true);
  });

  it("should update balances after transfer", () => {
    simnet.callPublicFn(
      "simple-token",
      "mint",
      [address1, 1000],
      address1
    );
    
    simnet.callPublicFn(
      "simple-token",
      "transfer",
      [address2, 400],
      address1
    );
    
    const { result: balance1 } = simnet.callReadOnlyFn(
      "simple-token",
      "get-balance-of",
      [address1],
      address1
    );
    expect(balance1).toBeUint(600);
    
    const { result: balance2 } = simnet.callReadOnlyFn(
      "simple-token",
      "get-balance-of",
      [address2],
      address1
    );
    expect(balance2).toBeUint(400);
  });

  it("should not allow transferring more than balance", () => {
    simnet.callPublicFn(
      "simple-token",
      "mint",
      [address1, 100],
      address1
    );
    
    const { result } = simnet.callPublicFn(
      "simple-token",
      "transfer",
      [address2, 200],
      address1
    );
    expect(result).toBeErr(2);
  });

  it("should not allow transferring zero tokens", () => {
    simnet.callPublicFn(
      "simple-token",
      "mint",
      [address1, 100],
      address1
    );
    
    const { result } = simnet.callPublicFn(
      "simple-token",
      "transfer",
      [address2, 0],
      address1
    );
    expect(result).toBeErr(1);
  });

  it("should allow burning tokens", () => {
    simnet.callPublicFn(
      "simple-token",
      "mint",
      [address1, 1000],
      address1
    );
    
    const { result } = simnet.callPublicFn(
      "simple-token",
      "burn",
      [300],
      address1
    );
    expect(result).toBeOk(true);
  });

  it("should update balance and supply after burning", () => {
    simnet.callPublicFn(
      "simple-token",
      "mint",
      [address1, 1000],
      address1
    );
    
    simnet.callPublicFn(
      "simple-token",
      "burn",
      [250],
      address1
    );
    
    const { result: balance } = simnet.callReadOnlyFn(
      "simple-token",
      "get-balance",
      [],
      address1
    );
    expect(balance).toBeUint(750);
    
    const { result: supply } = simnet.callReadOnlyFn(
      "simple-token",
      "get-total-supply",
      [],
      address1
    );
    expect(supply).toBeUint(750);
  });

  it("should not allow burning more than balance", () => {
    simnet.callPublicFn(
      "simple-token",
      "mint",
      [address1, 100],
      address1
    );
    
    const { result } = simnet.callPublicFn(
      "simple-token",
      "burn",
      [200],
      address1
    );
    expect(result).toBeErr(5);
  });

  it("should not allow burning zero tokens", () => {
    simnet.callPublicFn(
      "simple-token",
      "mint",
      [address1, 100],
      address1
    );
    
    const { result } = simnet.callPublicFn(
      "simple-token",
      "burn",
      [0],
      address1
    );
    expect(result).toBeErr(4);
  });

  it("should handle multiple mints correctly", () => {
    simnet.callPublicFn(
      "simple-token",
      "mint",
      [address1, 500],
      address1
    );
    
    simnet.callPublicFn(
      "simple-token",
      "mint",
      [address1, 300],
      address1
    );
    
    simnet.callPublicFn(
      "simple-token",
      "mint",
      [address2, 200],
      address1
    );
    
    const { result: supply } = simnet.callReadOnlyFn(
      "simple-token",
      "get-total-supply",
      [],
      address1
    );
    expect(supply).toBeUint(1000);
    
    const { result: balance1 } = simnet.callReadOnlyFn(
      "simple-token",
      "get-balance-of",
      [address1],
      address1
    );
    expect(balance1).toBeUint(800);
    
    const { result: balance2 } = simnet.callReadOnlyFn(
      "simple-token",
      "get-balance-of",
      [address2],
      address1
    );
    expect(balance2).toBeUint(200);
  });

  it("should handle multiple transfers correctly", () => {
    simnet.callPublicFn(
      "simple-token",
      "mint",
      [address1, 1000],
      address1
    );
    
    simnet.callPublicFn(
      "simple-token",
      "transfer",
      [address2, 200],
      address1
    );
    
    simnet.callPublicFn(
      "simple-token",
      "transfer",
      [address3, 300],
      address1
    );
    
    const { result: balance1 } = simnet.callReadOnlyFn(
      "simple-token",
      "get-balance-of",
      [address1],
      address1
    );
    expect(balance1).toBeUint(500);
    
    const { result: balance2 } = simnet.callReadOnlyFn(
      "simple-token",
      "get-balance-of",
      [address2],
      address1
    );
    expect(balance2).toBeUint(200);
    
    const { result: balance3 } = simnet.callReadOnlyFn(
      "simple-token",
      "get-balance-of",
      [address3],
      address1
    );
    expect(balance3).toBeUint(300);
  });

  it("should increment unique users count", () => {
    simnet.callPublicFn(
      "simple-token",
      "mint",
      [address1, 100],
      address1
    );
    
    const { result } = simnet.callReadOnlyFn(
      "simple-token",
      "get-total-unique-users",
      [],
      address1
    );
    expect(result).toBeUint(1);
  });

  it("should increment interactions count", () => {
    simnet.callPublicFn(
      "simple-token",
      "mint",
      [address1, 100],
      address1
    );
    
    simnet.callPublicFn(
      "simple-token",
      "transfer",
      [address2, 50],
      address1
    );
    
    simnet.callPublicFn(
      "simple-token",
      "burn",
      [25],
      address1
    );
    
    const { result } = simnet.callReadOnlyFn(
      "simple-token",
      "my-interactions",
      [],
      address1
    );
    expect(result).toBeUint(3);
  });

  it("should check if user has interacted", () => {
    const { result: before } = simnet.callReadOnlyFn(
      "simple-token",
      "has-user-interacted",
      [address1],
      address1
    );
    expect(before).toBeBool(false);
    
    simnet.callPublicFn(
      "simple-token",
      "mint",
      [address1, 100],
      address1
    );
    
    const { result: after } = simnet.callReadOnlyFn(
      "simple-token",
      "has-user-interacted",
      [address1],
      address1
    );
    expect(after).toBeBool(true);
  });

  it("should maintain correct supply after mint and burn", () => {
    simnet.callPublicFn(
      "simple-token",
      "mint",
      [address1, 1000],
      address1
    );
    
    simnet.callPublicFn(
      "simple-token",
      "burn",
      [200],
      address1
    );
    
    simnet.callPublicFn(
      "simple-token",
      "mint",
      [address2, 500],
      address1
    );
    
    simnet.callPublicFn(
      "simple-token",
      "burn",
      [100],
      address2
    );
    
    const { result: supply } = simnet.callReadOnlyFn(
      "simple-token",
      "get-total-supply",
      [],
      address1
    );
    expect(supply).toBeUint(1200);
  });
});
