# Xcode 26 — Compatibility Notes

**Last updated:** 2026-05-01

This document captures what we learned while modernizing the SDK's PubNub dependency for Xcode 26 and addressing a coverage-reporting issue surfaced by a third-party CI consumer.

## TL;DR

- The SDK is **Xcode 26 compatible** with no source changes.
- PubNubSDK was bumped from `9.3.5` → `10.1.5` in this release as a **maintenance modernization**, not as a bug fix.
- A third-party consumer reported empty `.xcresult` code-coverage data under Xcode 26 with the SDK linked. **Root cause is upstream Apple bug FB7724987** at the Xcode + SwiftPM layer, not in this SDK or in PubNub. Section "Coverage reporting under Xcode 26" below explains the workaround.

## What we know

| Statement | Status |
|---|---|
| The PubNub `9.3.5 → 10.1.5` bump compiles cleanly under Xcode 26.2 | ✅ Verified — `swift build` clean |
| The bump does not regress the SDK's public surface | ✅ Verified — public API unchanged; legacy `SubscriptionListener` still works alongside the modern `Subscription` API |
| The bump introduces no new breaking changes for SDK consumers | ✅ Verified — see "Public API impact" below |
| 29 new isolated unit tests covering the PubNub-typed conversion surface (`MessageBase.init(pubNubMessage:)`, `MessageAction(action:)`, `MessagePage(page:)`) all pass | ✅ Verified — `MessageData.swift` line coverage 0% → 79.31% |
| The bump fixes the third-party CI consumer's empty-coverage symptom | ❌ **Not** verified. The diff between PubNub `9.3.5` and `10.1.5` `Package.swift` is one test-target `path` field; SPM coverage instrumentation is derived from the manifest, which is causally inert across this bump. |
| The empty-coverage symptom is a PubNub or TSL SDK bug | ❌ **No** — it's Apple FB7724987, surfaced when a consumer scheme uses "Gather coverage for specific targets" with any SwiftPM-linked dependency in the graph. Predates Xcode 26. |

## What we don't know

- The exact Xcode patch version, iOS Simulator runtime version, scheme coverage-scope setting, and target structure in the third-party CI environment that originated the report. Those details determine whether FB7724987 is the exact match in their case or whether something else is at play.

## Coverage reporting under Xcode 26

### The symptom

Under Xcode 26, `xcodebuild test -enableCodeCoverage YES` produces an `.xcresult` bundle without coverage data when the consuming scheme is set to "Gather coverage for specific targets" and has SwiftPM dependencies in the graph (including this SDK, since it transitively links `PubNubSDK`). Removing `PubNubSDK` from the dependency graph causes coverage to populate again — because removing any SPM dependency removes the scope-conflict trigger.

### The cause (upstream, unresolved)

Apple Feedback **FB7724987**. Discussed on the Swift Forums:
[Xcode doesn't gather code coverage from packages when set to "some targets"](https://forums.swift.org/t/xcode-doesnt-gather-code-coverage-from-packages-when-set-to-some-targets/37220).

The bug class predates Xcode 26 and is unresolved as of this writing. It's not in PubNubSDK, not in TalkShopLive's iOS SDK, and not specific to Xcode 26 — Xcode 26 just makes it more visible because more SDK consumers are now noticing the empty coverage data.

### What to do in your project

Two consumer-side workarounds, **independent of any SDK update**:

1. **Switch coverage scope to "All targets," post-process.** In your scheme: Edit Scheme → Test → Options → Code Coverage → **Gather coverage for "All targets"**. Then post-process the `.xcresult` if you need to exclude SDK dependencies from your reporting totals:
   ```bash
   xcrun xccov view --report --json out.xcresult \
     | jq '{targets: [.targets[] | select(.name | startswith("PubNub") | not)]}' \
     > coverage.json
   ```
   Bypasses FB7724987 with no code change.

2. **Vendor `PubNubSDK` as a binary `.xcframework`** instead of consuming it via SwiftPM. Heavier (you lose SPM auto-update flow), but eliminates the SPM coverage scope-bug trigger entirely.

Neither is provided by an SDK update; both are project-configuration decisions on the consumer's side.

### What this release does NOT do

This SDK release **does not include** a fix for FB7724987 because no SDK release can. The bug is at the Xcode + SwiftPM layer, not in the dependency.

If your CI is hitting the symptom: apply one of the two workarounds above. If you need help diagnosing whether your case matches FB7724987 or is something else, please open an issue with the following:

- `xcodebuild -version` output
- `xcrun simctl runtime list` from your CI runner
- Your `.xcscheme` file (or a screenshot of scheme → Test → Options → Code Coverage)
- Your full `xcodebuild test` invocation
- Your `Package.resolved`
- A sketch of your app's target structure and how the SDK is linked into each target

## Public API impact of the PubNub `9.3.5 → 10.1.5` bump

**None.** The TSL Swift SDK's public surface is unchanged. Three potential PubNub 10.0 breaking changes were considered; none affect this SDK's code:

| PubNub 10.0 breaking change | Used in this SDK's `Sources/`? |
|---|---|
| `LogWriter` protocol refactor | No |
| `hereNow` capped at 1,000 occupants | No call sites |
| MPNS push notifications removed | No MPNS / push registration |

`Sources/Talkshoplive/Core/Chat/ChatProvider.swift` uses the legacy `SubscriptionListener(queue:)` + `pubnub.add(listener)` pattern. PubNub 10.1.5 retains this API alongside the modern entity-scoped `pubnub.channel("x").subscription()` pattern. Migration to the modern API is tracked separately and not blocking on this release.

## Toolchain requirement

`swift-tools-version: 5.9` and `swiftLanguageVersions: [.v5]` — **unchanged** in this release. Deployment targets (`.iOS(.v13)`, `.macOS(.v10_15)`) — unchanged. No new Xcode minimum introduced by this SDK's manifest.

## Validation evidence summary

| Check | Result |
|-------|--------|
| `swift build` (Xcode 26.2 / Swift 6.2.3, manifest at swift-tools 5.9) | ✅ Clean compile |
| `swift test --filter PubNub10MigrationTests` | ✅ 29 / 29 pass |
| `xcodebuild test -enableCodeCoverage YES` against the sample app on Xcode 26.2 + iOS Simulator 26.3.1 | ✅ `** TEST SUCCEEDED **`, `.xcresult` coverage **present** for the app target (8.09%, 400 of 4942 lines). Both PubNub `9.3.5` and `10.1.5` produce **byte-for-byte identical** `.xcresult` data — confirming the bump is causally inert for SPM coverage instrumentation. |
| Pre-existing 7 backend integration tests (`SHOW_NOT_FOUND`, `AUTHENTICATION_EXCEPTION`) | Pre-existing on `development`; unrelated to PubNub; no regression. |

## Reference

- Apple Feedback FB7724987 → [Swift Forums thread](https://forums.swift.org/t/xcode-doesnt-gather-code-coverage-from-packages-when-set-to-some-targets/37220)
- PubNub Swift SDK releases → https://github.com/pubnub/swift/releases
- This SDK's PubNub bump → PR #139
