import Dependencies
import Utilities
import Foundation

public typealias WordList = [Word]

// MARK: Word - 단어, 용어 등
public struct Word: Codable, Identifiable, Equatable {
    public let id: String
    public var wordString: String
    public var wordMeaning: String
    public var wordLevel: Int
    
    public init(
        wordString: String,
        wordMeaning: String,
        wordLevel: Int = 0
    ) {
        @Dependency(\.uuid) var uuid
        self.init(
            id: uuid().uuidString,
            wordString: wordString,
            wordMeaning: wordMeaning,
            wordLevel: wordLevel
        )
    }
    
    public init(
        id: String,
        wordString: String,
        wordMeaning: String,
        wordLevel: Int
    ) {
        self.id = id
        self.wordString = wordString
        self.wordMeaning = wordMeaning
        self.wordLevel = wordLevel
    }
}

extension Word {
    public static let mock = Self(
        wordString: "레드와인의 색이 추출되는 양조 과정?",
        wordMeaning: "포도 껍질과 접촉해 발효",
        wordLevel: 0
    )
    
    public static let mock2 = Self(
        wordString: "효모 자가 분해 풍미는?",
        wordMeaning: "비스킷과 빵",
        wordLevel: 2
    )
}

extension WordList {
    public static let mock = Self([
        .mock,
        .mock2
    ])
}
