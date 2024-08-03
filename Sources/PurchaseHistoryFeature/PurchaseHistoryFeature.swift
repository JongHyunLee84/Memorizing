import ComposableArchitecture
import CommonUI
import MyReviewClient
import MarketClient
import Models
import Shared
import SwiftUI
import Utilities

@Reducer
public struct PurchaseHistoryFeature {
    @ObservableState
    public struct State: Equatable {
        @Shared(.currentUser) var currentUser
        public var noteList: NoteList
        public var marketNoteList: MarketNoteList
        public var reviewList: MyReviewList
        public var isLoading: Bool // review 작성 유무 체크 전까지 Loading
        public var responseCount: Int // onAppear에서 보낸 response action의 갯수
        public var purchaseHistoryNoteList: IdentifiedArrayOf<PurchaseHistoryNote>
        public init(
            noteList: NoteList,
            marketNoteList: MarketNoteList = [],
            reviewList: MyReviewList = [],
            isLoading: Bool = false,
            responseCount: Int = 0,
            purchaseHistoryNoteList: IdentifiedArrayOf<PurchaseHistoryNote> = .init()
        ) {
            @Shared(.currentUser) var currentUser
            let noteListFromMarket = noteList.filter { $0.enrollmentUser != currentUser?.id }
            self.noteList = noteListFromMarket
            self.marketNoteList = marketNoteList
            self.reviewList = reviewList
            self.isLoading = isLoading
            self.responseCount = responseCount
            self.purchaseHistoryNoteList = purchaseHistoryNoteList
        }
    }
    
    public enum Action: ViewAction {
        case view(View)
        case myReviewListResponse(MyReviewList)
        case marketNoteListReponse(MarketNoteList)
        case handleResponseCount
        case assignPurchaseHistoryNoteList
        
        @CasePathable
        public enum View {
            case onAppear
            case backButtonTapped
            case writeReviewButtonTapped(String) // parentView에서 push
        }
    }
    
    public init() {}
    
    @Dependency(\.myReviewClient) var myReviewClient
    @Dependency(\.marketClient) var marketClient
    @Dependency(\.dismiss) var dismiss
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
                
            case .view(.onAppear):
                guard let userID = state.currentUser?.id else { return .none }
                state.isLoading = true
                
                return .run { [noteIDList = state.noteList.map(\.id) ]send in
                    async let reviewList = myReviewClient.getReviewList(userID: userID)
                    async let marketNoteList = marketClient.getMarketNoteListWith(noteIDList: noteIDList)
                    
                    await send(.myReviewListResponse(try await reviewList))
                    await send(.marketNoteListReponse(try await marketNoteList))
                }
                
            case .myReviewListResponse(let list):
                state.reviewList = list
                return .send(.handleResponseCount)
                
            case .marketNoteListReponse(let list):
                state.marketNoteList = list
                return .send(.handleResponseCount)
                
            case .handleResponseCount:
                state.responseCount += 1
                if state.responseCount >= 2 { // isLoading이 끝나야 하는 조건 (myReviewListResponse + marketNoteListReponse)
                    state.isLoading = false
                    return .send(.assignPurchaseHistoryNoteList)
                }
                return .none
                
            case .assignPurchaseHistoryNoteList:
                let list: [PurchaseHistoryNote] = state.marketNoteList.map { note in
                    let isReviewed = state.reviewList.contains(where: { $0.noteID == note.id })
                    ? true
                    : false
                    return .init(note: note, isReviewed: isReviewed)
                }
                state.purchaseHistoryNoteList = .init(uniqueElements: list)
                return .none
                
            case .view(.writeReviewButtonTapped):
                return .none
                
            case .view(.backButtonTapped):
                return .run { _ in
                    await dismiss()
                }
            }
        }
    }
}

@dynamicMemberLookup
public struct PurchaseHistoryNote: Identifiable, Equatable {
    public var note: MarketNote
    public var isReviewed: Bool
    public let id: String
    
    public init(
        note: MarketNote,
        isReviewed: Bool
    ) {
        self.note = note
        self.isReviewed = isReviewed
        self.id = note.id
    }
    
    public subscript<T>(dynamicMember keyPath: KeyPath<MarketNote, T>) -> T {
        note[keyPath: keyPath]
    }
}

@ViewAction(for: PurchaseHistoryFeature.self)
public struct PurchaseHistoryView: View {
    public var store: StoreOf<PurchaseHistoryFeature>
    
    public init(store: StoreOf<PurchaseHistoryFeature>) {
        self.store = store
    }
    
    public var body: some View {
        GeometryReader { proxy in
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(store.purchaseHistoryNoteList) { note in
                        PurchaseHistoryCell(note)
                    }
                    Spacer()
                }
                .emptyList(isVisible: !store.isLoading,
                           list: store.purchaseHistoryNoteList.elements,
                           title: "구매한 암기장이 없어요.")
                .padding(.horizontal, 12)
                .padding(.top, 32)
                .frame(minHeight: proxy.size.height)
            }
            .scrollIndicators(.never)
        }
        .isProgressing(store.isLoading)
        .task {
            await send(.onAppear).finish()
        }
        .navigationSetting()
        .toolbar {
            BackButtonToolbarItem {
                send(.backButtonTapped)
            }
            TitleToolbarItem(title: "암기장 구매 내역")
        }
    }
    
    public func PurchaseHistoryCell(_ note: PurchaseHistoryNote) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(note.updateDate, format: .yearMonthDay)
                .textStyler(color: .gray1,
                            font: .footnote)
                .padding(.bottom, 8)
            
            HStack {
                Text(note.noteName)
                Spacer()
                Text(note.notePrice.description)
                    .textColor(.mainBlue)
            }
            .textStyler(font: .body,
                        weight: .semibold)
            
            Button(note.isReviewed ? "후기 작성 완료" : "후기 작성하고 10P 받기!") {
                send(.writeReviewButtonTapped(note.id))
            }
            .frame(maxWidth: .infinity,
                   alignment: note.isReviewed ? .leading : .trailing)
            .textStyler(color: note.isReviewed ? .gray3 : .mainBlue,
                        font: .caption,
                        weight: .medium)
            .disabled(note.isReviewed)
            .padding(.vertical, 12)
            
            CustomDivider()
        }
    }
}

#Preview {
    @Shared(.currentUser) var currentUser
    currentUser = .mock
    return NavigationStack {
        PurchaseHistoryView(
            store: .init(
                initialState: .init(noteList: .mock),
                reducer: { PurchaseHistoryFeature()._printChanges() },
                withDependencies: {
                    $0.uuid = .incrementing
                    $0.date = .init { .random }
                }
            )
        )
    }
}

#Preview("Loading and Empty Case") {
    @Shared(.currentUser) var currentUser
    currentUser = .mock
    return NavigationStack {
        PurchaseHistoryView(
            store: .init(
                initialState: .init(noteList: .mock),
                reducer: { PurchaseHistoryFeature()._printChanges() },
                withDependencies: {
                    $0.uuid = .incrementing
                    $0.date = .init { .random }
                    $0.myReviewClient.getReviewList = { _ in return [] }
                    $0.marketClient.getMarketNoteListWith = { _ in
                        try await Task.sleep(for: .seconds(2))
                        return []
                    }
                }
            )
        )
    }
}
