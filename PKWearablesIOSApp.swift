import SwiftUI

@main
struct PKWearablesIOSApp: App {
    @StateObject private var dashboard = DashboardViewModel()

    var body: some Scene {
        WindowGroup {
            DashboardView(viewModel: dashboard)
        }
    }
}
