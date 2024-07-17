import AddMarketFeature
import ComposableArchitecture
import MarketFeature
import Models
import XCTest

final class MarketFeatureTest: XCTestCase {

    @MainActor
    func test_onAppear() async {
        let store = TestStore(initialState: MarketFeature.State.init(),
                              reducer: { MarketFeature() },
                              withDependencies: {
            $0.uuid = .incrementing
            $0.date.now = Date(timeIntervalSince1970: 1234567890)
        }
        )
        await store.send(\.view.onFirstAppear)
        await store.receive(\.marketNoteRequest)
        await store.receive(\.marketNoteListResponse) {
            $0.noteList = .init(uniqueElements: MarketNoteList.mock)
            $0.queriedNoteList = .init(uniqueElements: MarketNoteList.mock)
        }
    }
    
    @MainActor
    func test_coinButtonTapped() async {
        let store = TestStore(initialState: MarketFeature.State.init(),
                              reducer: { MarketFeature() }
        )
        await store.send(.view(.coinButtonTapped)) {
            $0.destination = .alert(.coin)
        }
    }
    
    @MainActor
    func test_query_note_list() async {
        let store = TestStore(
            initialState: MarketFeature.State.init(
                noteList: .mock
            ),
            reducer: { MarketFeature() },
            withDependencies: {
                $0.uuid = .incrementing
                $0.date.now = Date(timeIntervalSince1970: 1234567890)
            }
        )
        
        await store.send(\.view.binding.noteQuery, "영어") {
            $0.noteQuery = "영어"
        }
        await store.send(\.view.searchButtonTapped) {
            $0.queriedNoteList.removeLast()
        }
        await store.send(\.view.binding.noteQuery, "") {
            $0.noteQuery = ""
            $0.queriedNoteList = $0.noteList
        }
        await store.send(\.view.categoryButtonTapped, .etc) {
            $0.marketCategory = .etc
            $0.queriedNoteList.removeFirst()
        }
    }
    
    @MainActor
    func test_sort_note_list() async {
        let store = TestStore(
            initialState: MarketFeature.State.init(
                noteList: .mock
            ),
            reducer: { MarketFeature() },
            withDependencies: {
                $0.uuid = .incrementing
                $0.date.now = Date(timeIntervalSince1970: 1234567890)
            }
        )
        
        await store.send(\.view.sortButtonTapped, .sellCount) {
            $0.sortType = .sellCount
            $0.queriedNoteList.reverse()
        }
    }
    
    @MainActor
    func test_AddMarketFeature_Integration() async {
        let clock = TestClock()
        @Shared(.currentUser) var currentUser
        $currentUser.withLock { $0 = .mock }
        let store = TestStore(
            initialState: MarketFeature.State.init(),
            reducer: { MarketFeature() },
            withDependencies: {
                $0.uuid = .incrementing
                $0.date.now = Date(timeIntervalSince1970: 1234567890)
                $0.continuousClock = clock
            }
        )
        
        store.exhaustivity = .off
        
        await store.send(\.view.plusButtonTapped) {
            $0.destination = .addMarket(AddMarketFeature.State())
        }
        await store.send(\.destination.addMarket.view.binding.priceStr, "123")
        // noteTapped에서 기존 noteList를 미리 생성시켜놓기 위해
        await store.send(\.destination.addMarket.view.onFirstAppear)
        await store.send(\.destination.addMarket.view.noteTapped, .mock)
        await store.send(\.destination.presented.addMarket.view.addButtonTapped) {
            $0.destination?.addMarket?.isInFlight = true
        }
        await store.receive(\.marketNoteListResponse) {
            $0.noteList = .init(uniqueElements: MarketNoteList.mock)
            $0.queriedNoteList = .init(uniqueElements: MarketNoteList.mock)
        }
        await store.receive(\.destination.dismiss) {
            $0.destination = nil
        }
        
    }
}
