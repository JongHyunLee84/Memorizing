import ComposableArchitecture
import Models
import ReviewHistoryFeature
import Shared
import XCTest

final class ReviewHistoryFeatureTest: XCTestCase {
    
    @MainActor
    func test_onAppear() async {
        @Shared(.currentUser) var currentUser
        $currentUser.withLock { $0 = .mock }
        let store = TestStore(
            initialState: ReviewHistoryFeature.State(),
            reducer: { ReviewHistoryFeature() },
            withDependencies: {
                $0.uuid = .incrementing
                $0.date.now = Date(timeIntervalSince1970: 1234567890)
            }
        )
        
        await store.send(\.view.onAppear)
        await store.receive(\.reviewListResponse) {
            $0.reviewList = .init(uniqueElements: MyReviewList.mock)
        }
    }
    
    @MainActor
    func test_delete_review_success() async {
        @Shared(.currentUser) var currentUser
        $currentUser.withLock { $0 = .mock }
        let store = TestStore(
            initialState: ReviewHistoryFeature.State(
                reviewList: .init(uniqueElements: MyReviewList.mock)
            ),
            reducer: { ReviewHistoryFeature() },
            withDependencies: {
                $0.uuid = .incrementing
                $0.date.now = Date(timeIntervalSince1970: 1234567890)
            }
        )
        let firstReview = store.state.reviewList.first ?? .mock
        await store.send(.view(.deleteButtonTapped(firstReview))) {
            $0.alert = .deleteReview(firstReview)
        }
        await store.send(\.alert.presented.confirmDelete, firstReview) {
            $0.alert = nil
        }
        await store.receive(\.removeListWith) {
            $0.reviewList.remove(id: firstReview.id)
        }
        await store.receive(\.toastMessage) {
            $0.toastMessage = "리뷰가 삭제되었어요."
        }
    }
    
    @MainActor
    func test_delete_review_cancel() async {
        @Shared(.currentUser) var currentUser
        $currentUser.withLock { $0 = .mock }
        let store = TestStore(
            initialState: ReviewHistoryFeature.State(
                reviewList: .init(uniqueElements: MyReviewList.mock)
            ),
            reducer: { ReviewHistoryFeature() },
            withDependencies: {
                $0.uuid = .incrementing
                $0.date.now = Date(timeIntervalSince1970: 1234567890)
            }
        )
        let firstReview = store.state.reviewList.first ?? .mock
        await store.send(.view(.deleteButtonTapped(firstReview))) {
            $0.alert = .deleteReview(firstReview)
        }
        await store.send(\.alert.dismiss) {
            $0.alert = nil
        }
    }
    
    @MainActor
    func test_backButtonTapped() async {
        let isDismissInvoked: LockIsolated<[Bool]> = .init([])
        let store = TestStore(
            initialState: ReviewHistoryFeature.State(),
            reducer: { ReviewHistoryFeature() },
            withDependencies: {
                $0.dismiss = DismissEffect { isDismissInvoked.withValue { $0.append(true) } }
            }
        )
        await store.send(\.view.backButtonTapped)
        XCTAssertEqual(isDismissInvoked.value, [true])
    }
    
}
