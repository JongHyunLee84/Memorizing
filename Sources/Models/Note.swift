import Dependencies
import Foundation
import SwiftUI

public typealias NoteList = [Note]

// MARK: WordNote - 암기장
public struct Note: Codable, Identifiable, Equatable, CategoryProtocol {
    public let id: String
    public var noteName: String
    public var noteCategory: String
    public var enrollmentUser: String
    public var repeatCount: Int
    public var firstTestResult: Double
    public var lastTestResult: Double
    public var updateDate: Date
    public var nextStudyDate: Date?
    
    // MARK: 마켓 거래내역 관련 추가 - 현기
    /// 마켓에서 구매한 날짜
    public var marketPurchaseDate: Date?
    /// 마켓에서 구매한 가격
    public var notePrice: Int?
    /// 리뷰 작성 시간
    public var reviewDate: Date?
    
    enum CodingKeys: CodingKey {
        case id
        case noteName
        case noteCategory
        case enrollmentUser
        case repeatCount
        case firstTestResult
        case lastTestResult
        case updateDate
        case nextStudyDate
        case marketPurchaseDate
        case notePrice
        case reviewDate
    }
    
    
    init(
        id: String,
        noteName: String,
        noteCategory: String,
        enrollmentUser: String,
        repeatCount: Int,
        firstTestResult: Double,
        lastTestResult: Double,
        updateDate: Date,
        nextStudyDate: Date? = nil,
        marketPurchaseDate: Date? = nil,
        notePrice: Int? = nil,
        reviewDate: Date? = nil,
        wordList: WordList = []
    ) {
        self.id = id
        self.noteName = noteName
        self.noteCategory = noteCategory
        self.enrollmentUser = enrollmentUser
        self.repeatCount = repeatCount
        self.firstTestResult = firstTestResult
        self.lastTestResult = lastTestResult
        self.updateDate = updateDate
        self.nextStudyDate = nextStudyDate
        self.marketPurchaseDate = marketPurchaseDate
        self.notePrice = notePrice
        self.reviewDate = reviewDate
        self.wordList = wordList
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init(
            id: try container.decode(String.self, forKey: .id),
            noteName: try container.decode(String.self, forKey: .noteName),
            noteCategory: try container.decode(String.self, forKey: .noteCategory),
            enrollmentUser: try container.decode(String.self, forKey: .enrollmentUser),
            repeatCount: try container.decode(Int.self, forKey: .repeatCount),
            firstTestResult: try container.decode(Double.self, forKey: .firstTestResult),
            lastTestResult: try container.decode(Double.self, forKey: .lastTestResult),
            updateDate: try container.decode(Date.self, forKey: .updateDate),
            nextStudyDate: try container.decodeIfPresent(Date.self, forKey: .nextStudyDate),
            marketPurchaseDate: try container.decodeIfPresent(Date.self, forKey: .marketPurchaseDate),
            notePrice: try container.decodeIfPresent(Int.self, forKey: .notePrice),
            reviewDate: try container.decodeIfPresent(Date.self, forKey: .reviewDate)
        )
    }
    
    public var wordList: WordList
    
    public var noteColor: Color {
        category.noteColor
    }
    
    /// marketPurchaseDate 날짜 형식 변경
//    var marketPurchaseDateStr: String? {
//        let dateFormatter = DateFormatter()
//        dateFormatter.locale = Locale(identifier: "ko_kr")
//        dateFormatter.timeZone = TimeZone(abbreviation: "KST")
//        dateFormatter.dateFormat = "yyyy.MM.dd"
//        
//        return dateFormatter.string(from: marketPurchaseDate ?? Date())
//    }
    
}

// MARK: - Mocking

extension Note {
    private init(
        noteName: String,
        noteCategory: String,
        enrollmentUser: String,
        repeatCount: Int,
        firstTestResult: Double,
        lastTestResult: Double,
        notePrice: Int? = nil,
        wordList: WordList = .mock
    ) {
        @Dependency(\.uuid) var uuid
        @Dependency(\.date) var date
        self.init(
            id: uuid().uuidString,
            noteName: noteName,
            noteCategory: noteCategory,
            enrollmentUser: enrollmentUser,
            repeatCount: repeatCount,
            firstTestResult: firstTestResult,
            lastTestResult: lastTestResult,
            updateDate: date(),
            nextStudyDate: date(),
            marketPurchaseDate: date(),
            notePrice: notePrice,
            reviewDate: date(),
            wordList: wordList
        )
    }
    
    public static let mock = Self(
        noteName: "이건 알아야해! 속담 모음집",
        noteCategory: "한국사",
        enrollmentUser: "58TIlLKwJWOAjhsglkXaOsgaCfb8nHA2",
        repeatCount: 2,
        firstTestResult: 0.6,
        lastTestResult: 0
    )
    
    public static let mock2 = Self(
        noteName: "WSET 2단계 와인 인증 과정 연습문제",
        noteCategory: "기타",
        enrollmentUser: "58TIlLOAjhsglkXaOsgaCfb8nHA2",
        repeatCount: 4,
        firstTestResult: 100,
        lastTestResult: 100
    )
    
    public static let mock3 = Self(
        noteName: "토익 필수 문제",
        noteCategory: "영어",
        enrollmentUser: "58TIlLOAjhsglasdfkXaOsgaCfb8nHA2",
        repeatCount: 0,
        firstTestResult: 0,
        lastTestResult: 0,
        wordList: []
    )
}


extension NoteList {
    public static let mock = Self([
        .mock3,
        .mock,
        .mock2
    ])
}
