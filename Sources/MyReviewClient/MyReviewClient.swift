import Dependencies
import DependenciesMacros
import Foundation
import Models

@DependencyClient
public struct MyReviewClient {
    public var getReviewList: (_ userID: String) async throws -> ReviewList
    public var postReview: (_ userID: String, _ review: Review) async throws -> Void
    public var deleteReview: (_ userID: String, _ reviewID: String) async throws -> Void
}

extension DependencyValues {
    public var myReviewClient: MyReviewClient {
        get { self[MyReviewClient.self] }
        set { self[MyReviewClient.self] = newValue }
    }
}

extension MyReviewClient: TestDependencyKey {
    public static var testValue = Self(
        getReviewList: { _ in .mock },
        postReview: { _, _ in },
        deleteReview: { _, _ in }
    )
    
    public static var previewValue = testValue
}
