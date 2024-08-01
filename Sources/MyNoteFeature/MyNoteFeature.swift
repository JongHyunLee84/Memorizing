import AddNoteFeature
import ComposableArchitecture
import CommonUI
import Models
import NoteClient
import StudyFeature
import Shared
import SwiftUI

@Reducer
public struct MyNoteFeature {
    @ObservableState
    public struct State: Equatable {
        @Shared(.currentUser) public var currentUser
        @Presents public var destination: Destination.State?
        @Shared public var noteList: IdentifiedArrayOf<Note>
        @Shared(.showOnlyStudyingNote) public var showOnlyStudyingNote
        public var path: StackState<Path.State>
        public var currentStudyingNoteID: Note.ID?
        
        public init(
            noteList: Shared<IdentifiedArrayOf<Note>> = Shared([]),
            path: StackState<Path.State> = .init()
        ) {
            self._noteList = noteList
            self.path = path
        }
        
        var userID: String? {
            currentUser?.id
        }
    }
    
    public enum Action: ViewAction {
        case view(View)
        case noteListResponse(NoteList)
        case destination(PresentationAction<Destination.Action>)
        case path(StackActionOf<Path>)
        
        @CasePathable
        public enum View: BindableAction {
            case binding(BindingAction<State>)
            case showOnlyStudyingNoteButtonTapped
            case onFirstAppear
            case plusButtonTapped
            case studyButtonTapped(Shared<Note>)
            case noteTapped(Note)
            case onAppear
        }
    }
    
    @Reducer(state: .equatable)
    public enum Destination {
        case addNote(AddNoteFeature)
        //      case alert(AlertState<ContactsFeature.Action.Alert>)
    }
    
    @Reducer(state: .equatable)
    public enum Path {
        case study(StudyFeature)
    }
    
    public init() {}
    
    @Dependency(\.noteClient) var noteClient
    @Dependency(\.date.now) var now
    
    public var body: some ReducerOf<Self> {
        BindingReducer(action: \.view)
        Reduce { state, action in
            switch action {
            case .view(.showOnlyStudyingNoteButtonTapped):
                state.showOnlyStudyingNote.toggle()
                return .none
                
            case .view(.onFirstAppear):
                return .run { [userID = state.userID] send in
                    guard let userID else {
                        fatalError("No Current User in MyNoteFeature")
                    }
                    let noteList = try await noteClient.getNoteList(userID)
                    await send(.noteListResponse(noteList))
                }
                
            case let .noteListResponse(noteList):
                state.noteList = .init(uniqueElements: noteList)
                return .none
                
            case .view(.onAppear):
                state.noteList.sort()
                return .none
                
                // MARK: - AddNoteFeature
            case .view(.plusButtonTapped):
                state.destination = .addNote(AddNoteFeature.State())
                return .none
                
            case let .view(.noteTapped(note)):
                if note.repeatCount < 4 {
                    state.destination = .addNote(AddNoteFeature.State.init(note: note))
                }
                return .none
                
            case .destination(.presented(.addNote(.view(.saveButtonTapped)))):
                // 새로운 노트 추가 or 기존 노트 업데이트
                guard let addNote = state.destination?.addNote,
                      let userID = state.userID else {
                    return .none
                }
                var saveNote: Note!
                if let note = addNote.note {
                    saveNote = .init(id: note.id,
                                     noteName: addNote.noteName,
                                     noteCategory: addNote.noteCategory.rawValue,
                                     enrollmentUser: userID,
                                     repeatCount: note.repeatCount,
                                     firstTestResult: note.firstTestResult,
                                     lastTestResult: note.lastTestResult,
                                     updateDate: now,
                                     wordList: addNote.wordList)
                } else {
                    saveNote = .init(
                        noteName: addNote.noteName,
                        noteCategory: addNote.noteCategory,
                        enrollmentUser: userID,
                        wordList: addNote.wordList
                    )
                }
                state.noteList.updateOrAppend(saveNote)
                return .run { [saveNote] _ in
                    guard let saveNote else { return }
                    try await noteClient.saveNote(userID, saveNote)
                }
                
                // Tree Based Navgation onAppear 작동 안 함.
            case .destination(.dismiss):
                state.noteList.sort()
                return .none
                
                // MARK: - StudyFeature
            case let .view(.studyButtonTapped(note)):
                state.path.append(.study(StudyFeature.State(note: note)))
                state.currentStudyingNoteID = note.id
                return .none
                
            case .path(.popFrom):
                state.currentStudyingNoteID = nil
                return .none
                
            case .path(.element(id: _, action: .study(.view(.endButtonTapped)))):
                guard let userID = state.currentUser?.id,
                      let noteID = state.currentStudyingNoteID else {
                    return .none
                }
                return .run { [userID, noteID] _ in
                    try await noteClient.incrementRepeatCount(userID, noteID)
                }
                
            case .path(.element(id: _, action: .study(.view(.studyFinishButtonTapped)))):
                guard let userID = state.currentUser?.id,
                      let noteID = state.currentStudyingNoteID,
                      let note = state.noteList[id: noteID] else {
                    return .none
                }
                return .run { [userID, noteID, note] _ in
                    async let incrementRepeat: Void = noteClient.incrementRepeatCount(userID, noteID)
                    async let setTestResult: Void = noteClient.setLastTestResult(userID, noteID, note.lastTestResult)
                    async let saveWordList: Void = noteClient.saveWordList(userID, noteID, note.wordList)
                    
                    _ = try await (incrementRepeat, setTestResult, saveWordList)
                }
                
            case .path(.element(id: _, action: .study(.view(.studyResetButtonTapped)))):
                guard let userID = state.currentUser?.id,
                      let noteID = state.currentStudyingNoteID else {
                    return .none
                }
                return .run { [userID, noteID] _ in
                    async let incrementRepeat: Void = noteClient.resetRepeatCount(userID, noteID)
                    async let setFirstTestResult: Void = noteClient.setFirstTestResult(userID, noteID, 0)
                    async let setLastTestResult: Void = noteClient.setLastTestResult(userID, noteID, 0)
                    
                    _ = try await (incrementRepeat, setFirstTestResult, setLastTestResult)
                }
                
            case .view(.binding):
                return .none
            case .destination:
                return .none
            case .path:
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
        .forEach(\.path, action: \.path)
    }
}

@ViewAction(for: MyNoteFeature.self)
public struct MyNoteView: View {
    @Bindable public var store: StoreOf<MyNoteFeature>
    
    public init(store: StoreOf<MyNoteFeature>) {
        self.store = store
    }
    
    public var body: some View {
        NavigationStack(
            path: $store.scope(state: \.path, action: \.path)
        ) {
            ScrollView {
                LazyVStack {
                    HStack(spacing: 2) {
                        Image(systemName: "checkmark.circle")
                        Text("진행 중인 암기만 보기")
                    }
                    .textStyler(color: store.showOnlyStudyingNote ? .mainBlue : .gray3,
                                font: .caption2)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .onTapGesture {
                        send(.showOnlyStudyingNoteButtonTapped)
                    }
                    .padding(.top, 12)
                    
                    ForEach(store.$noteList.elements) { $note in
                        if !store.showOnlyStudyingNote {
                            NoteCellView($note)
                        } else if note.repeatCount < 4 {
                            NoteCellView($note)
                        }
                    }
                }
            }
            .overlay(alignment: .bottomTrailing) {
                PlusButton {
                    send(.plusButtonTapped)
                }
                .padding(.bottom, 50)
            }
            .padding(.horizontal, 16)
            .onFirstTask {
                send(.onFirstAppear)
            }
            .onAppear {
                send(.onAppear)
            }
            .toolbar {
                AppLogoToolbarItem(placement: .topBarLeading)
                TitleToolbarItem(title: "내 암기장")
            }
            .navigationBarTitleDisplayMode(.inline)
            .fullScreenCover(item: $store.scope(state: \.destination?.addNote,
                                                action: \.destination.addNote)) { store in
                NavigationStack {
                    AddNoteView(store: store)
                }
            }
            
        } destination: { store in
            switch store.case {
            case let .study(store):
                StudyView(store: store)
            }
        }
    }
    
    private func NoteCellView(_ note: Shared<Note>) -> some View {
        NoteCell(
            note: note.wrappedValue,
            studyButtonTapped: {
                send(.studyButtonTapped(note))
            }
        )
        .onTapGesture {
            send(.noteTapped(note.wrappedValue))
        }
    }
}

#Preview {
    @Shared(.currentUser) var currentUser
    @Shared(.showOnlyStudyingNote) var showOnlyStudyingNote
    currentUser = .mock
    showOnlyStudyingNote = false
    return MyNoteView(
        store: .init(
            initialState: .init(),
            reducer: { MyNoteFeature()._printChanges() }
        )
    )
}
