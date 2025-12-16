import { describe, expect, it } from "vitest";

const accounts = simnet.getAccounts();
const address1 = accounts.get("wallet_1")!;

describe("simple-leaderboard tests", () => {
  it("ensures simnet is well initialised", () => {
    expect(simnet.blockHeight).toBeDefined();
  });

  it("should start with zero unique users", () => {
    const { result } = simnet.callReadOnlyFn(
      "simple-leaderboard",
      "get-total-unique-users",
      [],
      address1
    );
    expect(result).toBeUint(0);
  });

  it("should start with zero points", () => {
    const { result } = simnet.callReadOnlyFn(
      "simple-leaderboard",
      "my-points",
      [],
      address1
    );
    expect(result).toBeUint(0);
  });

  it("should allow gaining points", () => {
    const { result } = simnet.callPublicFn(
      "simple-leaderboard",
      "gain-points",
      [100],
      address1
    );
    expect(result).toBeOk(true);
  });

  it("should return points after gaining them", () => {
    simnet.callPublicFn(
      "simple-leaderboard",
      "gain-points",
      [50],
      address1
    );
    
    const { result } = simnet.callReadOnlyFn(
      "simple-leaderboard",
      "my-points",
      [],
      address1
    );
    expect(result).toBeUint(50);
  });

  it("should accumulate points", () => {
    simnet.callPublicFn(
      "simple-leaderboard",
      "gain-points",
      [30],
      address1
    );
    
    simnet.callPublicFn(
      "simple-leaderboard",
      "gain-points",
      [20],
      address1
    );
    
    const { result } = simnet.callReadOnlyFn(
      "simple-leaderboard",
      "my-points",
      [],
      address1
    );
    expect(result).toBeUint(50);
  });

  it("should not allow gaining zero points", () => {
    const { result } = simnet.callPublicFn(
      "simple-leaderboard",
      "gain-points",
      [0],
      address1
    );
    expect(result).toBeErr(1);
  });

  it("should increment unique users count", () => {
    simnet.callPublicFn(
      "simple-leaderboard",
      "gain-points",
      [10],
      address1
    );
    
    const { result } = simnet.callReadOnlyFn(
      "simple-leaderboard",
      "get-total-unique-users",
      [],
      address1
    );
    expect(result).toBeUint(1);
  });

  it("should add user to participants list", () => {
    simnet.callPublicFn(
      "simple-leaderboard",
      "gain-points",
      [25],
      address1
    );
    
    const { result } = simnet.callReadOnlyFn(
      "simple-leaderboard",
      "get-participants-count",
      [],
      address1
    );
    expect(result).toBeUint(1);
  });
});
