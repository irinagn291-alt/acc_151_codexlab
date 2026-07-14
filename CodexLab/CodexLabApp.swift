import SwiftUI

struct CodexLabRootView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @State private var factory = CodexLabFactory.shared
    @State private var coordinator = CodexLabFactory.shared.makeCoordinator()
    @State private var showOnboarding = !UserDefaults.standard.bool(forKey: "codexlab.onboarded.v1")

    var body: some View {
        Group {
            if horizontalSizeClass == .regular {
                splitWorkspace
            } else {
                stackWorkspace
            }
        }
        .tint(LabTheme.brass)
        .labScreenStyle()
        .task { await factory.bootstrap() }
        .fullScreenCover(item: $coordinator.presentedSheet) { route in
            if case .scanner = route {
                CodexLabScannerView { isbn in
                    Task {
                        _ = try? await factory.addBookUseCase.execute(isbn: isbn)
                        coordinator.dismissSheet()
                    }
                }
            }
        }
        .sheet(isPresented: $coordinator.showSettings) {
            CodexLabSettingsView()
        }
        .fullScreenCover(isPresented: $showOnboarding) {
            CodexLabOnboardingView(isPresented: $showOnboarding)
        }
    }

    private var splitWorkspace: some View {
        NavigationSplitView(columnVisibility: $coordinator.columnVisibility) {
            NavigationStack(path: $coordinator.path) {
                PeriodicTableCanvasView(coordinator: coordinator)
                    .navigationDestination(for: CodexLabRoute.self) { routeDestination($0) }
            }
        } detail: {
            NavigationStack {
                if coordinator.selectedBookID != nil {
                    LaboratoryWorkspaceView(coordinator: coordinator)
                } else {
                    VStack(spacing: 12) {
                        Text("Codex Lab")
                            .font(LabTheme.display)
                            .foregroundStyle(LabTheme.brass)
                        Text("Select an element cell, then a specimen.")
                            .font(LabTheme.serif)
                            .foregroundStyle(LabTheme.label.opacity(0.75))
                        GaugeMeter(value: 0.35, title: "Standby", unit: "%")
                    }
                    .padding()
                    .labScreenStyle()
                }
            }
        }
    }

    private var stackWorkspace: some View {
        NavigationStack(path: $coordinator.path) {
            PeriodicTableCanvasView(coordinator: coordinator)
                .navigationDestination(for: CodexLabRoute.self) { routeDestination($0) }
        }
    }

    @ViewBuilder
    private func routeDestination(_ route: CodexLabRoute) -> some View {
        switch route {
        case .laboratoryWorkspace:
            LaboratoryWorkspaceView(coordinator: coordinator)
        case .experimentLog:
            ExperimentLogTimelineView()
        case .alchemyBench:
            AlchemyBenchView()
        case .periodicTable, .specimenDrawer, .scanner, .settings:
            EmptyView()
        }
    }
}

@main
struct CodexLabApp: App {
    var body: some Scene {
        WindowGroup {
            CodexLabRootView()
        }
    }
}
