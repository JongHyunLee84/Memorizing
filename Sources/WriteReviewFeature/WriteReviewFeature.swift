import ComposableArchitecture
import CommonUI
import MyReviewClient
import Models
import ReviewClient
import Shared
import SwiftUI
import Utilities

@Reducer
public struct WriteReviewFeature {
    @ObservableState
    public struct State: Equatable {
        @Shared(.currentUser) var currentUser
        public let note: MarketNote
        public var score: Int
        public var reviewContent: String
        public var toastMessage: String?
        public let textLimit: Int = 500
        
        public init(
            note: MarketNote,
            score: Int = 0,
            reviewContent: String = ""
        ) {
            self.note = note
            self.score = score
            self.reviewContent = reviewContent
        }
        
        public var isConfirmAvailable: Bool {
            !reviewContent.isEmpty && score != 0
        }
    }
    
    public enum Action: ViewAction {
        case view(View)
        case toastMessage(String)
        
        @CasePathable
        public enum View: BindableAction {
            case binding(BindingAction<State>)
            case backButtonTapped
            case confirmButtonTapped
        }
    }
    
    public init() {}
    
    @Dependency(\.myReviewClient) var myReviewClient
    @Dependency(\.reviewClient) var reviewClient
    @Dependency(\.dismiss) var dismiss
    @Dependency(\.uuid) var uuid
    @Dependency(\.continuousClock) var clock
    
    public var body: some ReducerOf<Self> {
        BindingReducer(action: \.view)
        Reduce { state, action in
            switch action {
            case .view(.confirmButtonTapped):
                guard let userID = state.currentUser?.id else { return .none }
                let score = Double(state.score)
                let content = state.reviewContent
                state.score = 0
                state.reviewContent = ""
                return .run { [note = state.note] send in
                    async let myReview: Void = myReviewClient.postReview(
                        userID,
                        MyReview.init(
                            marketNote: note,
                            reviewText: content,
                            starScore: score
                        )
                    )
                    async let marketReview: Void = reviewClient.postReview(
                        note.id, Review.init(
                            marketNote: note,
                            reivewText: content,
                            starScore: score
                        )
                    )
                    let _ = try await(myReview, marketReview)
                    await send(.toastMessage("리뷰가 등록되었어요."))
                    try await clock.sleep(for: .seconds(1))
                    await dismiss()
                }
                
            case .toastMessage(let message):
                state.toastMessage = message
                return .none
                
            case .view(.binding(\.reviewContent)):
                let content = state.reviewContent
                if content.count > state.textLimit {
                    state.reviewContent = String(content.prefix(state.textLimit))
                }
                return .none
                
            case .view(.binding(\.score)):
                if state.score > 5 {
                    state.score = 5
                }
                return .none
                
            case .view(.backButtonTapped):
                return .run { _ in
                    await dismiss()
                }
                
            case .view(.binding):
                return .none
            }
        }
    }
}

@ViewAction(for: WriteReviewFeature.self)
public struct WriteReviewView: View {
    @Bindable public var store: StoreOf<WriteReviewFeature>
    
    public init(store: StoreOf<WriteReviewFeature>) {
        self.store = store
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            let note = store.note
            CategoryText(noteCategory: note.noteCategory,
                         noteColor: note.noteColor)
            .padding(.vertical, 14)
            
            Text(note.noteName)
                .textStyler(font: .headline,
                            weight: .semibold)
                .padding(.bottom, 8)
            
            Text(note.updateDate, format: .yearMonthDay)
                .textStyler(color: .gray2,
                            font: .footnote)
                .padding(.bottom, 60)
            
            
            Text("즐거운 학습이 되셨나요?")
                .textStyler(font: .body,
                            weight: .semibold)
                .frame(maxWidth: .infinity,
                       alignment: .center)
                .padding(.bottom, 14)
            
            ScoreView($store.score)
                .padding(.bottom, 40)
            
            CustomTextEditor(placeholder: """
 리뷰를 작성해주세요. 다른 사용자분들께 도움이 된답니다!
 험한말은 싫어요. 이쁜말로 부탁해요:)
 아 리뷰는 선택이에요! 별점만 남겨주셔도 괜찮습니다.
 """,
                             text: $store.reviewContent,
                             textLimit: store.textLimit)
            
            .frame(height: 300)
            
            Spacer()
            
            MainButton(title: "등록하기",
                       isAvailable: store.isConfirmAvailable) {
                send(.confirmButtonTapped)
            }
            
        }
        .padding(.horizontal, 16)
        .navigationSetting()
        .toastMessage(messsage: $store.toastMessage)
        .toolbar {
            BackButtonToolbarItem {
                send(.backButtonTapped)
            }
            TitleToolbarItem(title: "리뷰 작성하기")
        }
    }
    
    private func ScoreView(_ score: Binding<Int>) -> some View {
        HStack(spacing: 10) {
            ForEach(1..<6, id: \.self) { idx in
                Image(systemName: store.score >= idx ? "star.fill" : "star")
                    .resizable()
                    .textColor(.yellow)
                    .frame(width: 32, height: 32)
                    .onTapGesture {
                        score.wrappedValue = idx
                    }
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }
}

#Preview {
    @Shared(.currentUser) var currentUser
    currentUser = .mock
    return NavigationStack {
        WriteReviewView(
            store: .init(
                initialState: .init(note: .mock),
                reducer: { WriteReviewFeature()._printChanges() }
            )
        )
    }
}
