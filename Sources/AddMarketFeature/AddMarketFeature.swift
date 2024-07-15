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
        
        public var isAddButtonAvailable: Bool {
            selectedNote != nil && !priceStr.isEmpty
        }
    }
    
    public enum Action: ViewAction {
        case view(View)
        case noteListResponse(NoteList)
        case editPriceStr

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
    @Dependency(\.continuousClock) var clock
    private enum CancelID { case price }

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
                if state.selectedNote == note {
                    state.selectedNote = nil
                } else {
                    state.selectedNote = note
                }
                return .none
                
            case .view(.binding(\.priceStr)):
                guard !state.priceStr.isEmpty else { return .cancel(id: CancelID.price) }
                
                return .run { send in
                    try await clock.sleep(for: .seconds(0.5))
                    await send(.editPriceStr)
                }
                .cancellable(id: CancelID.price,
                             cancelInFlight: true)
                
            case .editPriceStr:
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
    @Bindable public var store: StoreOf<AddMarketFeature>
    
    public init(store: StoreOf<AddMarketFeature>) {
        self.store = store
    }
    
    public var body: some View {
        GeometryReader { proxy in
            VStack(spacing: 0) {
                let height = proxy.size.height
                Text("내 암기장")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 32)
                    .padding(.bottom, 12)
                    .textStyler(weight: .semibold)
                
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(store.noteList) { note in
                            MyNoteCell(note: note)
                                .onTapGesture {
                                    send(.noteTapped(note))
                                }
                        }
                    }
                }
                .scrollIndicators(.never)
                .frame(height: height * 0.7)
                
                CustomDivider()
                    .padding(.vertical, 12)
                
                HStack {
                    Text("포인트 설정")
                    Spacer()
                    TextField("100P",
                              text: $store.priceStr)
                    .multilineTextAlignment(.center)
                    .frame(width: 125)
                    .padding(.vertical, 4)
                    .background(Color.gray6)
                    .border(.gray5)
                }
                .textStyler(font: .headline,
                            weight: .semibold)
                
                Spacer()
                
                MainButton(title: "마켓에 등록하기",
                           font: .subheadline,
                           weight: .semibold,
                           isAvailable: store.isAddButtonAvailable) {
                    send(.addButtonTapped)
                }
                
            }
            
        }
        .padding(.horizontal, 16)
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
    
    private func MyNoteCell(note: Note) -> some View {
        let gray4 = note == store.selectedNote
        ? note.noteColor
        : .gray4
        let gray1 = note == store.selectedNote
        ? note.noteColor
        : .gray1
        return Rectangle()
            .fill(.white)
            .cornerRadius(12)
            .frame(height: 80)
            .overlay {
                HStack(spacing: 12) {
                    Rectangle()
                        .fill(gray4)
                        .frame(width: 10)
                    VStack(alignment: .leading, spacing: 8) {
                        Text(note.noteCategory)
                            .textStyler(color: gray1,
                                        font: .caption2)
                            .border(gray1,
                                    verticalPadding: 4,
                                    horizontalPadding: 6)
                        Text(note.noteName)
                            .textStyler(color: .gray1,
                                        font: .headline,
                                        weight: .semibold)
                    }
                    Spacer()
                }
            }
            .border(gray4,
                    radius: 12)
    }
}

#Preview {
    @Shared(.currentUser) var currentUser
    currentUser = .mock
    return NavigationStack {
        AddMarketFeatureView(
            store: .init(
                initialState: .init(),
                reducer: { AddMarketFeature()._printChanges() }
            )
        )
        .onAppear {
            UIApplication.shared.hideKeyboard()
        }
    }
}
