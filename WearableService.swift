import CoreBluetooth
import Foundation

@MainActor
final class WearableService: NSObject, ObservableObject {
    @Published private(set) var connectionState: ConnectionState = .disconnected
    @Published private(set) var latestHeartRate: HeartRateReading?

    private var centralManager: CBCentralManager!

    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }

    func startScanning() {
        guard centralManager.state == .poweredOn else { return }
        connectionState = .scanning
        centralManager.scanForPeripherals(withServices: nil)
    }

    func stopScanning() {
        centralManager.stopScan()
        connectionState = .disconnected
    }

    // Vendor DAFIT/CRP and QRing adapters will publish normalized readings here.
    func publishHeartRate(_ bpm: Int, source: String) {
        latestHeartRate = HeartRateReading(beatsPerMinute: bpm, source: source)
    }
}

extension WearableService: CBCentralManagerDelegate {
    nonisolated func centralManagerDidUpdateState(_ central: CBCentralManager) {
        Task { @MainActor [weak self] in
            guard let self else { return }
            if central.state != .poweredOn {
                connectionState = .disconnected
            }
        }
    }
}
