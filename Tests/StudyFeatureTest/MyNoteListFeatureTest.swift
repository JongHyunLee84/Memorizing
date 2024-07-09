import ComposableArchitecture
import Extensions
import Models
import StudyFeature
import XCTest

final class MyNoteListFeatureTest: XCTestCase {
    @MainActor
    func test_onAppear() async {
        @Shared(.currentUser) var currentUser
        $currentUser.withLock { $0 = .mock }
        
        let store = TestStore(
            initialState: MyNoteListFeature.State.init(),
            reducer: { MyNoteListFeature() },
            withDependencies: {
                $0.date.now = Date(timeIntervalSince1970: 1234567890)
                $0.uuid = .constant(.zero)
            }
        )
                
        await store.send(\.view.onAppear)
        await store.receive(\.noteListResponse) {
            $0.noteList = .mock
        }
    }
    
    @MainActor
    func test_integration() async {
        @Shared(.currentUser) var currentUser
        $currentUser.withLock { $0 = .mock }
        
        let store = TestStore(
            initialState: MyNoteListFeature.State.init(),
            reducer: { MyNoteListFeature() },
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
        await store.send(\.destination.addNote.view.saveButtonTapped)
        await store.receive(\.destination.presented.addNote.addNoteDelegate) {
            let userID = $0.currentUser?.id ?? UUID.zero.uuidString
            $0.noteList.append(.init(noteName: "영단어 암기장",
                                     noteCategory: .english,
                                     enrollmentUser: userID,
                                     wordList: []))
        }
        await store.receive(\.destination.dismiss) {
            $0.destination = nil
        }
    }
    
    @MainActor
    func test_showOnlyStudingNote() async {
        let store = TestStore(
            initialState: MyNoteListFeature.State.init(),
            reducer: { MyNoteListFeature() }
        )
        
        await store.send(\.view.showOnlyStudyingNoteButtonTapped) {
            $0.showOnlyStudyingNote = true
        }
        await store.send(\.view.showOnlyStudyingNoteButtonTapped) {
            $0.showOnlyStudyingNote = false
        }
    }
}
