import Foundation
import Combine
import UIKit

/// Manages the user's catalog of gaming applications.
/// Because standard iOS sandboxing forbids querying installed applications without MDM or private frameworks,
/// GCOOL provides a user-curated favorites system with URL scheme validation and active game pinning.
public class FavoritesStore: ObservableObject {
    public static let shared = FavoritesStore()

    @Published public private(set) var games: [GameItem] = []
    @Published public private(set) var pinnedGame: GameItem?

    private let storageFileName = "gcool_favorites.json"

    public init() {
        loadGames()
        if games.isEmpty {
            self.games = GameItem.defaults
            saveGames()
        }
        updatePinned()
    }

    // MARK: - Catalog CRUD

    public func addGame(name: String, category: String, launchURLScheme: String?, notes: String) -> GameItem {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let item = GameItem(
            name: trimmedName.isEmpty ? "Custom Game" : trimmedName,
            category: category.isEmpty ? "Action" : category,
            launchURLScheme: launchURLScheme?.trimmingCharacters(in: .whitespacesAndNewlines),
            notes: notes,
            isPinnedAsActive: false
        )
        games.append(item)
        saveGames()
        return item
    }

    public func updateGame(_ item: GameItem) {
        if let idx = games.firstIndex(where: { $0.id == item.id }) {
            games[idx] = item
            saveGames()
            updatePinned()
        }
    }

    public func deleteGame(at offsets: IndexSet) {
        games.remove(atOffsets: offsets)
        saveGames()
        updatePinned()
    }

    public func deleteGame(byId id: UUID) {
        games.removeAll(where: { $0.id == id })
        saveGames()
        updatePinned()
    }

    /// Pins a game as the primary active game in GCOOL.
    public func pinGame(byId id: UUID) {
        for i in 0..<games.count {
            games[i].isPinnedAsActive = (games[i].id == id)
        }
        saveGames()
        updatePinned()
    }

    /// Unpins all games.
    public func unpinAll() {
        for i in 0..<games.count {
            games[i].isPinnedAsActive = false
        }
        saveGames()
        updatePinned()
    }

    /// Attempts to open the registered URL scheme for this game if valid and supported by the device.
    @discardableResult
    public func launchGame(_ item: GameItem, completion: ((Bool) -> Void)? = nil) -> Bool {
        guard let scheme = item.launchURLScheme, let url = URL(string: scheme) else {
            completion?(false)
            return false
        }

        UIApplication.shared.open(url, options: [:]) { success in
            completion?(success)
        }
        return true
    }

    private func updatePinned() {
        self.pinnedGame = games.first(where: { $0.isPinnedAsActive })
    }

    // MARK: - Persistence

    private var fileURL: URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0].appendingPathComponent(storageFileName)
    }

    public func saveGames() {
        do {
            let data = try JSONEncoder().encode(games)
            try data.write(to: fileURL, options: .atomic)
        } catch {
            print("[GCOOL] Failed to save games: \(error.localizedDescription)")
        }
    }

    private func loadGames() {
        guard FileManager.default.fileExists(atPath: fileURL.path) else { return }
        do {
            let data = try Data(contentsOf: fileURL)
            self.games = try JSONDecoder().decode([GameItem].self, from: data)
        } catch {
            print("[GCOOL] Failed to load games: \(error.localizedDescription)")
        }
    }

    /// Resets catalog to the default recommended game titles.
    public func resetToDefaults() {
        self.games = GameItem.defaults
        saveGames()
        updatePinned()
    }
}
