import Foundation
import Observation

enum LibraryFilter: String, CaseIterable, Identifiable {
    case all = "All"
    case sops = "SOPs"
    case checklists = "Checklists"
    case training = "Training"

    var id: String { rawValue }
}

@MainActor
@Observable
final class DocumentLibraryViewModel {
    var searchText = ""
    var filter = LibraryFilter.all
    var errorMessage: String?

    func includesSOPs() -> Bool {
        filter == .all || filter == .sops
    }

    func includesChecklists() -> Bool {
        filter == .all || filter == .checklists
    }

    func includesTraining() -> Bool {
        filter == .all || filter == .training
    }

    func matches(title: String, category: String, content: String = "") -> Bool {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return true }
        let haystack = "\(title) \(category) \(content)".localizedCaseInsensitiveContains(query)
        return haystack
    }
}
