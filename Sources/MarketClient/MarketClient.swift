import Dependencies
import DependenciesMacros
import Models

@DependencyClient
public struct MarketClient {
    public var getSellableNoteList: @Sendable (_ userID: String) async throws -> NoteList
    public var getMarketList: @Sendable () async throws -> MarketNoteList
    public var getWordList: @Sendable (_ noteID: String) async throws -> MarketWordList
    public var postMarketNote: @Sendable (_ note: Note, _ price: Int) async throws -> Void
    public var postWordList: @Sendable (_ noteID: String, _ wordList: WordList) async throws -> Void
    public var getIsBuyable: @Sendable (_ userID: String, _ price: Int) async throws -> Bool
    public var buyNote: @Sendable (_ userID: String, _ note: MarketNote) async throws -> Void
    public var deleteNote: @Sendable (_ noteID: String) async throws -> Void
}

extension DependencyValues {
    public var marketClient: MarketClient {
        get { self[MarketClient.self] }
        set { self[MarketClient.self] = newValue }
    }
}

extension MarketClient: TestDependencyKey {
    public static var testValue = Self(
        getSellableNoteList: { _ in .mock },
        getMarketList: { .mock },
        getWordList: { _ in .mock },
        postMarketNote: { _, _ in },
        postWordList: { _, _ in },
        getIsBuyable: { _, _ in true },
        buyNote: { _, _ in },
        deleteNote: { _ in }
    )
    
    public static var previewValue = testValue
}

