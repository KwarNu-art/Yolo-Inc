import SwiftUI

public struct ApplicationsView: View {
    @ObservedObject var favoritesStore = FavoritesStore.shared
    @ObservedObject var sessionManager = SessionManager.shared

    @State private var searchText = ""
    @State private var showingAddSheet = false
    @State private var newGameName = ""
    @State private var newGameCategory = "Action"
    @State private var newGameURLScheme = ""
    @State private var newGameNotes = ""

    public init() {}

    private var filteredGames: [GameItem] {
        if searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return favoritesStore.games
        } else {
            return favoritesStore.games.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.category.localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    public var body: some View {
        ZStack {
            GlacierTheme.glacierGradient.ignoresSafeArea()
            SnowfallView()

            ScrollView {
                VStack(spacing: 16) {
                    searchAndAddBar
                    sandboxTransparencyBanner
                    gameListSection
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 24)
            }
        }
        .navigationTitle("Game Catalog")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingAddSheet) {
            addGameModal
        }
    }

    // MARK: - Search & Add Bar
    private var searchAndAddBar: some View {
        HStack(spacing: 10) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(GlacierTheme.silverSlate)

                TextField("Search games or categories...", text: $searchText)
                    .foregroundColor(GlacierTheme.snowWhite)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(GlacierTheme.cardBackground)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(GlacierTheme.cardBorder, lineWidth: 1)
            )

            Button(action: {
                showingAddSheet = true
            }) {
                Image(systemName: "plus")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .padding(12)
                    .background(GlacierTheme.heroButtonGradient)
                    .cornerRadius(12)
                    .shadow(color: GlacierTheme.iceBlue.opacity(0.3), radius: 6, x: 0, y: 3)
            }
        }
    }

    // MARK: - Sandbox Transparency Banner
    private var sandboxTransparencyBanner: some View {
        GlacierCard {
            HStack(spacing: 12) {
                Image(systemName: "info.circle.fill")
                    .foregroundColor(GlacierTheme.iceBlue)
                    .font(.system(size: 18))

                VStack(alignment: .leading, spacing: 2) {
                    Text("Privacy-Preserving Catalog")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(GlacierTheme.snowWhite)

                    Text("Standard iOS apps cannot scan or discover all installed apps without MDM or private APIs. Manage your favorite games and URL schemes manually below.")
                        .font(.system(size: 11))
                        .foregroundColor(GlacierTheme.silverSlate)
                }
            }
        }
    }

    // MARK: - Game List Section
    private var gameListSection: some View {
        VStack(spacing: 12) {
            if filteredGames.isEmpty {
                GlacierCard {
                    VStack(spacing: 10) {
                        Image(systemName: "gamecontroller")
                            .font(.system(size: 36))
                            .foregroundColor(GlacierTheme.silverSlate)

                        Text("No Games Found")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(GlacierTheme.snowWhite)

                        Text("Tap the '+' button above to add custom games or reset to default catalog titles.")
                            .font(.system(size: 12))
                            .foregroundColor(GlacierTheme.silverSlate)
                            .multilineTextAlignment(.center)

                        Button(action: {
                            favoritesStore.resetToDefaults()
                        }) {
                            Text("Reset Default Catalog")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(GlacierTheme.iceBlue)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(GlacierTheme.iceBlue.opacity(0.15))
                                .cornerRadius(8)
                        }
                        .padding(.top, 4)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                }
            } else {
                ForEach(filteredGames) { game in
                    NavigationLink(destination: GameDetailView(game: game)) {
                        GlacierCard(borderColor: game.isPinnedAsActive ? GlacierTheme.iceBlue.opacity(0.6) : GlacierTheme.cardBorder) {
                            HStack(spacing: 14) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(GlacierTheme.iceBlue.opacity(0.15))
                                        .frame(width: 44, height: 44)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(GlacierTheme.iceBlue.opacity(0.3), lineWidth: 1)
                                        )

                                    Image(systemName: "gamecontroller.fill")
                                        .font(.system(size: 20))
                                        .foregroundColor(GlacierTheme.iceBlue)
                                }

                                VStack(alignment: .leading, spacing: 3) {
                                    HStack(spacing: 6) {
                                        Text(game.name)
                                            .font(.system(size: 15, weight: .bold))
                                            .foregroundColor(GlacierTheme.snowWhite)

                                        if game.isPinnedAsActive {
                                            Image(systemName: "pin.fill")
                                                .font(.system(size: 10))
                                                .foregroundColor(GlacierTheme.seasonalPine)
                                        }
                                    }

                                    Text(game.category)
                                        .font(.system(size: 12))
                                        .foregroundColor(GlacierTheme.silverSlate)
                                }

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(GlacierTheme.silverSlate)
                            }
                        }
                    }
                }
            }
        }
    }

    // MARK: - Add Game Modal Sheet
    private var addGameModal: some View {
        NavigationView {
            ZStack {
                GlacierTheme.backgroundDark.ignoresSafeArea()

                Form {
                    Section(header: Text("GAME DETAILS").foregroundColor(GlacierTheme.silverSlate)) {
                        TextField("Game Name (e.g. Apex Legends)", text: $newGameName)
                        TextField("Category (e.g. Battle Royale)", text: $newGameCategory)
                    }

                    Section(
                        header: Text("LAUNCH URL SCHEME (OPTIONAL)").foregroundColor(GlacierTheme.silverSlate),
                        footer: Text("If the game registers a custom URL scheme (e.g. pubgmobile://), GCOOL can launch it when your session starts.").foregroundColor(GlacierTheme.silverSlate)
                    ) {
                        TextField("URL Scheme (e.g. game://)", text: $newGameURLScheme)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                    }

                    Section(header: Text("NOTES & PROFILE").foregroundColor(GlacierTheme.silverSlate)) {
                        TextField("Notes (e.g. 60 FPS cap, smooth graphics)", text: $newGameNotes)
                    }
                }
            }
            .navigationTitle("Add Game to Catalog")
            .navigationBarItems(
                leading: Button("Cancel") {
                    showingAddSheet = false
                },
                trailing: Button("Save") {
                    favoritesStore.addGame(
                        name: newGameName,
                        category: newGameCategory,
                        launchURLScheme: newGameURLScheme.isEmpty ? nil : newGameURLScheme,
                        notes: newGameNotes
                    )
                    newGameName = ""
                    newGameURLScheme = ""
                    newGameNotes = ""
                    showingAddSheet = false
                }
                .disabled(newGameName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            )
        }
    }
}
