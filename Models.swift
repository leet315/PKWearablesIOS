import Foundation

struct HeartRateReading: Codable, Identifiable {
    let id: UUID
    let beatsPerMinute: Int
    let source: String
    let recordedAt: Date

    init(
        id: UUID = UUID(),
        beatsPerMinute: Int,
        source: String,
        recordedAt: Date = .now
    ) {
        self.id = id
        self.beatsPerMinute = beatsPerMinute
        self.source = source
        self.recordedAt = recordedAt
    }
}

enum WearableType: String, Codable, CaseIterable, Identifiable {
    case watchC28 = "WATCH_C28"
    case strap = "STRAP"
    case ring = "RING"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .watchC28: return "C28 watch"
        case .strap: return "Chest strap"
        case .ring: return "Q-Ring"
        }
    }
}

enum ConnectionState: Equatable {
    case disconnected
    case scanning
    case connecting
    case connected

    var label: String {
        switch self {
        case .disconnected: return "Not connected"
        case .scanning: return "Scanning"
        case .connecting: return "Connecting"
        case .connected: return "Connected"
        }
    }
}

struct MemberProfile: Codable {
    let id: Int
    let name: String
    let email: String?
    let tier: String?
}
