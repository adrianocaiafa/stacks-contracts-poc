import { describe, expect, it } from "vitest";

const accounts = simnet.getAccounts();
const address1 = accounts.get("wallet_1")!;

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
});
