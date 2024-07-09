import ComposableArchitecture
import StudyFeature
import XCTest

final class StudyFeatureTest: XCTestCase {
    
    @MainActor
    func test_backButtonTapped() async {
        let isDismissInvoked: LockIsolated<[Bool]> = .init([])
        let store = TestStore(
            initialState: StudyFeature.State.init(note: .mock),
            reducer: { StudyFeature() },
            withDependencies: {
                $0.dismiss = DismissEffect { isDismissInvoked.withValue { $0.append(true) }}
                $0.date.now = Date(timeIntervalSince1970: 0)
                $0.uuid = .constant(.zero)
            }
        )
        
        await store.send(\.view.backButtonTapped)
        XCTAssertEqual(isDismissInvoked.value, [true])
    }
    
    @MainActor
    func test_endButtonTapped() async {
        let isDismissInvoked: LockIsolated<[Bool]> = .init([])
        let store = TestStore(
            initialState: StudyFeature.State.init(note: .mock),
            reducer: { StudyFeature() },
            withDependencies: {
                $0.dismiss = DismissEffect { isDismissInvoked.withValue { $0.append(true) }}
                $0.date.now = Date(timeIntervalSince1970: 0)
                $0.uuid = .constant(.zero)
            }
        )
        
        await store.send(\.view.endButtonTapped)
        XCTAssertEqual(isDismissInvoked.value, [true])
    }
    
    @MainActor
    func studyFinishButtonTapped() async {
        let isDismissInvoked: LockIsolated<[Bool]> = .init([])
        let store = TestStore(
            initialState: StudyFeature.State.init(note: .mock),
            reducer: { StudyFeature() },
            withDependencies: {
                $0.dismiss = DismissEffect { isDismissInvoked.withValue { $0.append(true) }}
                $0.date.now = Date(timeIntervalSince1970: 0)
                $0.uuid = .constant(.zero)
            }
        )
        
        await store.send(\.view.studyFinishButtonTapped)
        XCTAssertEqual(isDismissInvoked.value, [true])
    }
    
    @MainActor
    func test_studyResetButtonTapped() async {
        let isDismissInvoked: LockIsolated<[Bool]> = .init([])
        let store = TestStore(
            initialState: StudyFeature.State.init(note: .mock),
            reducer: { StudyFeature() },
            withDependencies: {
                $0.dismiss = DismissEffect { isDismissInvoked.withValue { $0.append(true) }}
                $0.date.now = Date(timeIntervalSince1970: 0)
                $0.uuid = .constant(.zero)
            }
        )
        
        await store.send(\.view.studyResetButtonTapped)
        XCTAssertEqual(isDismissInvoked.value, [true])
    }
    
    @MainActor
    func test_wordTapped() async {
        let store = TestStore(
            initialState: StudyFeature.State.init(note: .mock),
            reducer: { StudyFeature() },
            withDependencies: {
                $0.date.now = Date(timeIntervalSince1970: 0)
                $0.uuid = .constant(.zero)
            }
        )
        
        await store.send(\.view.wordTapped) {
            $0.isWordConverted.toggle()
        }
        
    }
    
    @MainActor
    func test_first_or_last_study() async {
        let store = TestStore(
            initialState: StudyFeature.State.init(
                note: .init(
                    noteName: "영단어 암기장",
                    noteCategory: .english,
                    enrollmentUser: "",
                    wordList: [
                        .init(
                            wordString: "",
                            wordMeaning: ""
                        ),
                        .init(
                            wordString: "",
                            wordMeaning: ""
                        )
                    ]
                )
            ),
            reducer: { StudyFeature() },
            withDependencies: {
                $0.date.now = Date(timeIntervalSince1970: 0)
                $0.uuid = .constant(.zero)
            }
        )
        
        await store.send(.view(.levelButtonTapped(.easy))) {
            $0.note.wordList[$0.currentWordIdx].wordLevel = 2
            $0.currentWordIdx += 1
        }
        await store.send(.view(.levelButtonTapped(.normal))) {
            $0.note.wordList[$0.currentWordIdx].wordLevel = 1
        }
        await store.receive(\.studyComplete) {
            $0.isStudyCompleted = true
        }
    }
    
    @MainActor
    func test_middle_study() async {
        let store = TestStore(
            initialState: StudyFeature.State.init(
                note: .init(
                    noteName: "영단어 암기장",
                    noteCategory: .english,
                    enrollmentUser: "",
                    repeatCount: 1,
                    wordList: [
                        .init(
                            wordString: "",
                            wordMeaning: ""
                        ),
                        .init(
                            wordString: "",
                            wordMeaning: ""
                        )
                    ]
                )
            ),
            reducer: { StudyFeature() },
            withDependencies: {
                $0.date.now = Date(timeIntervalSince1970: 0)
                $0.uuid = .constant(.zero)
            }
        )
        
        // state change noting
        await store.send(\.view.beforeButtonTapped)
        await store.send(\.view.nextButtonTapped) {
            $0.currentWordIdx += 1
        }
        await store.send(\.view.beforeButtonTapped) {
            $0.currentWordIdx -= 1
        }
        await store.send(\.view.nextButtonTapped) {
            $0.currentWordIdx += 1
        }
        await store.send(\.view.nextButtonTapped)
        await store.receive(\.studyComplete) {
            $0.isStudyCompleted = true
        }
    }
    
    @MainActor
    func test_onChange() async {
        let store = TestStore(
            initialState: StudyFeature.State.init(
                note: .mock
            ),
            reducer: { StudyFeature() },
            withDependencies: {
                $0.date.now = Date(timeIntervalSince1970: 0)
                $0.uuid = .constant(.zero)
            }
        )
        
        await store.send(\.view.wordTapped) {
            $0.isWordConverted = true
        }
        await store.send(\.view.nextButtonTapped) {
            $0.currentWordIdx += 1
            $0.isWordConverted = false
        }
    }
    
}
