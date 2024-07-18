import ComposableArchitecture
import MarketNoteDetailFeature
import XCTest

final class ReviewListFeatureTest: XCTestCase {

    @MainActor
    func test_backButtonTapped() async {
        let isDismissInvoked: LockIsolated<[Bool]> = .init([])
        let store = TestStore(
            initialState: ReviewListFeature.State(
                note: .mock,
                reviewList: .mock
            ),
            reducer: { ReviewListFeature() },
            withDependencies: {
                $0.uuid = .incrementing
                $0.date.now = Date(timeIntervalSince1970: 1234567890)
                $0.dismiss = DismissEffect { isDismissInvoked.withValue {
                    $0.append(true)
                }
                }
            }
        )
        
        await store.send(\.view.backButtonTapped)
        XCTAssertEqual(isDismissInvoked.value, [true])
    }
    
}
