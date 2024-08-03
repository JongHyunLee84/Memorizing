import ComposableArchitecture
import PurchaseHistoryFeature
import Shared
import XCTest

final class PurchaseHistoryFeatureTest: XCTestCase {
    
    @MainActor
    func test_onAppear() async {
        @Shared(.currentUser) var currentUser
        $currentUser.withLock { $0 = .mock }
        let store = TestStore(
            initialState: PurchaseHistoryFeature.State(noteList: .mock),
            reducer: { PurchaseHistoryFeature() },
            withDependencies: {
                $0.uuid = .incrementing
                $0.date.now = Date(timeIntervalSince1970: 1234567890)
            }
        )
        
        await store.send(\.view.onAppear) {
            $0.isLoading = true
        }
        await store.receive(\.myReviewListResponse) {
            $0.reviewList = .mock
        }
        await store.receive(\.handleResponseCount) {
            $0.responseCount += 1
        }
        await store.receive(\.marketNoteListReponse) {
            $0.marketNoteList = .mock
        }
        await store.receive(\.handleResponseCount) {
            $0.responseCount += 1
            $0.isLoading = false
        }
        await store.receive(\.assignPurchaseHistoryNoteList) {
            let list = $0.marketNoteList.map { note in
                PurchaseHistoryNote(note: note,
                                    isReviewed: false) // mock 데이터 상으로는 false
            }
            $0.purchaseHistoryNoteList = .init(uniqueElements: list)
        }
    }
    
    @MainActor
    func test_backButtonTapped() async {
        let isDismissInvoked: LockIsolated<[Bool]> = .init([])
        let store = TestStore(
            initialState: PurchaseHistoryFeature.State(noteList: .mock),
            reducer: { PurchaseHistoryFeature() },
            withDependencies: {
                $0.dismiss = DismissEffect { isDismissInvoked.withValue { $0.append(true) }}
                $0.uuid = .incrementing
                $0.date.now = Date(timeIntervalSince1970: 1234567890)
            }
        )
        
        await store.send(\.view.backButtonTapped)
        XCTAssertEqual(isDismissInvoked.value, [true])
    }
    
}


