import { describe, expect, it } from "vitest";

const accounts = simnet.getAccounts();
const address1 = accounts.get("wallet_1")!;
const address2 = accounts.get("wallet_2")!;

describe("wizard-game tests", () => {
  it("ensures simnet is well initialised", () => {
    expect(simnet.blockHeight).toBeDefined();
  });

  it("should return contract owner", () => {
    const { result } = simnet.callReadOnlyFn(
      "wizard-game",
      "get-contract-info",
      [],
      address1
    );
    expect(result).toBeOk();
    expect(result.value.owner).toBePrincipal(address1);
  });

  it("should start with zero wizards", () => {
    const { result } = simnet.callReadOnlyFn(
      "wizard-game",
      "get-total-unique-wizards",
      [],
      address1
    );
    expect(result).toBeUint(0);
  });

  it("should start with zero XP", () => {
    const { result } = simnet.callReadOnlyFn(
      "wizard-game",
      "my-xp",
      [],
      address1
    );
    expect(result).toBeUint(0);
  });

  it("should start with zero level", () => {
    const { result } = simnet.callReadOnlyFn(
      "wizard-game",
      "my-level",
      [],
      address1
    );
    expect(result).toBeUint(0);
  });

  it("should allow owner to set wizard token contract", () => {
    const { result } = simnet.callPublicFn(
      "wizard-game",
      "set-wizard-token",
      [".wizard-token"],
      address1
    );
    expect(result).toBeOk(true);
  });

  it("should not allow non-owner to set wizard token contract", () => {
    const { result } = simnet.callPublicFn(
      "wizard-game",
      "set-wizard-token",
      [".wizard-token"],
      address2
    );
    expect(result).toBeErr(1);
  });

  it("should allow owner to set wizard card contract", () => {
    const { result } = simnet.callPublicFn(
      "wizard-game",
      "set-wizard-card",
      [".simple-nft"],
      address1
    );
    expect(result).toBeOk(true);
  });

  it("should allow owner to set NFT requirement", () => {
    const { result } = simnet.callPublicFn(
      "wizard-game",
      "set-nft-required-for-actions",
      [true],
      address1
    );
    expect(result).toBeOk(true);
  });

  it("should return contract info after setting values", () => {
    simnet.callPublicFn(
      "wizard-game",
      "set-wizard-token",
      [".wizard-token"],
      address1
    );
    
    const { result } = simnet.callReadOnlyFn(
      "wizard-game",
      "get-contract-info",
      [],
      address1
    );
    expect(result).toBeOk();
    expect(result.value.wizard-token).toBeSome(".wizard-token");
  });
});
