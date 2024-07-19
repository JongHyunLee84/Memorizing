import ComposableArchitecture
import CommonUI
import MarketClient
import Models
import ReviewClient
import SwiftUI
import Shared
import Utilities

@Reducer
public struct MarketNoteDetailFeature {
    @ObservableState
    public struct State: Equatable {
        @Shared(.currentUser) public var currentUser
        public var path: StackState<Path.State>
        public var note: MarketNote
        public var isInFlight: Bool
        public var reviewList: ReviewList
        public var toastMessage: String?
        
        public init(
            path: StackState<Path.State> = .init(),
            note: MarketNote,
            isInFlight: Bool = false,
            reviewList: ReviewList = [],
            toastMessage: String? = nil
        ) {
            self.path = path
            self.note = note
            self.isInFlight = isInFlight
            self.reviewList = reviewList
            self.toastMessage = toastMessage
        }
        
    }
    
    public enum Action: ViewAction {
        case view(View)
        case reviewListResponse(ReviewList)
        case sendToastMessage(String)
        case isInFlightFinish
        case path(StackActionOf<Path>)
        @CasePathable
        public enum View: BindableAction {
            case binding(BindingAction<State>)
            case onFirstAppear
            case xButtonTapped
            case purchaseButtonTapped
            case watchMoreReviewsButtonTapped
        }
    }
    
    @Reducer(state: .equatable)
    public enum Path {
        case reviewList(ReviewListFeature)
    }
    
    
    @Dependency(\.marketClient) var marketClient
    @Dependency(\.reviewClient) var reviewClient
    @Dependency(\.dismiss) var dismiss
    @Dependency(\.continuousClock) var clock
    
    public init() {}
    
    enum CancelID { case purchaseButton }
    
    public var body: some ReducerOf<Self> {
        BindingReducer(action: \.view)
        Reduce { state, action in
            switch action {
            case .view(.onFirstAppear):
                return .run { [noteID = state.note.id] send in
                    await send(
                        .reviewListResponse(
                            try await reviewClient.getReviewList(noteID: noteID)
                        )
                    )
                }
                
            case .view(.purchaseButtonTapped):
                guard let userID = state.currentUser?.id else { return .none }
                state.isInFlight = true
                return .run { [note = state.note, currentUser = state.$currentUser] send in
                    let isBuyable = try await marketClient.getIsBuyable(userID: userID,
                                                                        price: note.notePrice)
                    if isBuyable {
                        try await marketClient.buyNote(userID: userID,
                                                       note: note)
                        await currentUser.withLock { $0?.coin -= note.notePrice }
                        await send(.sendToastMessage("구매가 완료되었어요."))
                        try await clock.sleep(for: .seconds(1))
                        await dismiss()
                    } else {
                        await send(.isInFlightFinish)
                        await send(.sendToastMessage("보유하신 포인트가 부족해요."))
                    }
                }
                .cancellable(id: CancelID.purchaseButton, cancelInFlight: true)

            case .view(.watchMoreReviewsButtonTapped):
                state.path.append(
                    .reviewList(
                        .init(
                            note: state.note,
                            reviewList: state.reviewList
                        )
                    )
                )
                return .none
                
            case .view(.xButtonTapped):
                return .run { _ in
                    await dismiss()
                }
                
            case let .reviewListResponse(reviewList):
                state.reviewList = reviewList
                return .none

            case .isInFlightFinish:
                state.isInFlight = false
                return .none
                
            case let .sendToastMessage(toastMessage):
                state.toastMessage = toastMessage
                return .none

            case .view(.binding):
                return .none
            case .path:
                return .none
            }
        }
        .forEach(\.path, action: \.path)
    }
}

@ViewAction(for: MarketNoteDetailFeature.self)
public struct MarketNoteDetailView: View {
    @Bindable public var store: StoreOf<MarketNoteDetailFeature>
    
    public init(store: StoreOf<MarketNoteDetailFeature>) {
        self.store = store
    }
    
    public var body: some View {
        NavigationStack(path: $store.scope(state: \.path,
                                           action: \.path)) {
            VStack(alignment: .leading, spacing: 0) {
                NoteInfo()
                CustomDivider(height: 5)
                    .padding(.horizontal, -16)
                WordListView()
                MainButton(title: "\(store.note.notePrice.description)P으로 지식 구매하기!",
                           font: .callout,
                           weight: .heavy,
                           radius: 20,
                           height: 50) {
                    send(.purchaseButtonTapped)
                }
            }
            .padding(.horizontal, 16)
            .toastMessage(messsage: $store.toastMessage)
            .isProgressing(store.isInFlight)
            .onFirstTask {
                send(.onFirstAppear)
            }
            .navigationSetting()
            .toolbar {
                TitleToolbarItem(title: "암기장 구매하기")
                XToolbarItem {
                    send(.xButtonTapped)
                }
            }
        } destination: { state in
            switch state.case {
            case let .reviewList(store):
                ReviewListView(store: store)
            }
        }
    }
    
    private func NoteInfo() -> some View {
        VStack(alignment: .leading, spacing: 0) {
            CategoryText(noteCategory: store.note.noteCategory,
                         noteColor: store.note.noteColor)
                .padding(.vertical, 12)
            
            Text(store.note.noteName)
                .textStyler(font: .title3,
                            weight: .heavy)
            
            HStack(alignment: .bottom, spacing: 0) {
                Image(systemName: "star.fill")
                    .textColor(.yellow)
                Text(" \(String(format: "%.1f", store.note.reviewScoreAverage)) (\(store.note.reviewCount)) | ")
                Text(store.note.updateDate, formatter: dateFormatter)
                Spacer()
                Text(store.note.notePrice.description + "P")
                    .textStyler(color: .mainDarkBlue,
                                font: .title2,
                                weight: .heavy)
            }
            .textStyler(color: .gray2,
                        font: .footnote)
            .padding(.vertical, 12)
            
            if !store.reviewList.isEmpty {
                ScrollView(.horizontal) {
                    LazyHStack(spacing: 5) {
                        ForEach(store.reviewList) { review in
                            ReviewCell(review)
                        }
                    }
                }
                .scrollIndicators(.never)
                .frame(height: 100)
                
                Button(
                    action: {
                        send(.watchMoreReviewsButtonTapped)
                    }, label: {
                        Text("후기 더보기 >")
                            .textStyler(color: .gray2, font: .footnote)
                            .padding(.vertical, 8)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                )

            }
        }
    }
    
    private func ReviewCell(_ review: Review) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            ReviewStars(reviewScore: review.starScore,
                        font: .footnote)
            Text(review.reviewText)
                .textStyler(font: .footnote)
            Text(review.createDate, formatter: dateFormatter)
                .textStyler(color: .gray4, font: .footnote)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .frame(width: 140, height: 70)
        .border(.gray5,
                verticalPadding: 10,
                horizontalPadding: 12)
    }
 
    private func WordListView() -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("미리보기")
                Spacer()
                let wordListCountText = Text(store.note.wordList.count.description)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.mainBlue)
                Text("총 \(wordListCountText)개의 단어")
                    .textColor(.mainBlack)
            }
            .textStyler(color: .gray2,
                        font: .callout,
                        weight: .semibold)
            .padding(.vertical, 22)
            
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(store.note.wordList.prefix(10)) { word in
                        WordCell(wordString: word.wordString,
                                 wordMeaning: word.wordMeaning)
                    }
                }
            }
            .scrollIndicators(.never)
            
            VStack(spacing: 20) {
                Image(systemName: "ellipsis")
                    .textStyler(color: .gray3,
                                font: .title,
                                weight: .bold)
                    .rotationEffect(.degrees(90))
                
                Text("모든 단어는 구매 후에 확인할 수 있어요🙏")
                    .textStyler(color: .gray2,
                                font: .callout)
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.vertical, 26)
        }
    }
}

#Preview {
    @Shared(.currentUser) var currentUser
    currentUser = .mock
    return MarketNoteDetailView(
        store: .init(
            initialState: .init(note: .mock),
            reducer: { MarketNoteDetailFeature()._printChanges() }
        )
    )
}


