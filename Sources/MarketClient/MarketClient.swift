import Dependencies
import DependenciesMacros
import Models

@DependencyClient
public struct MarketClient {
    public var getSellableNoteList: (_ userID: String) async throws -> NoteList
    public var getMarketNoteList: () async throws -> MarketNoteList
    public var getMarketNoteListWith: (_ noteIDList: [String]) async throws -> MarketNoteList
    public var getWordList: (_ noteID: String) async throws -> MarketWordList
    public var postMarketNote: (_ note: Note, _ price: Int) async throws -> Void
    public var postWordList: (_ noteID: String, _ wordList: WordList) async throws -> Void
    public var getIsBuyable: (_ userID: String, _ price: Int) async throws -> Bool
    public var buyNote: (_ userID: String, _ note: MarketNote) async throws -> Void
    public var deleteNote: (_ noteID: String) async throws -> Void
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
        getMarketNoteList: { .mock },
        getMarketNoteListWith: { _ in .mock },
        getWordList: { _ in .mock },
        postMarketNote: { _, _ in },
        postWordList: { _, _ in },
        getIsBuyable: { _, _ in true },
        buyNote: { _, _ in },
        deleteNote: { _ in }
    )
    
    public static var previewValue = testValue
}

