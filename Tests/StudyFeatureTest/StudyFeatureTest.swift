import ComposableArchitecture
import Models
import StudyFeature
import XCTest

final class StudyFeatureTest: XCTestCase {
    
    @MainActor
    func test_backButtonTapped() async {
        let isDismissInvoked: LockIsolated<[Bool]> = .init([])
        let store = TestStore(
            initialState: StudyFeature.State.init(note: Shared(.mock)),
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
            initialState: StudyFeature.State.init(note: Shared(.mock)),
            reducer: { StudyFeature() },
            withDependencies: {
                $0.dismiss = DismissEffect { isDismissInvoked.withValue { $0.append(true) }}
                $0.date.now = Date(timeIntervalSince1970: 0)
                $0.uuid = .constant(.zero)
            }
        )
        
        await store.send(\.view.endButtonTapped) {
            $0.note.repeatCount += 1
        }
        XCTAssertEqual(isDismissInvoked.value, [true])
    }
    
    @MainActor
    func test_studyFinishButtonTapped_with_first_study() async {
        let isDismissInvoked: LockIsolated<[Bool]> = .init([])
        let store = TestStore(
            initialState: StudyFeature.State.init(note: Shared(.firstStudyMock)),
            reducer: { StudyFeature() },
            withDependencies: {
                $0.dismiss = DismissEffect { isDismissInvoked.withValue { $0.append(true) }}
                $0.date.now = Date(timeIntervalSince1970: 0)
                $0.uuid = .constant(.zero)
            }
        )
        store.exhaustivity = .off
        await store.send(.view(.levelButtonTapped(.easy)))
        await store.send(.view(.levelButtonTapped(.easy)))
        await store.send(\.view.studyFinishButtonTapped) {
            $0.note.firstTestResult = $0.testResult
            $0.note.repeatCount = 1
        }
        XCTAssertEqual(isDismissInvoked.value, [true])
    }
    
    @MainActor
    func test_studyFinishButtonTapped_with_last_study() async {
        let isDismissInvoked: LockIsolated<[Bool]> = .init([])
        let store = TestStore(
            initialState: StudyFeature.State.init(note: Shared(.lastStudyMock)),
            reducer: { StudyFeature() },
            withDependencies: {
                $0.dismiss = DismissEffect { isDismissInvoked.withValue { $0.append(true) }}
                $0.date.now = Date(timeIntervalSince1970: 0)
                $0.uuid = .constant(.zero)
            }
        )
        store.exhaustivity = .off
        await store.send(.view(.levelButtonTapped(.easy)))
        await store.send(.view(.levelButtonTapped(.easy)))
        await store.send(\.view.studyFinishButtonTapped) {
            $0.note.lastTestResult = $0.testResult
            $0.note.repeatCount = 3
        }
        XCTAssertEqual(isDismissInvoked.value, [true])
    }
    
    @MainActor
    func test_studyResetButtonTapped() async {
        let isDismissInvoked: LockIsolated<[Bool]> = .init([])
        let store = TestStore(
            initialState: StudyFeature.State.init(note: Shared(.mock)),
            reducer: { StudyFeature() },
            withDependencies: {
                $0.dismiss = DismissEffect { isDismissInvoked.withValue { $0.append(true) }}
                $0.date.now = Date(timeIntervalSince1970: 0)
                $0.uuid = .constant(.zero)
            }
        )
        
        await store.send(\.view.studyResetButtonTapped) {
            $0.note.repeatCount = 0
            $0.note.firstTestResult = 0
            $0.note.lastTestResult = 0
        }
        XCTAssertEqual(isDismissInvoked.value, [true])
    }
    
    @MainActor
    func test_wordTapped() async {
        let store = TestStore(
            initialState: StudyFeature.State.init(note: Shared(.mock)),
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
                note: Shared(.init(
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
            )),
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
                note: Shared(.init(
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
            )),
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
            initialState: StudyFeature.State.init(note: Shared(.mock)),
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
