import { describe, expect, it } from "vitest";

const accounts = simnet.getAccounts();
const address1 = accounts.get("wallet_1")!;

describe("simple-todo tests", () => {
  it("ensures simnet is well initialised", () => {
    expect(simnet.blockHeight).toBeDefined();
  });

  it("should start with zero unique users", () => {
    const { result } = simnet.callReadOnlyFn(
      "simple-todo",
      "get-total-unique-users",
      [],
      address1
    );
    expect(result).toBeUint(0);
  });

  it("should allow adding a task", () => {
    const { result } = simnet.callPublicFn(
      "simple-todo",
      "add-task",
      ['"Buy groceries"'],
      address1
    );
    expect(result).toBeOk(true);
  });

  it("should return task count after adding tasks", () => {
    simnet.callPublicFn(
      "simple-todo",
      "add-task",
      ['"Task 1"'],
      address1
    );
    
    const { result } = simnet.callReadOnlyFn(
      "simple-todo",
      "my-task-count",
      [],
      address1
    );
    expect(result).toBeUint(1);
  });
});
