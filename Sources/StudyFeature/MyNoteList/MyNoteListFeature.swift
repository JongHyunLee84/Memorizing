import ComposableArchitecture
import Models
import NoteClient
import Shared

@Reducer
public struct MyNoteListFeature {
    @ObservableState
    public struct State: Equatable {
        @Shared(.currentUser) public var currentUser
        @Presents public var destination: Destination.State?
        public var noteList: NoteList
        public var showOnlyStudyingNote: Bool
        
        var userID: String? {
            currentUser?.id
        }
        
        public init(
            noteList: NoteList = [],
            showOnlyStudyingNote: Bool = false
        ) {
            self.noteList = noteList
            self.showOnlyStudyingNote = showOnlyStudyingNote
        }
    }
    
    public enum Action: ViewAction {
        case view(View)
        case noteListResponse(NoteList)
        case destination(PresentationAction<Destination.Action>)
        
        @CasePathable
        public enum View: BindableAction {
            case binding(BindingAction<State>)
            case showOnlyStudyingNoteButtonTapped
            case onAppear
            case plusButtonTapped
        }
    }
    
    @Reducer(state: .equatable)
    public enum Destination {
        case addNote(AddNoteFeature)
        //      case alert(AlertState<ContactsFeature.Action.Alert>)
    }
    
    public init() {}
    
    @Dependency(\.noteClient) var noteClient
    
    public var body: some ReducerOf<Self> {
        BindingReducer(action: \.view)
        Reduce { state, action in
            switch action {
            case .view(.showOnlyStudyingNoteButtonTapped):
                state.showOnlyStudyingNote.toggle()
                return .none
                
            case .view(.onAppear):
                return .run { [userID = state.userID] send in
                    guard let userID else {
                        fatalError("No Current User in MyNoteFeature")
                    }
                    let noteList = try await noteClient.getNoteList(userID)
                    await send(.noteListResponse(noteList))
                }
                
            case let .noteListResponse(noteList):
                state.noteList = noteList
                return .none
                
            case .view(.plusButtonTapped):
                state.destination = .addNote(AddNoteFeature.State())
                return .none
                
                // TODO: Parent, Child 각각 해보고 동작이 같은지 디버깅해보기
            case .destination(.presented(.addNote(.addNoteDelegate))):
                guard let addNote = state.destination?.addNote,
                      let userID = state.userID else {
                    return .none
                }
                let newNote: Note = .init(
                    noteName: addNote.noteName,
                    noteCategory: addNote.noteCategory,
                    enrollmentUser: userID,
                    wordList: addNote.wordList
                )
                state.noteList.append(newNote)
                return .run { _ in
                    try await noteClient.saveNote(userID, newNote)
                }
                
            case .view(.binding):
                return .none
                
            case .destination:
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}

