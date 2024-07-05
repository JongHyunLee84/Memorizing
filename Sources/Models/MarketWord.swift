import Dependencies
import Foundation

public typealias MarketWordList = [MarketWord]

public struct MarketWord: Codable, Identifiable {
    public let id: String
    public var wordMeaning: String
    public var wordString: String
}

// MARK: - Mocking

extension MarketWord {
    private init(
        wordMeaning: String,
        wordString: String
    ) {
        @Dependency(\.uuid) var uuid
        self.init(
            id: uuid().uuidString,
            wordMeaning: wordMeaning,
            wordString: wordString
        )
    }
    
    public static let mock = Self(
        wordMeaning: "죄송합니다",
        wordString: "すいません"
    )
    
    public static let mock2 = Self(
        wordMeaning: "영어 할줄 아시나요?",
        wordString: "英語できますか"
    )
}

extension MarketWordList {
    public static let mock = Self([
        .mock,
        .mock2
    ])
}
