//
//  VideoViewSource.swift
//
//
//  Created by TalkShopLive on 2026-10-13.
//

import Foundation

// MARK: - VideoViewSource

/// The show and stream currently loaded in the host app's player.
///
/// Pass it to `VideoViewTracker.onSourceChanged(_:)` when the player loads a stream,
/// and again every time the show status is refreshed.
public struct VideoViewSource: Equatable {

    // MARK: - VideoStatus

    /// The show phase reported as `meta.video_status`.
    public enum VideoStatus: String, Equatable {
        case prelive
        case live
        case vod

        /// Maps a raw show state to a reportable status:
        /// `prelive` / `draft` -> `.prelive`, `live` / `transcoding` -> `.live`, `vod` -> `.vod`.
        /// Returns nil for any other value.
        public init?(normalizing raw: String?) {
            switch raw?.lowercased() {
            case "prelive", "draft":
                self = .prelive
            case "live", "transcoding":
                self = .live
            case "vod":
                self = .vod
            default:
                return nil
            }
        }
    }

    // MARK: - Properties

    public let showId: Int // meta.show_id
    public let showKey: String // meta.streaming_content_key
    public let eventId: Int? // meta.event_id
    public let storeId: Int? // meta.store_id
    public let videoStatus: VideoStatus // meta.video_status
    public let playbackURL: URL? // Identifies the stream; never sent.
    public let title: String? // page_metrics.page_title

    // MARK: - Initializers

    init(showId: Int,
         showKey: String,
         eventId: Int? = nil,
         storeId: Int? = nil,
         videoStatus: VideoStatus,
         playbackURL: URL? = nil,
         title: String? = nil)
    {
        self.showId = showId
        self.showKey = showKey
        self.eventId = eventId
        self.storeId = storeId
        self.videoStatus = videoStatus
        self.playbackURL = playbackURL
        self.title = title
    }

    /// Creates a source from the show details and, optionally, the latest show status.
    ///
    /// Returns nil when the show has no id or key, or its status is not prelive / live / vod.
    /// The stream is chosen the same way as on web: prelive -> `trailerUrl`,
    /// live -> `hlsPlaybackUrl`, vod -> `hlsUrl`.
    /// - Parameters:
    ///   - show: The show details from `Show.getDetails`.
    ///   - event: The latest status from `Show.getStatus`. Its state wins over `show.status`.
    public init?(show: ShowData, event: EventData? = nil) {
        guard let showId = show.id,
              let showKey = show.showKey,
              let videoStatus = VideoStatus(normalizing: event?.status ?? show.status) else {
            return nil
        }

        let urlString: String?
        switch videoStatus {
        case .prelive:
            urlString = show.trailerUrl
        case .live:
            urlString = show.hlsPlaybackUrl
        case .vod:
            urlString = show.hlsUrl
        }

        self.init(showId: showId,
                  showKey: showKey,
                  eventId: show.liveAssetId,
                  storeId: show.channelId,
                  videoStatus: videoStatus,
                  playbackURL: urlString.flatMap { URL(string: $0) },
                  title: show.name)
    }

    // MARK: - Play Identity

    /// Whether `other` belongs to the same play: same show, same phase and same stream.
    ///
    /// Streams are compared by scheme, host and path, so query tokens do not matter.
    /// A missing URL on either side matches any URL.
    func isSamePlay(as other: VideoViewSource) -> Bool {
        guard showId == other.showId, videoStatus == other.videoStatus else {
            return false
        }
        guard let lhs = playbackURL, let rhs = other.playbackURL else {
            return true
        }
        return Self.streamIdentity(lhs) == Self.streamIdentity(rhs)
    }

    private static func streamIdentity(_ url: URL) -> String {
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        let scheme = components?.scheme?.lowercased() ?? ""
        let host = components?.host?.lowercased() ?? ""
        let path = components?.path ?? url.path
        return "\(scheme)://\(host)\(path)"
    }
}
