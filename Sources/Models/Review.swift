import Dependencies
import Foundation

public typealias ReviewList = [Review]

public struct Review: Codable, Identifiable, Equatable {
    public var id: String
    public var writer: String
    public var reviewText: String
    public var createDate: Date
    public var starScore: Double
    public var noteTitle: String
    public var noteCategory: String
    
    public init(
        id: String,
        writer: String,
        reviewText: String,
        createDate: Date,
        starScore: Double,
        noteTitle: String,
        noteCategory: String
    ) {
        self.id = id
        self.writer = writer
        self.reviewText = reviewText
        self.createDate = createDate
        self.starScore = starScore
        self.noteTitle = noteTitle
        self.noteCategory = noteCategory
    }
    
    public init(
        writer: String,
        reviewText: String,
        starScore: Double,
        noteTitle: String,
        noteCategory: String
    ) {
        @Dependency(\.uuid) var uuid
        @Dependency(\.date.now) var now
        self.id = uuid().uuidString
        self.writer = writer
        self.reviewText = reviewText
        self.createDate = now
        self.starScore = starScore
        self.noteTitle = noteTitle
        self.noteCategory = noteCategory
    }
    
    public init(
        marketNote: MarketNote,
        reivewText: String,
        starScore: Double
    ) {
        self.init(writer: marketNote.enrollmentUser,
                  reviewText: reivewText,
                  starScore: starScore,
                  noteTitle: marketNote.noteName,
                  noteCategory: marketNote.noteCategory
        )
    }
}

extension Review {
    public static var mock = Self(
        writer: "리리뷰",
        reviewText: "일본에서 실제로 적용해보니 너무 좋았어요",
        starScore: 5,
        noteTitle: "여행에 필요한 일본어 총정리",
        noteCategory: "기타"
    )
    public static var mock2 = Self(
        writer: "사용자7FC55",
        reviewText: "너무 유용해요",
        starScore: 4,
        noteTitle: "시사 경제 알아보기",
        noteCategory: "시사"
    )
}

extension ReviewList {
    public static var mock = Self([
        .mock,
        .mock2
    ])
}
