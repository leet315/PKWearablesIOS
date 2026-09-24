import SwiftUI

@MainActor
final class DashboardViewModel: ObservableObject {
    @Published var selectedDevice: WearableType = .watchC28
    @Published var heartRate = HeartRateReading(
        beatsPerMinute: 72,
        source: "Preview"
    )
    @Published var wearableService = WearableService()

    var connectionState: ConnectionState {
        wearableService.connectionState
    }

    func toggleScanning() {
        if connectionState == .scanning {
            wearableService.stopScanning()
        } else {
            wearableService.startScanning()
        }
    }
}

struct DashboardView: View {
    @ObservedObject var viewModel: DashboardViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    header
                    heartRateCard
                    deviceCard
                }
                .padding(20)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("PK Wearables")
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Training today")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
            Text("Stay in your rhythm")
                .font(.largeTitle.weight(.bold))
        }
    }

    private var heartRateCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Heart rate", systemImage: "heart.fill")
                .font(.headline)
                .foregroundStyle(.red)
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text("\(viewModel.heartRate.beatsPerMinute)")
                    .font(.system(size: 56, weight: .bold, design: .rounded))
                Text("BPM")
                    .font(.headline)
                    .foregroundStyle(.secondary)
            }
            Text("Last reading from \(viewModel.heartRate.source)")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(.background, in: RoundedRectangle(cornerRadius: 18))
    }

    private var deviceCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Label("Wearable", systemImage: "wave.3.right")
                    .font(.headline)
                Spacer()
                Text(viewModel.connectionState.label)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(viewModel.connectionState == .connected ? .green : .secondary)
            }

            Picker("Device", selection: $viewModel.selectedDevice) {
                ForEach(WearableType.allCases) { device in
                    Text(device.displayName).tag(device)
                }
            }
            .pickerStyle(.menu)

            Button(viewModel.connectionState == .scanning ? "Stop scanning" : "Scan for devices") {
                viewModel.toggleScanning()
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(.background, in: RoundedRectangle(cornerRadius: 18))
    }
}

#Preview {
    DashboardView(viewModel: DashboardViewModel())
}
