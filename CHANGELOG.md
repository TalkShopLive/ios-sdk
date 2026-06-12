# Changelog

## [4.1.1] — 2026-05-26

### Critical fixes

**`MessagingTokenResponse` — `chat_id` never decoded (`Response.swift`)**  
`CodingKeys.chatId` had no raw value, so Swift mapped it to the string `"chatId"`. The Chat API returns `"chat_id"`. Every v2 session decoded `chatId = nil`.  
Fix: `case chatId = "chat_id"`.

**`MessagingTokenResponse` — force-unwrap crash on `userId` fallback (`Response.swift`)**  
The fallback `container.decodeIfPresent(String.self, forKey: CodingKeys(rawValue: "userId")!)` always crashed: `"userId"` is not a valid rawValue in the enum (the case uses rawValue `"user_id"`), so `CodingKeys(rawValue:)` returned `nil` and the `!` triggered `EXC_BAD_ACCESS`. Fired whenever `user_id` was absent from the response.  
Fix: removed the fallback; `.userId` already maps `"user_id"` correctly.

**`unlikeComment` v1 — `Optional(N)` in URL (`ChatProvider.swift`)**  
`eventId` is `Int?`. String-interpolating an Optional directly — `"\(eventId)"` — produces `"Optional(12345)"`. Every v1 unlike request built a broken URL and got a 404.  
Fix: guard-unwrap `eventId` before interpolation; return `SHOW_NOT_LIVE` if nil.

### Non-critical fixes

**v2 live subscribe silently dropped messages on metadata failure (`ChatProvider.swift`)**  
`fetchUserMetadata` `.failure` branch did `break` — message was never forwarded to the delegate. The v1 path already degraded gracefully (delivered message without full sender). v2 now matches.

**Stray unconditional `print(senderData.profileUrl)` in v2 history path (`ChatProvider.swift`)**  
Not behind `isDebugMode()`. Fired on every v2 history fetch in production, leaking profile URLs to the host app's console.  
Fix: removed.

**`getCurrentEvent()` deleted instead of deprecated (`ChatProvider.swift`)**  
Removed in the Chat 2.0 refactor — a breaking change for any consumer calling it. Re-added as `@available(*, deprecated)`.

**`channelName` not percent-encoded in v2 DELETE URLs (`Urls.swift`)**  
`deleteMessageV2` and `unlikeCommentV2` passed `channelName` raw into the query string. Android SDK already encoded this.  
Fix: `addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)`.

**Redundant JSON body on v2 DELETE calls (`Networking.swift`)**  
`deleteMessage` and `unlikeComment` sent a `V2MessagingTokenRequest` body on v2 paths. The Chat API DELETE endpoints use `@Query()` only — no `@Body()` decorator. Body was serialized, allocated, and transmitted for nothing.  
Fix: pass `nil`.

### Debug logging added

`MessagingTokenResponse.init(from:)` — logs to console (debug mode) when `user_id`, `chat_id`, or `token` decode as nil. Surfaces contract mismatches between SDK and API at decode time instead of silently propagating nil downstream.

`ChatProvider.unlikeComment` — logs when `eventId` is nil on a v1 show before failing.

`ChatProvider` v2 subscribe / history — logs `fetchUserMetadata` failures with the PubNub error description before degrading gracefully.

All new log lines follow the existing `Config.shared.isDebugMode()` gate and use the prefix `[TSL][ClassName]` for easy filtering.

**Chat init against empty/mismatched show picked wrong chat version (`ChatProvider.swift`, `ShowData.swift`)**  
Started with only a show key (no prior `Show.getDetails`), `ChatProvider` read the shared singleton `Show.shared.showData`, found an empty `ShowData()`, and ran the whole flow against it. An empty show decodes as `type = .legacy`, so the resolver picked v1 and issued v1 requests for v2 shows. Root cause: `ChatProvider` assumed the singleton already held the matching show, with no check on key match or emptiness.  
Fix: `init` now syncs state before initializing — if `showKey` differs from the cached key **or** the cached show is empty (`id == nil`), it refetches via `Show.shared.getDetails` (mismatched key after refetch → `SHOW_NOT_FOUND`; fetch failure forwards the actual error), otherwise proceeds directly. Added a prelive guard returning `SHOW_NOT_LIVE` when the show is `prelive`, backed by a new `ShowData.Status` enum (`prelive`/`live`/`vod`/`transcoding`) and `statusEnum` property.  
Follow-ups: keeps the singleton architecture (ideally `ChatProvider` would take the show as an injected dependency). The refetch is skipped on a key match, so a show cached while `prelive` and reused once live would still read the stale `prelive` status and fail with `SHOW_NOT_LIVE` — refetch on cached `prelive` if that matters.

---

## [4.1.0] — 2026-05-08

- PubNub SDK 9.3.5 → 10.1.5
- Xcode 26 / Swift 6.2.3 compatibility
- 29 new unit tests covering PubNub 10.x conversion surface
- No public API changes

## [4.0.0] — 2026-02-24

- Chat 2.0: federated user token flow via `POST /api/v1/tokens/federated-user`
- PubNub channel subscription from token response (no client-side construction)
- v2 DELETE endpoints for messages and message actions
- User metadata from PubNub directly for v2 shows
- Shoppettes module
