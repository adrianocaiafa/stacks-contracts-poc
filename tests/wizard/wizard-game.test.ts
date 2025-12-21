import { describe, expect, it } from "vitest";

const accounts = simnet.getAccounts();
const address1 = accounts.get("wallet_1")!;
const address2 = accounts.get("wallet_2")!;
const address3 = accounts.get("wallet_3")!;

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

  it("should allow registering mana transfer", () => {
    simnet.callPublicFn(
      "wizard-game",
      "set-wizard-token",
      [".wizard-token"],
      address1
    );
    
    simnet.callPublicFn(
      "wizard-token",
      "claim",
      [],
      address2
    );
    
    simnet.callPublicFn(
      "wizard-token",
      "transfer",
      [".wizard-game", 2000000],
      address2
    );
    
    const { result } = simnet.callPublicFn(
      "wizard-game",
      "register-mana-transfer",
      [2000000],
      address2
    );
    expect(result).toBeOk(true);
  });

  it("should update pending mana after registering", () => {
    simnet.callPublicFn(
      "wizard-game",
      "set-wizard-token",
      [".wizard-token"],
      address1
    );
    
    simnet.callPublicFn(
      "wizard-token",
      "claim",
      [],
      address2
    );
    
    simnet.callPublicFn(
      "wizard-token",
      "transfer",
      [".wizard-game", 3000000],
      address2
    );
    
    simnet.callPublicFn(
      "wizard-game",
      "register-mana-transfer",
      [3000000],
      address2
    );
    
    const { result } = simnet.callReadOnlyFn(
      "wizard-game",
      "my-pending-mana",
      [],
      address2
    );
    expect(result).toBeUint(3000000);
  });

  it("should allow spending mana for XP", () => {
    simnet.callPublicFn(
      "wizard-game",
      "set-wizard-token",
      [".wizard-token"],
      address1
    );
    
    simnet.callPublicFn(
      "wizard-token",
      "claim",
      [],
      address2
    );
    
    simnet.callPublicFn(
      "wizard-token",
      "transfer",
      [".wizard-game", 5000000],
      address2
    );
    
    simnet.callPublicFn(
      "wizard-game",
      "register-mana-transfer",
      [5000000],
      address2
    );
    
    const { result } = simnet.callPublicFn(
      "wizard-game",
      "spend-mana-for-xp",
      [5000000],
      address2
    );
    expect(result).toBeOk(true);
  });

  it("should update XP after spending mana", () => {
    simnet.callPublicFn(
      "wizard-game",
      "set-wizard-token",
      [".wizard-token"],
      address1
    );
    
    simnet.callPublicFn(
      "wizard-token",
      "claim",
      [],
      address2
    );
    
    simnet.callPublicFn(
      "wizard-token",
      "transfer",
      [".wizard-game", 10000000],
      address2
    );
    
    simnet.callPublicFn(
      "wizard-game",
      "register-mana-transfer",
      [10000000],
      address2
    );
    
    simnet.callPublicFn(
      "wizard-game",
      "spend-mana-for-xp",
      [10000000],
      address2
    );
    
    const { result } = simnet.callReadOnlyFn(
      "wizard-game",
      "my-xp",
      [],
      address2
    );
    expect(result).toBeUint(10);
  });

  it("should level up when XP reaches threshold", () => {
    simnet.callPublicFn(
      "wizard-game",
      "set-wizard-token",
      [".wizard-token"],
      address1
    );
    
    simnet.callPublicFn(
      "wizard-token",
      "claim",
      [],
      address2
    );
    
    simnet.callPublicFn(
      "wizard-token",
      "transfer",
      [".wizard-game", 100000000],
      address2
    );
    
    simnet.callPublicFn(
      "wizard-game",
      "register-mana-transfer",
      [100000000],
      address2
    );
    
    simnet.callPublicFn(
      "wizard-game",
      "spend-mana-for-xp",
      [100000000],
      address2
    );
    
    const { result: level } = simnet.callReadOnlyFn(
      "wizard-game",
      "my-level",
      [],
      address2
    );
    expect(level).toBeUint(1000);
  });

  it("should allow casting spell on another wizard", () => {
    simnet.callPublicFn(
      "wizard-game",
      "set-wizard-token",
      [".wizard-token"],
      address1
    );
    
    simnet.callPublicFn(
      "wizard-token",
      "claim",
      [],
      address2
    );
    
    simnet.callPublicFn(
      "wizard-token",
      "transfer",
      [".wizard-game", 2000000],
      address2
    );
    
    simnet.callPublicFn(
      "wizard-game",
      "register-mana-transfer",
      [2000000],
      address2
    );
    
    const { result } = simnet.callPublicFn(
      "wizard-game",
      "cast-spell",
      [address3, 2000000],
      address2
    );
    expect(result).toBeOk(true);
  });

  it("should update spells cast count", () => {
    simnet.callPublicFn(
      "wizard-game",
      "set-wizard-token",
      [".wizard-token"],
      address1
    );
    
    simnet.callPublicFn(
      "wizard-token",
      "claim",
      [],
      address2
    );
    
    simnet.callPublicFn(
      "wizard-token",
      "transfer",
      [".wizard-game", 4000000],
      address2
    );
    
    simnet.callPublicFn(
      "wizard-game",
      "register-mana-transfer",
      [4000000],
      address2
    );
    
    simnet.callPublicFn(
      "wizard-game",
      "cast-spell",
      [address3, 2000000],
      address2
    );
    
    const { result } = simnet.callReadOnlyFn(
      "wizard-game",
      "my-spells-cast",
      [],
      address2
    );
    expect(result).toBeUint(1);
  });

  it("should not allow casting spell on yourself", () => {
    simnet.callPublicFn(
      "wizard-game",
      "set-wizard-token",
      [".wizard-token"],
      address1
    );
    
    simnet.callPublicFn(
      "wizard-token",
      "claim",
      [],
      address2
    );
    
    simnet.callPublicFn(
      "wizard-token",
      "transfer",
      [".wizard-game", 2000000],
      address2
    );
    
    simnet.callPublicFn(
      "wizard-game",
      "register-mana-transfer",
      [2000000],
      address2
    );
    
    const { result } = simnet.callPublicFn(
      "wizard-game",
      "cast-spell",
      [address2, 2000000],
      address2
    );
    expect(result).toBeErr(11);
  });

  it("should not allow spending more mana than pending", () => {
    simnet.callPublicFn(
      "wizard-game",
      "set-wizard-token",
      [".wizard-token"],
      address1
    );
    
    simnet.callPublicFn(
      "wizard-token",
      "claim",
      [],
      address2
    );
    
    simnet.callPublicFn(
      "wizard-token",
      "transfer",
      [".wizard-game", 2000000],
      address2
    );
    
    simnet.callPublicFn(
      "wizard-game",
      "register-mana-transfer",
      [2000000],
      address2
    );
    
    const { result } = simnet.callPublicFn(
      "wizard-game",
      "spend-mana-for-xp",
      [5000000],
      address2
    );
    expect(result).toBeErr(18);
  });

  it("should increment unique wizards count", () => {
    simnet.callPublicFn(
      "wizard-game",
      "set-wizard-token",
      [".wizard-token"],
      address1
    );
    
    simnet.callPublicFn(
      "wizard-token",
      "claim",
      [],
      address2
    );
    
    simnet.callPublicFn(
      "wizard-token",
      "transfer",
      [".wizard-game", 2000000],
      address2
    );
    
    simnet.callPublicFn(
      "wizard-game",
      "register-mana-transfer",
      [2000000],
      address2
    );
    
    simnet.callPublicFn(
      "wizard-game",
      "spend-mana-for-xp",
      [2000000],
      address2
    );
    
    const { result } = simnet.callReadOnlyFn(
      "wizard-game",
      "get-total-unique-wizards",
      [],
      address1
    );
    expect(result).toBeUint(1);
  });

  it("should track multiple wizards", () => {
    simnet.callPublicFn(
      "wizard-game",
      "set-wizard-token",
      [".wizard-token"],
      address1
    );
    
    simnet.callPublicFn(
      "wizard-token",
      "claim",
      [],
      address2
    );
    
    simnet.callPublicFn(
      "wizard-token",
      "claim",
      [],
      address3
    );
    
    simnet.callPublicFn(
      "wizard-token",
      "transfer",
      [".wizard-game", 2000000],
      address2
    );
    
    simnet.callPublicFn(
      "wizard-token",
      "transfer",
      [".wizard-game", 2000000],
      address3
    );
    
    simnet.callPublicFn(
      "wizard-game",
      "register-mana-transfer",
      [2000000],
      address2
    );
    
    simnet.callPublicFn(
      "wizard-game",
      "register-mana-transfer",
      [2000000],
      address3
    );
    
    simnet.callPublicFn(
      "wizard-game",
      "spend-mana-for-xp",
      [2000000],
      address2
    );
    
    simnet.callPublicFn(
      "wizard-game",
      "spend-mana-for-xp",
      [2000000],
      address3
    );
    
    const { result } = simnet.callReadOnlyFn(
      "wizard-game",
      "get-total-unique-wizards",
      [],
      address1
    );
    expect(result).toBeUint(2);
  });
});
