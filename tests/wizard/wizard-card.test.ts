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

  it("should allow multiple users to mint", () => {
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
      address2
    );
    expect(result).toBeOk(2);
  });

  it("should track multiple unique users", () => {
    simnet.callPublicFn(
      "wizard-card",
      "mint",
      [],
      address1
    );
    
    simnet.callPublicFn(
      "wizard-card",
      "mint",
      [],
      address2
    );
    
    const { result } = simnet.callReadOnlyFn(
      "wizard-card",
      "get-total-unique-users",
      [],
      address1
    );
    expect(result).toBeUint(2);
  });

  it("should allow owner to transfer NFT", () => {
    simnet.callPublicFn(
      "wizard-card",
      "mint",
      [],
      address1
    );
    
    const { result } = simnet.callPublicFn(
      "wizard-card",
      "transfer",
      [1, address2],
      address1
    );
    expect(result).toBeOk(true);
  });

  it("should update owner after transfer", () => {
    simnet.callPublicFn(
      "wizard-card",
      "mint",
      [],
      address1
    );
    
    simnet.callPublicFn(
      "wizard-card",
      "transfer",
      [1, address2],
      address1
    );
    
    const { result } = simnet.callReadOnlyFn(
      "wizard-card",
      "get-owner",
      [1],
      address1
    );
    expect(result).toBeSome(address2);
  });

  it("should not allow non-owner to transfer", () => {
    simnet.callPublicFn(
      "wizard-card",
      "mint",
      [],
      address1
    );
    
    const { result } = simnet.callPublicFn(
      "wizard-card",
      "transfer",
      [1, address2],
      address2
    );
    expect(result).toBeErr(4);
  });

  it("should not allow transfer of non-existent NFT", () => {
    const { result } = simnet.callPublicFn(
      "wizard-card",
      "transfer",
      [999, address2],
      address1
    );
    expect(result).toBeErr(3);
  });

  it("should track interactions after transfer", () => {
    simnet.callPublicFn(
      "wizard-card",
      "mint",
      [],
      address1
    );
    
    simnet.callPublicFn(
      "wizard-card",
      "transfer",
      [1, address2],
      address1
    );
    
    const { result } = simnet.callReadOnlyFn(
      "wizard-card",
      "my-interactions",
      [],
      address1
    );
    expect(result).toBeUint(2);
  });

  it("should allow new owner to transfer again", () => {
    simnet.callPublicFn(
      "wizard-card",
      "mint",
      [],
      address1
    );
    
    simnet.callPublicFn(
      "wizard-card",
      "transfer",
      [1, address2],
      address1
    );
    
    const { result } = simnet.callPublicFn(
      "wizard-card",
      "transfer",
      [1, address3],
      address2
    );
    expect(result).toBeOk(true);
  });

  it("should return correct has-user-minted for different users", () => {
    simnet.callPublicFn(
      "wizard-card",
      "mint",
      [],
      address1
    );
    
    const { result1 } = simnet.callReadOnlyFn(
      "wizard-card",
      "has-user-minted",
      [address1],
      address1
    );
    expect(result1).toBeBool(true);
    
    const { result2 } = simnet.callReadOnlyFn(
      "wizard-card",
      "has-user-minted",
      [address2],
      address1
    );
    expect(result2).toBeBool(false);
  });

  it("should increment token counter correctly with multiple mints", () => {
    simnet.callPublicFn(
      "wizard-card",
      "mint",
      [],
      address1
    );
    
    simnet.callPublicFn(
      "wizard-card",
      "mint",
      [],
      address2
    );
    
    simnet.callPublicFn(
      "wizard-card",
      "mint",
      [],
      address3
    );
    
    const { result } = simnet.callReadOnlyFn(
      "wizard-card",
      "get-next-token-id",
      [],
      address1
    );
    expect(result).toBeUint(4);
  });
});
