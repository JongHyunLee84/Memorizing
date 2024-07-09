import ComposableArchitecture
import Extensions
import Models
import StudyFeature
import XCTest

final class LoginFeatureTest: XCTestCase {
    @MainActor
    func test_cannot_save_without_noteName() async {
        let isDismissInvoked: LockIsolated<[Bool]> = .init([])
        let clock = TestClock()
        let store = TestStore(
            initialState: AddNoteFeature.State.init(),
            reducer: { AddNoteFeature() },
            withDependencies: {
                $0.dismiss = DismissEffect { isDismissInvoked.withValue { $0.append(true) }}
                $0.continuousClock = clock
            }
        )
        
        await store.send(\.view.saveButtonTapped)
        await clock.advance(by: .seconds(0.3))
        await store.receive(\.sendToastMessage) {
            $0.toastMessage = "암기장 이름을 입력해주세요"
        }
        await store.send(\.view.binding.toastMessage, nil) {
            $0.toastMessage = nil
        }
        
        
        await store.send(\.view.binding.noteName, "영단어 암기장") {
            $0.noteName = "영단어 암기장"
        }
        await store.send(\.view.saveButtonTapped)
        await store.receive(\.addNoteDelegate)
        
        XCTAssertEqual(isDismissInvoked.value, [true])
    }
    
    @MainActor
    func test_xButton_Tapped() async {
        let isDismissInvoked: LockIsolated<[Bool]> = .init([])
        let store = TestStore(
            initialState: AddNoteFeature.State.init(),
            reducer: { AddNoteFeature() },
            withDependencies: {
                $0.dismiss = DismissEffect { isDismissInvoked.withValue { $0.append(true) }}
            }
        )
        
        await store.send(\.view.xButtonTapped)
        XCTAssertEqual(isDismissInvoked.value, [true])
    }
    
    @MainActor
    func test_add_Note_success() async {
        let isDismissInvoked: LockIsolated<[Bool]> = .init([])
        let store = TestStore(
            initialState: AddNoteFeature.State.init(),
            reducer: { AddNoteFeature() },
            withDependencies: {
                $0.uuid = .constant(.zero)
                $0.dismiss = DismissEffect { isDismissInvoked.withValue { $0.append(true) }}
            }
        )
        
        await store.send(\.view.binding.noteName, "영단어 암기장") {
            $0.noteName = "영단어 암기장"
        }
        await store.send(.view(.categoryButtonTapped(.english)))
        await store.send(\.view.binding.wordName, "Apple") {
            $0.wordName = "Apple"
        }
        await store.send(\.view.binding.wordMeaning, "사과") {
            $0.wordMeaning = "사과"
        }
        await store.send(\.view.addWordButtonTapped) {
            $0.wordList.append(.init(wordString: "Apple",
                                     wordMeaning: "사과"))
            $0.wordName = ""
            $0.wordMeaning = ""
        }
        await store.send(\.view.saveButtonTapped)
        await store.receive(\.addNoteDelegate)
        
        XCTAssertEqual(isDismissInvoked.value, [true])
    }
    
    @MainActor
    func test_word_limitation() async {
        let clock = TestClock()
        let store = TestStore(
            initialState: AddNoteFeature.State.init(),
            reducer: { AddNoteFeature() },
            withDependencies: {
                $0.continuousClock = clock
            }
        )
        
        let text = (0...50).map { "\($0)" }.joined()
        await store.send(\.view.binding.wordName, text) {
            $0.wordName = String(text.prefix(50))
        }
        await clock.advance(by: .seconds(0.3))
        await store.receive(\.sendToastMessage) {
            $0.toastMessage = "최대 50글자까지만 입력해주세요."
        }
        await store.send(\.view.binding.toastMessage, nil) {
            $0.toastMessage = nil
        }
        
        await store.send(\.view.binding.wordMeaning, text) {
            $0.wordMeaning = String(text.prefix(50))
        }
        await clock.advance(by: .seconds(0.3))
        await store.receive(\.sendToastMessage) {
            $0.toastMessage = "최대 50글자까지만 입력해주세요."
        }
        await store.send(\.view.binding.toastMessage, nil) {
            $0.toastMessage = nil
        }
    }
    
    @MainActor
    func test_word_list_limitation() async {
        let clock = TestClock()
        let store = TestStore(
            initialState: AddNoteFeature.State.init(
                wordName: "Apple",
                wordMeaning: "사과",
                wordList: (1...50).map { .init(wordString: "\($0)",
                                               wordMeaning: "\($0)") }
            ),
            reducer: { AddNoteFeature() },
            withDependencies: {
                $0.continuousClock = clock
                $0.uuid = .constant(.zero)
            }
        )
        
        await store.send(\.view.addWordButtonTapped)
        await clock.advance(by: .seconds(0.3))
        await store.receive(\.sendToastMessage) {
            $0.toastMessage = "최대 50개까지만 추가해주세요."
        }
    }
    
    @MainActor
    func test_toastMessage_cancellable()  async {
        let clock = TestClock()
        let text = (1...50).map { _ in "0" }.joined()

        let store = TestStore(
            initialState: AddNoteFeature.State.init(),
            reducer: { AddNoteFeature() },
            withDependencies: {
                $0.continuousClock = clock
            }
        )
        
        await store.send(\.view.binding.wordName, text + " ") {
            $0.wordName = text
        }
        await clock.advance(by: .seconds(0.25))
        // cancel effect
        await store.send(\.view.binding.wordName, text + " ")
        await clock.advance(by: .seconds(0.3))
        // receive effect
        await store.receive(\.sendToastMessage) {
            $0.toastMessage = "최대 50글자까지만 입력해주세요."
        }
    }
}
