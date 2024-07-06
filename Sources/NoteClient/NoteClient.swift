import Dependencies
import DependenciesMacros
import Foundation
import Models

@DependencyClient
public struct NoteClient {
    public var getNoteList: @Sendable (_ userID: String) async throws -> NoteList
    public var getWordList: @Sendable (_ userID: String, _ noteID: String) async throws -> WordList
    public var saveNote: @Sendable (_ userID: String, _ note: Note) async throws -> Void
    public var saveWord: @Sendable (_ userID: String, _ noteID: String, _ word: Word) async throws -> Void
    public var saveWordList: @Sendable (_ userID: String, _ noteID: String, _ wordList: WordList) async throws -> Void
    public var deleteNote: @Sendable (_ userID: String, _ note: Note) async throws -> Void
    public var deleteWord: @Sendable (_ userID: String, _ noteID: String, _ wordID: String) async throws -> Void
    public var incrementRepeatCount: @Sendable (_ userID: String, _ noteID: String) async throws -> Void
    public var setNextStudyDate: @Sendable (_ userID: String, _ noteID: String, _ date: Date) async throws -> Void
    public var setFirstTestResult: @Sendable (_ userID: String, _ noteID: String, _ result: Double) async throws -> Void
    public var setLastTestResult: @Sendable (_ userID: String, _ noteID: String, _ result: Double) async throws -> Void
    public var resetRepeatCount: @Sendable (_ userID: String, _ noteID: String) async throws -> Void
    public var updateWordLevel: @Sendable (_ userID: String, _ noteID: String, _ wordID: String, _ level: Int) async throws -> Void
}

extension DependencyValues {
    public var noteClient: NoteClient {
        get { self[NoteClient.self] }
        set { self[NoteClient.self] = newValue }
    }
}

extension NoteClient: TestDependencyKey {
    public static var testValue = Self(
        getNoteList: { _ in .mock },
        getWordList: { _, _ in .mock },
        saveNote: { _, _ in },
        saveWord: { _, _, _ in },
        saveWordList: { _, _, _ in },
        deleteNote: { _, _ in },
        deleteWord: { _, _, _ in },
        incrementRepeatCount: { _, _ in },
        setNextStudyDate: { _, _, _ in },
        setFirstTestResult: { _, _, _ in },
        setLastTestResult: { _, _, _ in },
        resetRepeatCount: { _, _ in },
        updateWordLevel: { _, _, _, _ in }
    )
    
    public static var previewValue = testValue
}
