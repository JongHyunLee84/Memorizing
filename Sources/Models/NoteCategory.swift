import Foundation

public enum NoteCategory: String, CaseIterable {
    case english = "영어"
    case history = "한국사"
    case it = "IT"
    case economy = "경제"
    case knowledge = "시사"
    case etc = "기타"
}

public protocol CategoryProtocol {
    var noteCategory: String { get }
}

extension CategoryProtocol {
    public var category: NoteCategory {
        NoteCategory(rawValue: noteCategory) ?? .etc
    }
}
