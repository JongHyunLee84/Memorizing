import AddMarketFeature
import ComposableArchitecture
import MarketClient
import Models
import Shared
import XCTest

final class AddMarketFeatureTest: XCTestCase {
    @MainActor
    func test_on_first_appear() async {
        @Shared(.currentUser) var currentUser
        $currentUser.withLock { $0 = .mock }
        
        let store = TestStore(
            initialState: AddMarketFeature.State(),
            reducer: { AddMarketFeature() },
            withDependencies: {
                $0.uuid = .incrementing
                $0.date.now = Date(timeIntervalSince1970: 1234567890)
            }
        )
        
        await store.send(\.view.onFirstAppear)
        await store.receive(\.noteListResponse) {
            $0.noteList = .init(uniqueElements: NoteList.mock)
        }
    }
    
    @MainActor
    func test_backButtonTapped() async {
        let isDismissInvoked: LockIsolated<[Bool]> = .init([])
        let store = TestStore(
            initialState: AddMarketFeature.State(),
            reducer: { AddMarketFeature() },
            withDependencies: {
                $0.dismiss = DismissEffect { isDismissInvoked.withValue {
                    $0.append(true)
                }
                }
            }
        )
        
        await store.send(\.view.backButtonTapped)
        XCTAssertEqual(isDismissInvoked.value, [true])
    }
    
    @MainActor
    func test_note_tapped() async {
        let store = TestStore(
            initialState: AddMarketFeature.State(
                noteList: .mock
            ),
            reducer: { AddMarketFeature() },
            withDependencies: {
                $0.uuid = .incrementing
                $0.date.now = Date(timeIntervalSince1970: 1234567890)
            }
        )
        
        await store.send(\.view.noteTapped, .mock) {
            $0.selectedNote = .mock
        }
        await store.send(\.view.noteTapped, .mock) {
            $0.selectedNote = nil
        }
    }
    
    @MainActor
    func test_note_priceStr() async {
        let clock = TestClock()
        let store = TestStore(
            initialState: AddMarketFeature.State(),
            reducer: { AddMarketFeature() },
            withDependencies: {
                $0.continuousClock = clock
            }
        )
        
        // Filtering
        await store.send(\.view.binding.priceStr, "no price str") {
            $0.priceStr = "no price str"
        }
        await clock.advance(by: .seconds(0.5))
        await store.receive(\.editPriceStr) {
            $0.priceStr = ""
        }
        
        // Debounce
        await store.send(\.view.binding.priceStr, "3") {
            $0.priceStr = "3"
        }
        await clock.advance(by: .seconds(0.4))
        await store.send(\.view.binding.priceStr, "30") {
            $0.priceStr = "30"
        }
        await clock.advance(by: .seconds(0.5))
        await store.receive(\.editPriceStr) {
            $0.priceStr = "30P"
        }
        
    }
    
    @MainActor
    func test_add_note_process() async {
        let isDismissInvoked: LockIsolated<[Bool]> = .init([])
        let clock = TestClock()
        let store = TestStore(
            initialState: AddMarketFeature.State(
                noteList: .mock
            ),
            reducer: { AddMarketFeature() },
            withDependencies: {
                $0.uuid = .incrementing
                $0.date.now = Date(timeIntervalSince1970: 1234567890)
                $0.continuousClock = clock
                $0.dismiss = DismissEffect {
                    isDismissInvoked.withValue {
                        $0.append(true)
                    }
                }
            }
        )
        
        // Button Disable without selectedNote, priceStr
        await store.send(\.view.addButtonTapped)
        await store.send(\.view.noteTapped, .mock) {
            $0.selectedNote = .mock
        }
        await store.send(\.view.addButtonTapped)
        await store.send(\.view.binding.priceStr, "100") {
            $0.priceStr = "100"
        }
        await clock.advance(by: .seconds(0.5))
        await store.receive(\.editPriceStr) {
            $0.priceStr = "100P"
        }
        await store.send(\.view.addButtonTapped) {
            $0.isInFlight = true
        }
        XCTAssertEqual(isDismissInvoked.value, [true])
    }
    
}
