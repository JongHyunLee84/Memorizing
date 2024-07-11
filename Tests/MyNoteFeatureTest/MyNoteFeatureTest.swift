import AddNoteFeature
import ComposableArchitecture
import Extensions
import Models
import MyNoteFeature
import XCTest

final class MyNoteFeatureTest: XCTestCase {
    @MainActor
    func test_onAppear() async {
        @Shared(.currentUser) var currentUser
        $currentUser.withLock { $0 = .mock }
        
        let store = TestStore(
            initialState: MyNoteFeature.State.init(),
            reducer: { MyNoteFeature() },
            withDependencies: {
                $0.date.now = Date(timeIntervalSince1970: 1234567890)
                $0.uuid = .incrementing
            }
        )
        
        await store.send(\.view.onFirstAppear)
        await store.receive(\.noteListResponse) {
            $0.noteList = .init(uniqueElements: [.mock, .mock3, .mock2])
        }
        
        await store.send(\.view.onAppear) {
            $0.noteList.sort()
        }
    }
    
    @MainActor
    func test_add_note_feature_integration() async {
        @Shared(.currentUser) var currentUser
        $currentUser.withLock { $0 = .mock }
        
        let store = TestStore(
            initialState: MyNoteFeature.State.init(),
            reducer: { MyNoteFeature() },
            withDependencies: {
                $0.date.now = Date(timeIntervalSince1970: 1234567890)
                $0.uuid = .constant(.zero)
            }
        )
        
        await store.send(\.view.plusButtonTapped) {
            $0.destination = .addNote(.init())
        }
        
        await store.send(\.destination.addNote.view.binding.noteName, "영단어 암기장") {
            $0.destination?.addNote?.noteName = "영단어 암기장"
        }
        await store.send(\.destination.addNote.view.saveButtonTapped) {
            let userID = $0.currentUser?.id ?? UUID.zero.uuidString
            $0.noteList.append(.init(noteName: "영단어 암기장",
                                     noteCategory: .english,
                                     enrollmentUser: userID,
                                     wordList: []))
        }
        await store.receive(\.destination.dismiss) {
            $0.destination = nil
        }
        let newNote = store.state.$noteList.withLock { $0[0] }
        await store.send(\.view.noteTapped, newNote) {
            $0.destination = .addNote(.init(note: newNote))
        }
        await store.send(\.destination.addNote.view.binding.wordName, "토익 영단어") {
            $0.destination?.addNote?.wordName = "토익 영단어"
        }
        await store.send(\.destination.addNote.view.saveButtonTapped) {
            guard let note = $0.destination?.addNote?.note else {
                XCTFail("NO Note In AddNoteFeature.State")
                return
            }
            $0.noteList.updateOrAppend(note)
        }
        await store.receive(\.destination.dismiss) {
            $0.destination = nil
        }
    }
    
    @MainActor
    func test_showOnlyStudingNote() async {
        let store = TestStore(
            initialState: MyNoteFeature.State.init(),
            reducer: { MyNoteFeature() }
        )
        
        await store.send(\.view.showOnlyStudyingNoteButtonTapped) {
            $0.showOnlyStudyingNote = true
        }
        await store.send(\.view.showOnlyStudyingNoteButtonTapped) {
            $0.showOnlyStudyingNote = false
        }
    }
    
    @MainActor
    func test_studyNote_integration() async throws {

        let store = TestStore(
            initialState: MyNoteFeature.State.init(),
            reducer: { MyNoteFeature() }
        )
        
        let sharedNote = Shared(Note.mock)
        
        await store.send(\.view.studyButtonTapped, sharedNote) {
            $0.path.append(.study(.init(note: sharedNote)))
            $0.currentStudyingNoteID = sharedNote.id
        }
        await store.send(\.path.popFrom, 0) {
            $0.path.removeLast()
            $0.currentStudyingNoteID = nil
        }
    }
    
    
}
