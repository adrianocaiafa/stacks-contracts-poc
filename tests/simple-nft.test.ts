import { describe, expect, it } from "vitest";

const accounts = simnet.getAccounts();
const address1 = accounts.get("wallet_1")!;
const address2 = accounts.get("wallet_2")!;

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
});
