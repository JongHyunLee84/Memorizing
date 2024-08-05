import ComposableArchitecture
import ProfileFeature
import Shared
import URLClient
import XCTest

final class ProfileFeatureTest: XCTestCase {
    @MainActor
    func test_onFirstAppear() async {
        @Shared(.currentUser) var currentUser
        $currentUser.withLock { $0 = .mock }
        let store = TestStore(
            initialState: ProfileFeature.State(),
            reducer: { ProfileFeature() },
            withDependencies: {
                $0.uuid = .incrementing
                $0.date.now = Date(timeIntervalSince1970: 1234567890)
            }
        )
        
        await store.send(\.view.onFirstAppear)
        await store.receive(\.noteListResponse) {
            $0.myNoteList = .mock
        }
        await store.receive(\.webviewURLResponse) {
            $0.introduceURL = mockURL
            $0.privacyPolicyURL = mockURL
            $0.csURL = mockURL
        }
    }
    
    @MainActor
    func test_editProfileButtonTapped() async {
        let store = TestStore(
            initialState: ProfileFeature.State(),
            reducer: { ProfileFeature() }
        )
        
        await store.send(\.view.editProfileButtonTapped) {
            $0.path.append(.editProfile(.init()))
        }
    }
    
    @MainActor
    func test_purchaseHistoryButtonTapped() async {
        let store = TestStore(
            initialState: ProfileFeature.State(),
            reducer: { ProfileFeature() }
        )
        
        await store.send(\.view.purchaseHistoryButtonTapped) {
            $0.path.append(.purchaseHistory(.init(noteList: $0.myNoteList)))
        }
    }
    
    @MainActor
    func test_purchaseHistory_writeReview_integration() async {
        @Shared(.currentUser) var currentUser
        $currentUser.withLock { $0 = .mock }
        let clock = TestClock()
        let store = TestStore(
            initialState: ProfileFeature.State(),
            reducer: { ProfileFeature() },
            withDependencies: {
                $0.uuid = .incrementing
                $0.date.now = Date(timeIntervalSince1970: 1234567890)
                $0.continuousClock = clock
            }
        )
        
        store.exhaustivity = .off(showSkippedAssertions: true)
        
        await store.send(\.view.purchaseHistoryButtonTapped)
        await store.send(\.path[id: 0].purchaseHistory.view.onAppear)
        await store.receive(\.path[id: 0].purchaseHistory.myReviewListResponse)
        await store.receive(\.path[id: 0].purchaseHistory.handleResponseCount)
        await store.receive(\.path[id: 0].purchaseHistory.marketNoteListReponse)
        await store.receive(\.path[id: 0].purchaseHistory.handleResponseCount)
        await store.receive(\.path[id: 0].purchaseHistory.assignPurchaseHistoryNoteList)
        guard let willReviewNote = store.state.path[id: 0]?.purchaseHistory?.purchaseHistoryNoteList.first else {
            XCTFail("note does not exist")
            return
        }
        await store.send(\.path[id: 0].purchaseHistory.view.writeReviewButtonTapped, willReviewNote.id)
        XCTAssertEqual(store.state.path.count, 2)
        
        await store.send(\.path[id: 1].writeReview.view.confirmButtonTapped)
        await clock.advance(by: .seconds(1))
        await store.receive(\.path.popFrom)
        XCTAssertEqual(store.state.path.count, 1)
    }
    
    @MainActor
    func test_myReviewsButtonTapped() async {
        let store = TestStore(
            initialState: ProfileFeature.State(),
            reducer: { ProfileFeature() }
        )
        
        await store.send(\.view.myReviewsButtonTapped) {
            $0.path.append(.reviewHistory(.init()))
        }
    }
    
    @MainActor
    func test_destination_buttons_tapped() async {
        let store = TestStore(
            initialState: ProfileFeature.State(),
            reducer: { ProfileFeature() }
        )
        
        await store.send(\.view.aboutMemorizingButtonTapped) {
            $0.destination = .aboutMemorizing
        }
        await store.send(\.destination.dismiss) {
            $0.destination = nil
        }
        await store.send(\.view.csButtonTapped) {
            $0.destination = .cs
        }
        await store.send(\.destination.dismiss) {
            $0.destination = nil
        }
        await store.send(\.view.privacyPolicyButtonTapped) {
            $0.destination = .privacyPolicy
        }
    }
    
    @MainActor
    func test_logoutButtonTapped() async {
        let store = TestStore(
            initialState: ProfileFeature.State(),
            reducer: { ProfileFeature() }
        )
        
        // cancel
        await store.send(\.view.logoutButtonTapped) {
            $0.destination = .alert(.logout)
        }
        await store.send(\.destination.dismiss) {
            $0.destination = nil
        }
        // confirm
        await store.send(\.view.logoutButtonTapped) {
            $0.destination = .alert(.logout)
        }
        await store.send(\.destination.alert.logout) {
            $0.currentUser = nil
            $0.destination = nil
        }
    }
    
}
