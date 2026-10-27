import XCTest
@testable import GCOOL

class FavoritesStoreTests: XCTestCase {
    var store: FavoritesStore!

    override func setUp() {
        super.setUp()
        store = FavoritesStore()
        store.resetToDefaults()
    }

    func testDefaultGamesLoaded() {
        XCTAssertFalse(store.games.isEmpty)
        XCTAssertTrue(store.games.contains { $0.name.contains("Mobile Legends") })
    }

    func testAddAndPinGame() {
        let added = store.addGame(
            name: "Apex Legends Mobile",
            category: "Shooter",
            launchURLScheme: "apex://",
            notes: "Test profile"
        )

        XCTAssertEqual(added.name, "Apex Legends Mobile")
        XCTAssertTrue(store.games.contains { $0.id == added.id })

        // Pin the added game
        store.pinGame(byId: added.id)
        XCTAssertEqual(store.pinnedGame?.id, added.id)
        XCTAssertTrue(store.pinnedGame?.isPinnedAsActive ?? false)

        // Unpin
        store.unpinAll()
        XCTAssertNil(store.pinnedGame)
    }

    func testURLSchemeValidation() {
        let valid = GameItem(name: "Valid", launchURLScheme: "game://play")
        XCTAssertTrue(valid.isValidLaunchURL)

        let invalid = GameItem(name: "Invalid", launchURLScheme: "just_text_no_colon")
        XCTAssertFalse(invalid.isValidLaunchURL)

        let empty = GameItem(name: "Empty", launchURLScheme: "")
        XCTAssertFalse(empty.isValidLaunchURL)
    }

    func testDeleteGame() {
        let added = store.addGame(name: "Delete Me", category: "Test", launchURLScheme: nil, notes: "")
        let initialCount = store.games.count

        store.deleteGame(byId: added.id)
        XCTAssertEqual(store.games.count, initialCount - 1)
        XCTAssertFalse(store.games.contains { $0.id == added.id })
    }
}
