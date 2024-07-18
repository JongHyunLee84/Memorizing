import Dependencies
import Foundation

public typealias ReviewList = [Review]

public struct Review: Codable, Identifiable {
    public var id: String
    public var writer: String
    public var reviewText: String
    public var createDate: Date
    public var starScore: Double
    
    public init(
        id: String,
        writer: String,
        reviewText: String,
        createDate: Date,
        starScore: Double
    ) {
        self.id = id
        self.writer = writer
        self.reviewText = reviewText
        self.createDate = createDate
        self.starScore = starScore
    }
    
    public init(
        writer: String,
        reviewText: String,
        starScore: Double
    ) {
        @Dependency(\.uuid) var uuid
        @Dependency(\.date.now) var now
        self.id = uuid().uuidString
        self.writer = writer
        self.reviewText = reviewText
        self.createDate = now
        self.starScore = starScore
    }
}

extension Review {
    public static var mock = Self(
        writer: "리리뷰",
        reviewText: "일본에서 실제로 적용해보니 너무 좋았어요",
        starScore: 5
    )
    public static var mock2 = Self(
        writer: "사용자7FC55",
        reviewText: "너무 유용해요",
        starScore: 4
    )
}

extension ReviewList {
    public static var mock = Self([
        .mock,
        .mock2
    ])
}
