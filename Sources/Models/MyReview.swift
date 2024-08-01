import Dependencies
import Foundation

public typealias MyReviewList = [MyReview]

public struct MyReview: Codable, Identifiable, Equatable {
    public var id: String
    public var noteID: String
    public var noteOwner: String
    public var noteTitle: String
    public var noteCategory: String
    public var reviewText: String
    public var createDate: Date
    public var starScore: Double
    
    public init(
        id: String,
        noteID: String,
        noteOwner: String,
        noteTitle: String,
        noteCategory: String,
        reviewText: String,
        createDate: Date,
        starScore: Double
    ) {
        self.id = id
        self.noteID = noteID
        self.noteOwner = noteOwner
        self.noteTitle = noteTitle
        self.noteCategory = noteCategory
        self.reviewText = reviewText
        self.createDate = createDate
        self.starScore = starScore
    }
    
    public init(
        reviewText: String,
        starScore: Double,
        noteTitle: String,
        noteCategory: String
    ) {
        @Dependency(\.uuid) var uuid
        @Dependency(\.date.now) var now
        self.id = uuid().uuidString
        self.noteID = uuid().uuidString
        self.noteOwner = uuid().uuidString
        self.noteTitle = noteTitle
        self.noteCategory = noteCategory
        self.reviewText = reviewText
        self.createDate = now
        self.starScore = starScore
    }
}

extension MyReview {
    public static var mock = Self(
        reviewText: "일본에서 실제로 적용해보니 너무 좋았어요",
        starScore: 5,
        noteTitle: "여행에 필요한 일본어 총정리",
        noteCategory: "기타"
    )
    public static var mock2 = Self(
        reviewText: "너무 유용해요",
        starScore: 4,
        noteTitle: "시사 경제 알아보기",
        noteCategory: "기타"
    )
}

extension MyReviewList {
    public static var mock = Self([
        .mock,
        .mock2
    ])
}
