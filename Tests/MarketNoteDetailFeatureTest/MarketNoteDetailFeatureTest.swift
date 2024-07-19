import ComposableArchitecture
import MarketNoteDetailFeature
import XCTest

final class MarketNoteDetailFeatureTest: XCTestCase {

    @MainActor
    func test_xButtonTapped() async {
        let isDismissInvoked: LockIsolated<[Bool]> = .init([])
        let store = TestStore(
            initialState: MarketNoteDetailFeature.State(
                note: .mock
            ),
            reducer: { MarketNoteDetailFeature() },
            withDependencies: {
                $0.date.now = Date(timeIntervalSince1970: 1234567890)
                $0.uuid = .incrementing
                $0.dismiss = DismissEffect {
                    isDismissInvoked.withValue {
                        $0.append(true)
                    }
                }
            }
        )
        
        await store.send(.view(.xButtonTapped))
        XCTAssertEqual(isDismissInvoked.value, [true])
    }
    
    @MainActor
    func test_purchase_success_case() async {
        let isDismissInvoked: LockIsolated<[Bool]> = .init([])
        let clock = TestClock()
        @Shared(.currentUser) var currentUser
        $currentUser.withLock { $0 = .mock } // 유저의 포인트 = 1000
        
        let store = TestStore(
            initialState: MarketNoteDetailFeature.State(
                note: .mock // 노트 가격 = 1000
            ),
            reducer: { MarketNoteDetailFeature() },
            withDependencies: {
                $0.date.now = Date(timeIntervalSince1970: 1234567890)
                $0.uuid = .incrementing
                $0.dismiss = DismissEffect {
                    isDismissInvoked.withValue {
                        $0.append(true)
                    }
                }
                $0.continuousClock = clock
            }
        )
        
        await store.send(\.view.purchaseButtonTapped) {
            $0.isInFlight = true
        }
        await store.receive(\.isInFlightFinish) {
            $0.isInFlight = false
            $0.currentUser?.coin = 0
        }
        await store.receive(\.sendToastMessage) {
            $0.toastMessage = "구매가 완료되었어요."
        }
        await clock.advance(by: .seconds(1))
        XCTAssertEqual(isDismissInvoked.value, [true])
    }
    
    @MainActor
    func test_purchase_failure_case() async {
        @Shared(.currentUser) var currentUser
        $currentUser.withLock { 
            $0 = .mock
            $0?.coin = 900 // 유저의 포인트 = 900
        }
        
        let store = TestStore(
            initialState: MarketNoteDetailFeature.State(
                note: .mock // 노트 가격 = 1000
            ),
            reducer: { MarketNoteDetailFeature() },
            withDependencies: {
                $0.date.now = Date(timeIntervalSince1970: 1234567890)
                $0.uuid = .incrementing
                $0.marketClient.getIsBuyable = { @Sendable _, _ in
                    return false
                }
            }
        )
        await store.send(\.view.purchaseButtonTapped) {
            $0.isInFlight = true
        }
        await store.receive(\.isInFlightFinish) {
            $0.isInFlight = false
        }
        await store.receive(\.sendToastMessage) {
            $0.toastMessage = "보유하신 포인트가 부족해요."
        }
    }
    
    @MainActor
    func test_onFirstAppear() async {
        let store = TestStore(
            initialState: MarketNoteDetailFeature.State(
                note: .mock
            ),
            reducer: { MarketNoteDetailFeature() },
            withDependencies: {
                $0.date.now = Date(timeIntervalSince1970: 1234567890)
                $0.uuid = .incrementing
            }
        )
        
        await store.send(\.view.onFirstAppear)
        await store.receive(\.reviewListResponse) {
            $0.reviewList = .mock
        }
    }
    
    @MainActor
    func test_reviewListFeature_integration() async {
        let store = TestStore(
            initialState: MarketNoteDetailFeature.State(
                note: .mock
            ),
            reducer: { MarketNoteDetailFeature() },
            withDependencies: {
                $0.date.now = Date(timeIntervalSince1970: 1234567890)
                $0.uuid = .incrementing
            }
        )
        
        await store.send(\.view.watchMoreReviewsButtonTapped) {
            $0.path.append(.reviewList(.init(note: $0.note,
                                             reviewList: $0.reviewList)))
        }
        
        await store.send(\.path[id: 0].reviewList.view.backButtonTapped)
        await store.receive(\.path.popFrom) {
            $0.path.removeLast()
        }
    }
}
