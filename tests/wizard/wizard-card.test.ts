import { describe, expect, it } from "vitest";

const accounts = simnet.getAccounts();
const address1 = accounts.get("wallet_1")!;
const address2 = accounts.get("wallet_2")!;
const address3 = accounts.get("wallet_3")!;

describe("wizard-card tests", () => {
  it("ensures simnet is well initialised", () => {
    expect(simnet.blockHeight).toBeDefined();
  });

  it("should return token name", () => {
    const { result } = simnet.callReadOnlyFn(
      "wizard-card",
      "get-name",
      [],
      address1
    );
    expect(result).toBeOk("Wizard Card");
  });

  it("should return token symbol", () => {
    const { result } = simnet.callReadOnlyFn(
      "wizard-card",
      "get-symbol",
      [],
      address1
    );
    expect(result).toBeOk("WIZCARD");
  });

  it("should start with zero unique users", () => {
    const { result } = simnet.callReadOnlyFn(
      "wizard-card",
      "get-total-unique-users",
      [],
      address1
    );
    expect(result).toBeUint(0);
  });

  it("should start with next token id as 1", () => {
    const { result } = simnet.callReadOnlyFn(
      "wizard-card",
      "get-next-token-id",
      [],
      address1
    );
    expect(result).toBeUint(1);
  });

  it("should allow user to mint a card", () => {
    const { result } = simnet.callPublicFn(
      "wizard-card",
      "mint",
      [],
      address1
    );
    expect(result).toBeOk(1);
  });

  it("should not allow user to mint twice", () => {
    simnet.callPublicFn(
      "wizard-card",
      "mint",
      [],
      address1
    );
    
    const { result } = simnet.callPublicFn(
      "wizard-card",
      "mint",
      [],
      address1
    );
    expect(result).toBeErr(1);
  });

  it("should return owner of minted NFT", () => {
    simnet.callPublicFn(
      "wizard-card",
      "mint",
      [],
      address1
    );
    
    const { result } = simnet.callReadOnlyFn(
      "wizard-card",
      "get-owner",
      [1],
      address1
    );
    expect(result).toBeSome(address1);
  });

  it("should update has-minted after minting", () => {
    simnet.callPublicFn(
      "wizard-card",
      "mint",
      [],
      address1
    );
    
    const { result } = simnet.callReadOnlyFn(
      "wizard-card",
      "my-has-minted",
      [],
      address1
    );
    expect(result).toBeBool(true);
  });

  it("should increment unique users after mint", () => {
    simnet.callPublicFn(
      "wizard-card",
      "mint",
      [],
      address1
    );
    
    const { result } = simnet.callReadOnlyFn(
      "wizard-card",
      "get-total-unique-users",
      [],
      address1
    );
    expect(result).toBeUint(1);
  });

  it("should increment token counter after mint", () => {
    simnet.callPublicFn(
      "wizard-card",
      "mint",
      [],
      address1
    );
    
    const { result } = simnet.callReadOnlyFn(
      "wizard-card",
      "get-next-token-id",
      [],
      address1
    );
    expect(result).toBeUint(2);
  });
});
