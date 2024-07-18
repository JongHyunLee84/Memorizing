import Dependencies
import DependenciesMacros
import Models

@DependencyClient
public struct ReviewClient {
    public var getReviewList: @Sendable (_ noteID: String) async throws -> ReviewList
    public var getReviewListWithLimit: @Sendable (_ noteID: String, _ limit: Int) async throws -> ReviewList
    public var postReview: @Sendable (_ noteID: String, _ review: Review) async throws -> Void
    // score, reviewCount
    public var updateMarketNoteReviewData: @Sendable (_ noteID: String, _ review: Review) async throws -> Void
    public var deleteReview: @Sendable (_ noteID: String, _ reviewID: String) async throws -> Void
}

extension DependencyValues {
    public var reviewClient: ReviewClient {
        get { self[ReviewClient.self] }
        set { self[ReviewClient.self] = newValue }
    }
}

extension ReviewClient: TestDependencyKey {
    public static var testValue = Self(
        getReviewList: { _ in .mock },
        getReviewListWithLimit: { _, _ in .mock },
        postReview: { _, _ in },
        updateMarketNoteReviewData: { _, _ in },
        deleteReview: { _, _ in }
    )
    
    public static var previewValue = testValue
}
