import { describe, expect, it } from "vitest";

const accounts = simnet.getAccounts();
const address1 = accounts.get("wallet_1")!;
const address2 = accounts.get("wallet_2")!;

describe("simple-bookmarks tests", () => {
  it("ensures simnet is well initialised", () => {
    expect(simnet.blockHeight).toBeDefined();
  });

  it("should start with zero unique users", () => {
    const { result } = simnet.callReadOnlyFn(
      "simple-bookmarks",
      "get-total-unique-users",
      [],
      address1
    );
    expect(result).toBeUint(0);
  });

  it("should return none for unset bookmark", () => {
    const { result } = simnet.callReadOnlyFn(
      "simple-bookmarks",
      "my-bookmark",
      [],
      address1
    );
    expect(result).toBeNone();
  });

  it("should allow saving a bookmark", () => {
    const { result } = simnet.callPublicFn(
      "simple-bookmarks",
      "save-bookmark",
      ['"https://example.com"'],
      address1
    );
    expect(result).toBeOk(true);
  });

  it("should return bookmark after saving it", () => {
    simnet.callPublicFn(
      "simple-bookmarks",
      "save-bookmark",
      ['"https://stacks.co"'],
      address1
    );
    
    const { result } = simnet.callReadOnlyFn(
      "simple-bookmarks",
      "my-bookmark",
      [],
      address1
    );
    expect(result).toBeSome("https://stacks.co");
  });

  it("should allow updating a bookmark", () => {
    simnet.callPublicFn(
      "simple-bookmarks",
      "save-bookmark",
      ['"https://old-url.com"'],
      address1
    );
    
    simnet.callPublicFn(
      "simple-bookmarks",
      "save-bookmark",
      ['"https://new-url.com"'],
      address1
    );
    
    const { result } = simnet.callReadOnlyFn(
      "simple-bookmarks",
      "my-bookmark",
      [],
      address1
    );
    expect(result).toBeSome("https://new-url.com");
  });

  it("should allow clearing a bookmark", () => {
    simnet.callPublicFn(
      "simple-bookmarks",
      "save-bookmark",
      ['"https://to-delete.com"'],
      address1
    );
    
    const { result: clearResult } = simnet.callPublicFn(
      "simple-bookmarks",
      "clear-bookmark",
      [],
      address1
    );
    expect(clearResult).toBeOk(true);
    
    const { result: bookmarkResult } = simnet.callReadOnlyFn(
      "simple-bookmarks",
      "my-bookmark",
      [],
      address1
    );
    expect(bookmarkResult).toBeNone();
  });

  it("should track bookmarks separately for different users", () => {
    simnet.callPublicFn(
      "simple-bookmarks",
      "save-bookmark",
      ['"https://user1.com"'],
      address1
    );
    
    simnet.callPublicFn(
      "simple-bookmarks",
      "save-bookmark",
      ['"https://user2.com"'],
      address2
    );
    
    const { result: bookmark1 } = simnet.callReadOnlyFn(
      "simple-bookmarks",
      "get-bookmark",
      [address1],
      address1
    );
    expect(bookmark1).toBeSome("https://user1.com");
    
    const { result: bookmark2 } = simnet.callReadOnlyFn(
      "simple-bookmarks",
      "get-bookmark",
      [address2],
      address1
    );
    expect(bookmark2).toBeSome("https://user2.com");
  });

  it("should increment unique users count", () => {
    simnet.callPublicFn(
      "simple-bookmarks",
      "save-bookmark",
      ['"https://test.com"'],
      address1
    );
    
    const { result } = simnet.callReadOnlyFn(
      "simple-bookmarks",
      "get-total-unique-users",
      [],
      address1
    );
    expect(result).toBeUint(1);
  });

  it("should increment interactions count", () => {
    simnet.callPublicFn(
      "simple-bookmarks",
      "save-bookmark",
      ['"https://first.com"'],
      address1
    );
    
    simnet.callPublicFn(
      "simple-bookmarks",
      "save-bookmark",
      ['"https://second.com"'],
      address1
    );
    
    simnet.callPublicFn(
      "simple-bookmarks",
      "clear-bookmark",
      [],
      address1
    );
    
    const { result } = simnet.callReadOnlyFn(
      "simple-bookmarks",
      "my-interactions",
      [],
      address1
    );
    expect(result).toBeUint(3);
  });

  it("should check if user has interacted", () => {
    const { result: before } = simnet.callReadOnlyFn(
      "simple-bookmarks",
      "has-user-interacted",
      [address1],
      address1
    );
    expect(before).toBeBool(false);
    
    simnet.callPublicFn(
      "simple-bookmarks",
      "save-bookmark",
      ['"https://test.com"'],
      address1
    );
    
    const { result: after } = simnet.callReadOnlyFn(
      "simple-bookmarks",
      "has-user-interacted",
      [address1],
      address1
    );
    expect(after).toBeBool(true);
  });

  it("should handle different types of bookmarks", () => {
    simnet.callPublicFn(
      "simple-bookmarks",
      "save-bookmark",
      ['"https://example.com/page"'],
      address1
    );
    
    simnet.callPublicFn(
      "simple-bookmarks",
      "save-bookmark",
      ['"@username"'],
      address1
    );
    
    simnet.callPublicFn(
      "simple-bookmarks",
      "save-bookmark",
      ['"0x1234567890abcdef"'],
      address1
    );
    
    const { result } = simnet.callReadOnlyFn(
      "simple-bookmarks",
      "my-bookmark",
      [],
      address1
    );
    expect(result).toBeSome("0x1234567890abcdef");
  });

  it("should allow clearing and saving again", () => {
    simnet.callPublicFn(
      "simple-bookmarks",
      "save-bookmark",
      ['"https://first.com"'],
      address1
    );
    
    simnet.callPublicFn(
      "simple-bookmarks",
      "clear-bookmark",
      [],
      address1
    );
    
    simnet.callPublicFn(
      "simple-bookmarks",
      "save-bookmark",
      ['"https://second.com"'],
      address1
    );
    
    const { result } = simnet.callReadOnlyFn(
      "simple-bookmarks",
      "my-bookmark",
      [],
      address1
    );
    expect(result).toBeSome("https://second.com");
  });
});
