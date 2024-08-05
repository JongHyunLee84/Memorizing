import ComposableArchitecture
import Shared
import WriteReviewFeature
import XCTest

final class WriteReviewFeatureTest: XCTestCase {
    
    @MainActor
    func test_confirmButtonTapped() async {
        let isDismissInvoked: LockIsolated<[Bool]> = .init([])
        @Shared(.currentUser) var currentUser
        $currentUser.withLock { $0 = .mock }
        let clock = TestClock()
        let store = TestStore(
            initialState: WriteReviewFeature.State(note: .mock),
            reducer: { WriteReviewFeature() },
            withDependencies: {
                $0.uuid = .incrementing
                $0.date.now = Date(timeIntervalSince1970: 1234567890)
                $0.continuousClock = clock
                $0.dismiss = DismissEffect { isDismissInvoked.withValue{ $0.append(true) }}
            }
        )
        
        await store.send(\.view.binding.score, 3) {
            $0.score = 3
        }
        await store.send(\.view.binding.reviewContent, "좋아요") {
            $0.reviewContent = "좋아요"
        }
        await store.send(.view(.confirmButtonTapped)) {
            $0.score = 0
            $0.reviewContent = ""
        }
        await store.receive(\.toastMessage) {
            $0.toastMessage = "리뷰가 등록되었어요."
        }
        await clock.advance(by: .seconds(1))
        XCTAssertEqual(isDismissInvoked.value, [true])
    }
    
    @MainActor
    func test_binding_limit() async {
        let store = TestStore(
            initialState: WriteReviewFeature.State(note: .mock),
            reducer: { WriteReviewFeature() },
            withDependencies: {
                $0.uuid = .incrementing
                $0.date.now = Date(timeIntervalSince1970: 1234567890)
            }
        )
        
        await store.send(\.view.binding.score, 6) {
            $0.score = 5
        }
        let overLimit = String(repeating: "A", count: store.state.textLimit + 1)
        await store.send(\.view.binding.reviewContent, overLimit) {
            $0.reviewContent = String(overLimit.prefix($0.textLimit))
        }
    }
    
    @MainActor
    func test_backButtonTapped() async {
        let isDismissInvoked: LockIsolated<[Bool]> = .init([])
        let store = TestStore(
            initialState: WriteReviewFeature.State(note: .mock),
            reducer: { WriteReviewFeature() },
            withDependencies: {
                $0.uuid = .incrementing
                $0.date.now = Date(timeIntervalSince1970: 1234567890)
                $0.dismiss = DismissEffect { isDismissInvoked.withValue { $0.append(true) }}
            }
        )
        
        await store.send(\.view.backButtonTapped)
        XCTAssertEqual(isDismissInvoked.value, [true])
    }
    
}
