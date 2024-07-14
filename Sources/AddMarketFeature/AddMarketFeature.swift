import ComposableArchitecture
import CommonUI
import Models
import MarketClient
import Shared
import SwiftUI

@Reducer
public struct AddMarketFeature {
    @ObservableState
    public struct State: Equatable {
        @Shared(.currentUser) var currentUser
        public var noteList: IdentifiedArrayOf<Note>
        public var selectedNote: Note?
        public var priceStr: String
        public var isInFlight: Bool
        
        public init(
            noteList: NoteList = [],
            selectedNote: Note? = nil,
            priceStr: String = "",
            isInFlight: Bool = false
        ) {
            self.noteList = .init(uniqueElements: noteList)
            self.selectedNote = selectedNote
            self.priceStr = priceStr
            self.isInFlight = isInFlight
        }
    }
    
    public enum Action: ViewAction {
        case view(View)
        case noteListResponse(NoteList)
        
        @CasePathable
        public enum View: BindableAction {
            case binding(BindingAction<State>)
            case backButtonTapped
            case onFirstAppear
            case noteTapped(Note)
            case addButtonTapped
        }
    }
    
    @Dependency(\.marketClient) var marketClient
    @Dependency(\.dismiss) var dismiss
    
    public var body: some ReducerOf<Self> {
        BindingReducer(action: \.view)
        Reduce { state, action in
            switch action {
            case let .noteListResponse(noteList):
                state.noteList = .init(uniqueElements: noteList)
                return .none
                
            case .view(.onFirstAppear):
                guard let userID = state.currentUser?.id else { return .none }
                return .run { send in
                    await send(
                        .noteListResponse(
                            try await marketClient.getSellableNoteList(userID: userID)
                        )
                    )
                }
                
            case .view(.backButtonTapped):
                return .run { _ in
                    await dismiss()
                }
                
            case let .view(.noteTapped(note)):
                state.selectedNote = note
                return .none
                
            case .view(.binding(\.priceStr)):
                state.priceStr = state.priceStr.filter { $0.isNumber }
                state.priceStr += "P"
                return .none
                
            case .view(.addButtonTapped):
                guard let note = state.selectedNote,
                      let point = Int(state.priceStr.replacingOccurrences(of: "P", with: "")) else { return .none }
                state.isInFlight = true
                return .run { _ in
                    try await marketClient.postMarketNote(
                        note: note,
                        price: point
                    )
                    await dismiss()
                }
                
            case .view:
                return .none
            }
        }
    }
}

@ViewAction(for: AddMarketFeature.self)
public struct AddMarketFeatureView: View {
    public var store: StoreOf<AddMarketFeature>
    
    public init(store: StoreOf<AddMarketFeature>) {
        self.store = store
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            
        }
        .onFirstTask {
            send(.onFirstAppear)
        }
        .navigationSetting()
        .toolbar {
            TitleToolbarItem(title: "마켓에 등록하기")
            BackButtonToolbarItem {
                send(.backButtonTapped)
            }
        }
    }
}

#Preview {
    @Shared(.currentUser) var currentUser
    currentUser = .mock
    return NavigationStack {
        AddMarketFeatureView(
            store: .init(
                initialState: .init(),
                reducer: { AddMarketFeature() }
            )
        )
    }
}
