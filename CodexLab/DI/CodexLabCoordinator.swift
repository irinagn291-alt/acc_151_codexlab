import SwiftUI

enum CodexLabRoute: Hashable, Identifiable {
    case periodicTable
    case specimenDrawer(UUID)
    case laboratoryWorkspace
    case experimentLog
    case alchemyBench
    case scanner
    case settings

    var id: String {
        switch self {
        case .periodicTable: "periodicTable"
        case .specimenDrawer(let id): "specimenDrawer-\(id.uuidString)"
        case .laboratoryWorkspace: "laboratoryWorkspace"
        case .experimentLog: "experimentLog"
        case .alchemyBench: "alchemyBench"
        case .scanner: "scanner"
        case .settings: "settings"
        }
    }
}

@Observable
@MainActor
final class CodexLabCoordinator {
    var path = NavigationPath()
    var selectedElementID: UUID?
    var selectedBookID: UUID?
    var columnVisibility: NavigationSplitViewVisibility = .all
    var presentedSheet: CodexLabRoute?
    var showSpecimenDrawer = false
    var showSettings = false

    func navigate(to route: CodexLabRoute) {
        switch route {
        case .periodicTable:
            path = NavigationPath()
            selectedElementID = nil
            showSpecimenDrawer = false
        case .specimenDrawer(let elementID):
            selectedElementID = elementID
            showSpecimenDrawer = true
        case .laboratoryWorkspace:
            path.append(CodexLabRoute.laboratoryWorkspace)
        case .experimentLog:
            path.append(CodexLabRoute.experimentLog)
        case .alchemyBench:
            path.append(CodexLabRoute.alchemyBench)
        case .scanner:
            presentedSheet = .scanner
        case .settings:
            showSettings = true
        }
    }

    func openSpecimen(_ bookID: UUID) {
        selectedBookID = bookID
        showSpecimenDrawer = false
        if !path.isEmpty {
            path.append(CodexLabRoute.laboratoryWorkspace)
        } else {
            path.append(CodexLabRoute.laboratoryWorkspace)
        }
    }

    func dismissSheet() {
        presentedSheet = nil
        showSettings = false
    }
}
