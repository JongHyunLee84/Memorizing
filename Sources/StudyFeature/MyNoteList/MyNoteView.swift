import CommonUI
import ComposableArchitecture
import SwiftUI

@ViewAction(for: MyNoteListFeature.self)
public struct MyNoteListView: View {
    @Bindable public var store: StoreOf<MyNoteListFeature>
    
    public var body: some View {
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
                
                ForEach(store.noteList) { note in
                    if !store.showOnlyStudyingNote {
                        NoteCell(note: note)
                    } else if note.repeatCount < 4 {
                        NoteCell(note: note)
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
        .task {
            await send(.onAppear).finish()
        }
        .toolbar {
            AppLogoToolbarItem(placement: .topBarLeading)
            TitleToolbarItem(title: "내 암기장")
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    @Shared(.currentUser) var currentUser
    currentUser = .mock
    return NavigationStack {
        MyNoteListView(
            store: .init(
                initialState: .init(),
                reducer: { MyNoteListFeature()._printChanges() })
        )
    }
}

import ComposableArchitecture
import Models
import NoteClient
import Shared

@Reducer
public struct MyNoteListFeature {
    @ObservableState
    public struct State: Equatable {
        @Shared(.currentUser) public var currentUser
//        @Presents public var addNote: TODO: //
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
        
        @CasePathable
        public enum View: BindableAction {
            case binding(BindingAction<State>)
            case showOnlyStudyingNoteButtonTapped
            case onAppear
            case plusButtonTapped
        }
    }
    
//    @Reducer
//    enum Destination {
//      case addContact(AddContactFeature)
//      case alert(AlertState<ContactsFeature.Action.Alert>)
//    }
    
    public init() {}
    
    @Dependency(\.noteClient) var noteClient
    
    public var body: some Reducer<State, Action> {
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
                // TODO: 
                return .none
            case .view(.binding):
                return .none
            }
        }
    }
}
