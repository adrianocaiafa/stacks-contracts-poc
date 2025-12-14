import { describe, expect, it } from "vitest";

const accounts = simnet.getAccounts();
const address1 = accounts.get("wallet_1")!;
const address2 = accounts.get("wallet_2")!;

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

  it("should return a task by id", () => {
    simnet.callPublicFn(
      "simple-todo",
      "add-task",
      ['"Complete project"'],
      address1
    );
    
    const { result } = simnet.callReadOnlyFn(
      "simple-todo",
      "my-task",
      [0],
      address1
    );
    expect(result).toBeSome();
    const task = result.value;
    expect(task.id).toBeUint(0);
    expect(task.text).toBe("Complete project");
    expect(task.done).toBe(false);
    expect(task.deleted).toBe(false);
  });

  it("should toggle task done status", () => {
    simnet.callPublicFn(
      "simple-todo",
      "add-task",
      ['"Toggle me"'],
      address1
    );
    
    const { result: toggleResult } = simnet.callPublicFn(
      "simple-todo",
      "toggle-done",
      [0],
      address1
    );
    expect(toggleResult).toBeOk(true);
    
    const { result: taskResult } = simnet.callReadOnlyFn(
      "simple-todo",
      "my-task",
      [0],
      address1
    );
    expect(taskResult).toBeSome();
    expect(taskResult.value.done).toBe(true);
  });

  it("should delete a task", () => {
    simnet.callPublicFn(
      "simple-todo",
      "add-task",
      ['"Delete me"'],
      address1
    );
    
    const { result: deleteResult } = simnet.callPublicFn(
      "simple-todo",
      "delete-task",
      [0],
      address1
    );
    expect(deleteResult).toBeOk(true);
    
    const { result: taskResult } = simnet.callReadOnlyFn(
      "simple-todo",
      "my-task",
      [0],
      address1
    );
    expect(taskResult).toBeSome();
    expect(taskResult.value.deleted).toBe(true);
  });

  it("should not allow toggling a deleted task", () => {
    simnet.callPublicFn(
      "simple-todo",
      "add-task",
      ['"Will be deleted"'],
      address1
    );
    
    simnet.callPublicFn(
      "simple-todo",
      "delete-task",
      [0],
      address1
    );
    
    const { result } = simnet.callPublicFn(
      "simple-todo",
      "toggle-done",
      [0],
      address1
    );
    expect(result).toBeErr(1);
  });

  it("should track multiple tasks per user", () => {
    simnet.callPublicFn(
      "simple-todo",
      "add-task",
      ['"Task 1"'],
      address1
    );
    
    simnet.callPublicFn(
      "simple-todo",
      "add-task",
      ['"Task 2"'],
      address1
    );
    
    simnet.callPublicFn(
      "simple-todo",
      "add-task",
      ['"Task 3"'],
      address1
    );
    
    const { result } = simnet.callReadOnlyFn(
      "simple-todo",
      "my-task-count",
      [],
      address1
    );
    expect(result).toBeUint(3);
  });

  it("should track tasks separately for different users", () => {
    simnet.callPublicFn(
      "simple-todo",
      "add-task",
      ['"User 1 task"'],
      address1
    );
    
    simnet.callPublicFn(
      "simple-todo",
      "add-task",
      ['"User 2 task"'],
      address2
    );
    
    const { result: count1 } = simnet.callReadOnlyFn(
      "simple-todo",
      "get-task-count",
      [address1],
      address1
    );
    expect(count1).toBeUint(1);
    
    const { result: count2 } = simnet.callReadOnlyFn(
      "simple-todo",
      "get-task-count",
      [address2],
      address1
    );
    expect(count2).toBeUint(1);
  });

  it("should increment unique users count", () => {
    simnet.callPublicFn(
      "simple-todo",
      "add-task",
      ['"Test"'],
      address1
    );
    
    const { result } = simnet.callReadOnlyFn(
      "simple-todo",
      "get-total-unique-users",
      [],
      address1
    );
    expect(result).toBeUint(1);
  });

  it("should increment interactions count", () => {
    simnet.callPublicFn(
      "simple-todo",
      "add-task",
      ['"First"'],
      address1
    );
    
    simnet.callPublicFn(
      "simple-todo",
      "add-task",
      ['"Second"'],
      address1
    );
    
    simnet.callPublicFn(
      "simple-todo",
      "toggle-done",
      [0],
      address1
    );
    
    const { result } = simnet.callReadOnlyFn(
      "simple-todo",
      "my-interactions",
      [],
      address1
    );
    expect(result).toBeUint(3);
  });
});
