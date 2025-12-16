import { describe, expect, it } from "vitest";

const accounts = simnet.getAccounts();
const address1 = accounts.get("wallet_1")!;
const address2 = accounts.get("wallet_2")!;
const address3 = accounts.get("wallet_3")!;

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

  it("should allow duel between users", () => {
    simnet.callPublicFn(
      "simple-leaderboard",
      "gain-points",
      [100],
      address1
    );
    
    simnet.callPublicFn(
      "simple-leaderboard",
      "gain-points",
      [50],
      address2
    );
    
    const { result } = simnet.callPublicFn(
      "simple-leaderboard",
      "duel",
      [address2, 10],
      address1
    );
    expect(result).toBeOk(true);
  });

  it("should transfer points correctly in duel (winner gains, loser loses)", () => {
    simnet.callPublicFn(
      "simple-leaderboard",
      "gain-points",
      [100],
      address1
    );
    
    simnet.callPublicFn(
      "simple-leaderboard",
      "gain-points",
      [50],
      address2
    );
    
    simnet.callPublicFn(
      "simple-leaderboard",
      "duel",
      [address2, 20],
      address1
    );
    
    const { result: points1 } = simnet.callReadOnlyFn(
      "simple-leaderboard",
      "get-points",
      [address1],
      address1
    );
    expect(points1).toBeUint(120);
    
    const { result: points2 } = simnet.callReadOnlyFn(
      "simple-leaderboard",
      "get-points",
      [address2],
      address1
    );
    expect(points2).toBeUint(30);
  });

  it("should handle duel when opponent has more points", () => {
    simnet.callPublicFn(
      "simple-leaderboard",
      "gain-points",
      [50],
      address1
    );
    
    simnet.callPublicFn(
      "simple-leaderboard",
      "gain-points",
      [100],
      address2
    );
    
    simnet.callPublicFn(
      "simple-leaderboard",
      "duel",
      [address2, 15],
      address1
    );
    
    const { result: points1 } = simnet.callReadOnlyFn(
      "simple-leaderboard",
      "get-points",
      [address1],
      address1
    );
    expect(points1).toBeUint(35);
    
    const { result: points2 } = simnet.callReadOnlyFn(
      "simple-leaderboard",
      "get-points",
      [address2],
      address1
    );
    expect(points2).toBeUint(115);
  });

  it("should not allow duel with yourself", () => {
    simnet.callPublicFn(
      "simple-leaderboard",
      "gain-points",
      [100],
      address1
    );
    
    const { result } = simnet.callPublicFn(
      "simple-leaderboard",
      "duel",
      [address1, 10],
      address1
    );
    expect(result).toBeErr(3);
  });

  it("should not allow duel without enough points", () => {
    simnet.callPublicFn(
      "simple-leaderboard",
      "gain-points",
      [50],
      address1
    );
    
    simnet.callPublicFn(
      "simple-leaderboard",
      "gain-points",
      [30],
      address2
    );
    
    const { result } = simnet.callPublicFn(
      "simple-leaderboard",
      "duel",
      [address2, 100],
      address1
    );
    expect(result).toBeErr(4);
  });

  it("should handle tie in duel (no points transfer)", () => {
    simnet.callPublicFn(
      "simple-leaderboard",
      "gain-points",
      [100],
      address1
    );
    
    simnet.callPublicFn(
      "simple-leaderboard",
      "gain-points",
      [100],
      address2
    );
    
    const { result } = simnet.callPublicFn(
      "simple-leaderboard",
      "duel",
      [address2, 10],
      address1
    );
    expect(result).toBeOk(true);
    
    const { result: points1 } = simnet.callReadOnlyFn(
      "simple-leaderboard",
      "get-points",
      [address1],
      address1
    );
    expect(points1).toBeUint(100);
    
    const { result: points2 } = simnet.callReadOnlyFn(
      "simple-leaderboard",
      "get-points",
      [address2],
      address1
    );
    expect(points2).toBeUint(100);
  });

  it("should track multiple participants", () => {
    simnet.callPublicFn(
      "simple-leaderboard",
      "gain-points",
      [100],
      address1
    );
    
    simnet.callPublicFn(
      "simple-leaderboard",
      "gain-points",
      [200],
      address2
    );
    
    simnet.callPublicFn(
      "simple-leaderboard",
      "gain-points",
      [150],
      address3
    );
    
    const { result } = simnet.callReadOnlyFn(
      "simple-leaderboard",
      "get-participants-count",
      [],
      address1
    );
    expect(result).toBeUint(3);
  });

  it("should return participant by index", () => {
    simnet.callPublicFn(
      "simple-leaderboard",
      "gain-points",
      [100],
      address1
    );
    
    const { result } = simnet.callReadOnlyFn(
      "simple-leaderboard",
      "get-participant",
      [0],
      address1
    );
    expect(result).toBeSome(address1);
  });

  it("should return participant with points", () => {
    simnet.callPublicFn(
      "simple-leaderboard",
      "gain-points",
      [250],
      address1
    );
    
    const { result } = simnet.callReadOnlyFn(
      "simple-leaderboard",
      "get-participant-with-points",
      [0],
      address1
    );
    expect(result).toBeSome();
    expect(result.value.user).toBePrincipal(address1);
    expect(result.value.points).toBeUint(250);
  });

  it("should increment interactions count", () => {
    simnet.callPublicFn(
      "simple-leaderboard",
      "gain-points",
      [10],
      address1
    );
    
    simnet.callPublicFn(
      "simple-leaderboard",
      "gain-points",
      [20],
      address1
    );
    
    simnet.callPublicFn(
      "simple-leaderboard",
      "duel",
      [address2, 5],
      address1
    );
    
    const { result } = simnet.callReadOnlyFn(
      "simple-leaderboard",
      "my-interactions",
      [],
      address1
    );
    expect(result).toBeUint(3);
  });

  it("should check if user has interacted", () => {
    const { result: before } = simnet.callReadOnlyFn(
      "simple-leaderboard",
      "has-user-interacted",
      [address1],
      address1
    );
    expect(before).toBeBool(false);
    
    simnet.callPublicFn(
      "simple-leaderboard",
      "gain-points",
      [10],
      address1
    );
    
    const { result: after } = simnet.callReadOnlyFn(
      "simple-leaderboard",
      "has-user-interacted",
      [address1],
      address1
    );
    expect(after).toBeBool(true);
  });
});
