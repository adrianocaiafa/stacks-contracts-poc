import { describe, expect, it } from "vitest";

const accounts = simnet.getAccounts();
const address1 = accounts.get("wallet_1")!;
const address2 = accounts.get("wallet_2")!;
const address3 = accounts.get("wallet_3")!;

describe("simple-nft tests", () => {
  it("ensures simnet is well initialised", () => {
    expect(simnet.blockHeight).toBeDefined();
  });

  it("should return contract owner", () => {
    const { result } = simnet.callReadOnlyFn(
      "simple-nft",
      "get-contract-owner",
      [],
      address1
    );
    expect(result).toBePrincipal(address1);
  });

  it("should start with zero token counter", () => {
    const { result } = simnet.callReadOnlyFn(
      "simple-nft",
      "get-token-counter",
      [],
      address1
    );
    expect(result).toBeUint(0);
  });

  it("should return none for max supply initially", () => {
    const { result } = simnet.callReadOnlyFn(
      "simple-nft",
      "get-max-supply",
      [],
      address1
    );
    expect(result).toBeNone();
  });

  it("should allow owner to set supply", () => {
    const { result } = simnet.callPublicFn(
      "simple-nft",
      "set-supply",
      [100],
      address1
    );
    expect(result).toBeOk(true);
  });

  it("should not allow non-owner to set supply", () => {
    const { result } = simnet.callPublicFn(
      "simple-nft",
      "set-supply",
      [100],
      address2
    );
    expect(result).toBeErr(1);
  });

  it("should return max supply after setting it", () => {
    simnet.callPublicFn(
      "simple-nft",
      "set-supply",
      [50],
      address1
    );
    
    const { result } = simnet.callReadOnlyFn(
      "simple-nft",
      "get-max-supply",
      [],
      address1
    );
    expect(result).toBeSome(50);
  });

  it("should not allow minting before supply is set", () => {
    const { result } = simnet.callPublicFn(
      "simple-nft",
      "mint",
      [],
      address2
    );
    expect(result).toBeErr(5);
  });

  it("should allow minting after supply is set", () => {
    simnet.callPublicFn(
      "simple-nft",
      "set-supply",
      [100],
      address1
    );
    
    const { result } = simnet.callPublicFn(
      "simple-nft",
      "mint",
      [],
      address2
    );
    expect(result).toBeOk(true);
  });

  it("should update token counter after minting", () => {
    simnet.callPublicFn(
      "simple-nft",
      "set-supply",
      [100],
      address1
    );
    
    simnet.callPublicFn(
      "simple-nft",
      "mint",
      [],
      address2
    );
    
    const { result } = simnet.callReadOnlyFn(
      "simple-nft",
      "get-token-counter",
      [],
      address1
    );
    expect(result).toBeUint(1);
  });

  it("should return owner of minted NFT", () => {
    simnet.callPublicFn(
      "simple-nft",
      "set-supply",
      [100],
      address1
    );
    
    simnet.callPublicFn(
      "simple-nft",
      "mint",
      [],
      address2
    );
    
    const { result } = simnet.callReadOnlyFn(
      "simple-nft",
      "get-owner",
      [0],
      address1
    );
    expect(result).toBeSome(address2);
  });

  it("should update minted count after minting", () => {
    simnet.callPublicFn(
      "simple-nft",
      "set-supply",
      [100],
      address1
    );
    
    simnet.callPublicFn(
      "simple-nft",
      "mint",
      [],
      address2
    );
    
    const { result } = simnet.callReadOnlyFn(
      "simple-nft",
      "my-minted-count",
      [],
      address2
    );
    expect(result).toBeUint(1);
  });

  it("should allow minting up to 2 NFTs per user", () => {
    simnet.callPublicFn(
      "simple-nft",
      "set-supply",
      [100],
      address1
    );
    
    simnet.callPublicFn(
      "simple-nft",
      "mint",
      [],
      address2
    );
    
    const { result: mint2 } = simnet.callPublicFn(
      "simple-nft",
      "mint",
      [],
      address2
    );
    expect(mint2).toBeOk(true);
    
    const { result: count } = simnet.callReadOnlyFn(
      "simple-nft",
      "my-minted-count",
      [],
      address2
    );
    expect(count).toBeUint(2);
  });

  it("should not allow minting more than 2 NFTs per user", () => {
    simnet.callPublicFn(
      "simple-nft",
      "set-supply",
      [100],
      address1
    );
    
    simnet.callPublicFn(
      "simple-nft",
      "mint",
      [],
      address2
    );
    
    simnet.callPublicFn(
      "simple-nft",
      "mint",
      [],
      address2
    );
    
    const { result } = simnet.callPublicFn(
      "simple-nft",
      "mint",
      [],
      address2
    );
    expect(result).toBeErr(4);
  });

  it("should allow transferring NFT", () => {
    simnet.callPublicFn(
      "simple-nft",
      "set-supply",
      [100],
      address1
    );
    
    simnet.callPublicFn(
      "simple-nft",
      "mint",
      [],
      address2
    );
    
    const { result } = simnet.callPublicFn(
      "simple-nft",
      "transfer",
      [0, address3],
      address2
    );
    expect(result).toBeOk(true);
  });

  it("should update owner after transfer", () => {
    simnet.callPublicFn(
      "simple-nft",
      "set-supply",
      [100],
      address1
    );
    
    simnet.callPublicFn(
      "simple-nft",
      "mint",
      [],
      address2
    );
    
    simnet.callPublicFn(
      "simple-nft",
      "transfer",
      [0, address3],
      address2
    );
    
    const { result } = simnet.callReadOnlyFn(
      "simple-nft",
      "get-owner",
      [0],
      address1
    );
    expect(result).toBeSome(address3);
  });

  it("should not allow transferring NFT you don't own", () => {
    simnet.callPublicFn(
      "simple-nft",
      "set-supply",
      [100],
      address1
    );
    
    simnet.callPublicFn(
      "simple-nft",
      "mint",
      [],
      address2
    );
    
    const { result } = simnet.callPublicFn(
      "simple-nft",
      "transfer",
      [0, address3],
      address3
    );
    expect(result).toBeErr(6);
  });

  it("should allow multiple transfers without limits", () => {
    simnet.callPublicFn(
      "simple-nft",
      "set-supply",
      [100],
      address1
    );
    
    simnet.callPublicFn(
      "simple-nft",
      "mint",
      [],
      address2
    );
    
    simnet.callPublicFn(
      "simple-nft",
      "transfer",
      [0, address3],
      address2
    );
    
    simnet.callPublicFn(
      "simple-nft",
      "transfer",
      [0, address1],
      address3
    );
    
    simnet.callPublicFn(
      "simple-nft",
      "transfer",
      [0, address2],
      address1
    );
    
    const { result } = simnet.callReadOnlyFn(
      "simple-nft",
      "get-owner",
      [0],
      address1
    );
    expect(result).toBeSome(address2);
  });

  it("should not allow minting beyond max supply", () => {
    simnet.callPublicFn(
      "simple-nft",
      "set-supply",
      [2],
      address1
    );
    
    simnet.callPublicFn(
      "simple-nft",
      "mint",
      [],
      address2
    );
    
    simnet.callPublicFn(
      "simple-nft",
      "mint",
      [],
      address3
    );
    
    const { result } = simnet.callPublicFn(
      "simple-nft",
      "mint",
      [],
      address2
    );
    expect(result).toBeErr(3);
  });

  it("should track minted count separately for different users", () => {
    simnet.callPublicFn(
      "simple-nft",
      "set-supply",
      [100],
      address1
    );
    
    simnet.callPublicFn(
      "simple-nft",
      "mint",
      [],
      address2
    );
    
    simnet.callPublicFn(
      "simple-nft",
      "mint",
      [],
      address2
    );
    
    simnet.callPublicFn(
      "simple-nft",
      "mint",
      [],
      address3
    );
    
    const { result: count2 } = simnet.callReadOnlyFn(
      "simple-nft",
      "get-minted-count",
      [address2],
      address1
    );
    expect(count2).toBeUint(2);
    
    const { result: count3 } = simnet.callReadOnlyFn(
      "simple-nft",
      "get-minted-count",
      [address3],
      address1
    );
    expect(count3).toBeUint(1);
  });

  it("should generate unique token IDs", () => {
    simnet.callPublicFn(
      "simple-nft",
      "set-supply",
      [100],
      address1
    );
    
    simnet.callPublicFn(
      "simple-nft",
      "mint",
      [],
      address2
    );
    
    simnet.callPublicFn(
      "simple-nft",
      "mint",
      [],
      address3
    );
    
    const { result: owner1 } = simnet.callReadOnlyFn(
      "simple-nft",
      "get-owner",
      [0],
      address1
    );
    expect(owner1).toBeSome(address2);
    
    const { result: owner2 } = simnet.callReadOnlyFn(
      "simple-nft",
      "get-owner",
      [1],
      address1
    );
    expect(owner2).toBeSome(address3);
  });

  it("should increment unique users count", () => {
    simnet.callPublicFn(
      "simple-nft",
      "set-supply",
      [100],
      address1
    );
    
    simnet.callPublicFn(
      "simple-nft",
      "mint",
      [],
      address2
    );
    
    const { result } = simnet.callReadOnlyFn(
      "simple-nft",
      "get-total-unique-users",
      [],
      address1
    );
    expect(result).toBeUint(1);
  });

  it("should increment interactions count", () => {
    simnet.callPublicFn(
      "simple-nft",
      "set-supply",
      [100],
      address1
    );
    
    simnet.callPublicFn(
      "simple-nft",
      "mint",
      [],
      address2
    );
    
    simnet.callPublicFn(
      "simple-nft",
      "transfer",
      [0, address3],
      address2
    );
    
    const { result } = simnet.callReadOnlyFn(
      "simple-nft",
      "my-interactions",
      [],
      address2
    );
    expect(result).toBeUint(2);
  });

  it("should check if user has interacted", () => {
    const { result: before } = simnet.callReadOnlyFn(
      "simple-nft",
      "has-user-interacted",
      [address2],
      address1
    );
    expect(before).toBeBool(false);
    
    simnet.callPublicFn(
      "simple-nft",
      "set-supply",
      [100],
      address1
    );
    
    simnet.callPublicFn(
      "simple-nft",
      "mint",
      [],
      address2
    );
    
    const { result: after } = simnet.callReadOnlyFn(
      "simple-nft",
      "has-user-interacted",
      [address2],
      address1
    );
    expect(after).toBeBool(true);
  });

  it("should allow owner to redefine supply", () => {
    simnet.callPublicFn(
      "simple-nft",
      "set-supply",
      [50],
      address1
    );
    
    const { result } = simnet.callPublicFn(
      "simple-nft",
      "set-supply",
      [100],
      address1
    );
    expect(result).toBeOk(true);
    
    const { result: supply } = simnet.callReadOnlyFn(
      "simple-nft",
      "get-max-supply",
      [],
      address1
    );
    expect(supply).toBeSome(100);
  });
});
