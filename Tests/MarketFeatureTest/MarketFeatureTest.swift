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
            $0.queriedNoteList.remove(id: "00000000-0000-0000-0000-000000000003")
        }
        await store.send(\.view.binding.noteQuery, "") {
            $0.noteQuery = ""
            $0.queriedNoteList = $0.noteList
        }
        await store.send(\.view.categoryButtonTapped, .etc) {
            $0.marketCategory = .etc
            $0.queriedNoteList.remove(id: "00000000-0000-0000-0000-000000000000")
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
}
