import Dependencies
import Foundation

public typealias MarketNoteList = [MarketNote]

public struct MarketNote: Codable, Identifiable, CategoryProtocol {
    public let id: String
    /// 암기장 이름
    public var noteName: String
    /// 암기장 카테고리
    public var noteCategory: String
    /// 등록한 유저 UID
    public var enrollmentUser: String
    /// 암기장 가격
    public var notePrice: Int
    /// 등록한 날짜
    public var updateDate: Date
    /// 판매된 횟수
    public var salesCount: Int
    /// 암기장 총평점
    public var starScoreTotal: Double
    /// 등록된 리뷰 횟수
    public var reviewCount: Int
    
    enum CodingKeys: CodingKey {
        case id
        case noteName
        case noteCategory
        case enrollmentUser
        case notePrice
        case updateDate
        case salesCount
        case starScoreTotal
        case reviewCount
    }
    
    public init(
        id: String,
        noteName: String,
        noteCategory: String,
        enrollmentUser: String,
        notePrice: Int,
        updateDate: Date,
        salesCount: Int = 0,
        starScoreTotal: Double = 0,
        reviewCount: Int = 0,
        wordList: MarketWordList = []
    ) {
        self.id = id
        self.noteName = noteName
        self.noteCategory = noteCategory
        self.enrollmentUser = enrollmentUser
        self.notePrice = notePrice
        self.updateDate = updateDate
        self.salesCount = salesCount
        self.starScoreTotal = starScoreTotal
        self.reviewCount = reviewCount
        self.wordList = wordList
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init(
            id: try container.decode(String.self, forKey: .id),
            noteName: try container.decode(String.self, forKey: .noteName),
            noteCategory: try container.decode(String.self, forKey: .noteCategory),
            enrollmentUser: try container.decode(String.self, forKey: .enrollmentUser),
            notePrice: try container.decode(Int.self, forKey: .notePrice),
            updateDate: try container.decode(Date.self, forKey: .updateDate),
            salesCount: try container.decode(Int.self, forKey: .salesCount),
            starScoreTotal: try container.decode(Double.self, forKey: .starScoreTotal),
            reviewCount: try container.decode(Int.self, forKey: .reviewCount)
        )
    }
    
    public var wordList: MarketWordList
    
    /// 총 판매수익
    public var totalSalesAmount: Int {
        salesCount * notePrice
    }

}


// MARK: - Mocking

extension MarketNote {
    private init(
        noteName: String,
        noteCategory: String,
        enrollmentUser: String,
        notePrice: Int,
        salesCount: Int,
        starScoreTotal: Double,
        reviewCount: Int
    ) {
        @Dependency(\.uuid) var uuid
        @Dependency(\.date) var date
        self.init(
            id: uuid().uuidString,
            noteName: noteName,
            noteCategory: noteCategory,
            enrollmentUser: enrollmentUser,
            notePrice: notePrice,
            updateDate: date(),
            salesCount: salesCount,
            starScoreTotal: starScoreTotal,
            reviewCount: reviewCount,
            wordList: .mock
        )
    }
    
    public static let mock = Self(
        noteName: "시험 하루 전 꼭 봐야할 토익 단어",
        noteCategory: "영어",
        enrollmentUser: "4SJyuVeU3Hhz4Q0I039wKaMUVIq21234",
        notePrice: 1000,
        salesCount: 5,
        starScoreTotal: 3.0,
        reviewCount: 10
    )
    
    public static let mock2 = Self(
        noteName: "20가지 유용한 필수 일본 여행 회화",
        noteCategory: "기타",
        enrollmentUser: "XN9Tq6Y0epNIpLfAmTuJS835tEL142JE3",
        notePrice: 100,
        salesCount: 25,
        starScoreTotal: 9,
        reviewCount: 2
    )
}

extension MarketNoteList {
    public static let mock = Self([
        .mock,
        .mock2
    ])
}
