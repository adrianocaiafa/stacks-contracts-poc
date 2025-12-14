import { describe, expect, it } from "vitest";

const accounts = simnet.getAccounts();
const address1 = accounts.get("wallet_1")!;
const address2 = accounts.get("wallet_2")!;

describe("simple-status tests", () => {
  it("ensures simnet is well initialised", () => {
    expect(simnet.blockHeight).toBeDefined();
  });

  it("should start with zero unique users", () => {
    const { result } = simnet.callReadOnlyFn(
      "simple-status",
      "get-total-unique-users",
      [],
      address1
    );
    expect(result).toBeUint(0);
  });

  it("should allow setting a status", () => {
    const { result } = simnet.callPublicFn(
      "simple-status",
      "set-status",
      ['"Hello, world!"'],
      address1
    );
    expect(result).toBeOk(true);
  });

  it("should return the status after setting it", () => {
    simnet.callPublicFn(
      "simple-status",
      "set-status",
      ['"My status message"'],
      address1
    );
    
    const { result } = simnet.callReadOnlyFn(
      "simple-status",
      "my-status",
      [],
      address1
    );
    expect(result).toBeSome("My status message");
  });

  it("should increment unique users count", () => {
    simnet.callPublicFn(
      "simple-status",
      "set-status",
      ['"Test status"'],
      address1
    );
    
    const { result } = simnet.callReadOnlyFn(
      "simple-status",
      "get-total-unique-users",
      [],
      address1
    );
    expect(result).toBeUint(1);
  });

  it("should increment interactions count", () => {
    simnet.callPublicFn(
      "simple-status",
      "set-status",
      ['"First interaction"'],
      address1
    );
    
    const { result } = simnet.callReadOnlyFn(
      "simple-status",
      "my-interactions",
      [],
      address1
    );
    expect(result).toBeUint(1);
  });

  it("should allow clearing status", () => {
    simnet.callPublicFn(
      "simple-status",
      "set-status",
      ['"Temporary status"'],
      address1
    );
    
    const { result } = simnet.callPublicFn(
      "simple-status",
      "clear-status",
      [],
      address1
    );
    expect(result).toBeOk(true);
    
    const { result: statusResult } = simnet.callReadOnlyFn(
      "simple-status",
      "my-status",
      [],
      address1
    );
    expect(statusResult).toBeNone();
  });

  it("should track multiple users separately", () => {
    simnet.callPublicFn(
      "simple-status",
      "set-status",
      ['"User 1 status"'],
      address1
    );
    
    simnet.callPublicFn(
      "simple-status",
      "set-status",
      ['"User 2 status"'],
      address2
    );
    
    const { result: totalUsers } = simnet.callReadOnlyFn(
      "simple-status",
      "get-total-unique-users",
      [],
      address1
    );
    expect(totalUsers).toBeUint(2);
    
    const { result: status1 } = simnet.callReadOnlyFn(
      "simple-status",
      "get-status",
      [address1],
      address1
    );
    expect(status1).toBeSome("User 1 status");
    
    const { result: status2 } = simnet.callReadOnlyFn(
      "simple-status",
      "get-status",
      [address2],
      address1
    );
    expect(status2).toBeSome("User 2 status");
  });

  it("should update status when setting a new one", () => {
    simnet.callPublicFn(
      "simple-status",
      "set-status",
      ['"Old status"'],
      address1
    );
    
    simnet.callPublicFn(
      "simple-status",
      "set-status",
      ['"New status"'],
      address1
    );
    
    const { result } = simnet.callReadOnlyFn(
      "simple-status",
      "my-status",
      [],
      address1
    );
    expect(result).toBeSome("New status");
  });

  it("should increment interactions on multiple calls", () => {
    simnet.callPublicFn(
      "simple-status",
      "set-status",
      ['"First"'],
      address1
    );
    
    simnet.callPublicFn(
      "simple-status",
      "set-status",
      ['"Second"'],
      address1
    );
    
    simnet.callPublicFn(
      "simple-status",
      "clear-status",
      [],
      address1
    );
    
    const { result } = simnet.callReadOnlyFn(
      "simple-status",
      "my-interactions",
      [],
      address1
    );
    expect(result).toBeUint(3);
  });

  it("should check if user has interacted", () => {
    const { result: before } = simnet.callReadOnlyFn(
      "simple-status",
      "has-user-interacted",
      [address1],
      address1
    );
    expect(before).toBeBool(false);
    
    simnet.callPublicFn(
      "simple-status",
      "set-status",
      ['"Test"'],
      address1
    );
    
    const { result: after } = simnet.callReadOnlyFn(
      "simple-status",
      "has-user-interacted",
      [address1],
      address1
    );
    expect(after).toBeBool(true);
  });
});
