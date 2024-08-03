import CommonUI
import ComposableArchitecture
import Models
import MyReviewClient
import ReviewClient
import Shared
import SwiftUI
import Utilities

@Reducer
public struct ReviewHistoryFeature {
    @ObservableState
    public struct State: Equatable {
        @Shared(.currentUser) public var currentUser
        @Presents public var alert: AlertState<Action.Alert>?
        public var reviewList: IdentifiedArrayOf<MyReview>
        public var toastMessage: String?
        
        public init(
            reviewList: IdentifiedArrayOf<MyReview> = .init(),
            toastMessage: String? = nil
        ) {
            self.reviewList = reviewList
            self.toastMessage = toastMessage
        }
    }
    
    public enum Action: ViewAction {
        case view(View)
        case reviewListResponse(MyReviewList)
        case removeListWith(String)
        case toastMessage(String)
        case alert(PresentationAction<Alert>)
        
        @CasePathable
        public enum View {
            case onAppear
            case deleteButtonTapped(MyReview)
            case backButtonTapped
        }
        
        @CasePathable
        public enum Alert: Equatable {
            case confirmDelete(MyReview)
        }
    }
    
    public init() {}
    
    @Dependency(\.myReviewClient) var myReviewClient
    @Dependency(\.reviewClient) var reviewClient
    @Dependency(\.dismiss) var dismiss
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
                
            case .view(.onAppear):
                guard let userID = state.currentUser?.id else { return .none }
                return .run { send in
                    let reviewList = try await myReviewClient.getReviewList(userID: userID)
                    await send(.reviewListResponse(reviewList))
                }
                
            case let .reviewListResponse(reviewList):
                state.reviewList = .init(uniqueElements: reviewList)
                return .none
                
            case let .view(.deleteButtonTapped(review)):
                state.alert = .deleteReview(review)
                return .none
                
            case .alert(.presented(.confirmDelete(let review))):
                guard let userID = state.currentUser?.id else { return .none }
                return .run { send in
                    async let deleteMyReview: Void =  myReviewClient.deleteReview(userID: userID,
                                                                                  reviewID: review.id)
                    async let deleteReview: Void = reviewClient.deleteReview(noteID: review.noteID,
                                                                             reviewID: review.id)
                    _ = try await (deleteMyReview, deleteReview)
                    await send(.removeListWith(review.id))
                    await send(.toastMessage("리뷰가 삭제되었어요."))
                }
                
            case .removeListWith(let reviewID):
                state.reviewList.remove(id: reviewID)
                return .none
                
            case .toastMessage(let message):
                state.toastMessage = nil
                state.toastMessage = message
                return .none
                
            case .view(.backButtonTapped):
                return .run { _ in
                    await dismiss()
                }
                
            case .alert:
                return .none
                
            case .view:
                return .none
            }
        }
        .ifLet(\.$alert, action: \.alert)
    }
    
}

extension AlertState where Action == ReviewHistoryFeature.Action.Alert {
    public static func deleteReview(
        _ review: MyReview
    ) -> AlertState<Action> {
        .init(title: TextState("삭제하기"),
              message: TextState("정말 삭제하실 건가요?"),
              buttons: [
                .cancel(TextState("취소")),
                .default(TextState("삭제"),
                         action: .send(.confirmDelete(review)))
              ]
        )
    }
}

@ViewAction(for: ReviewHistoryFeature.self)
public struct ReviewHistoryView: View {
    @Bindable public var store: StoreOf<ReviewHistoryFeature>
    
    public init(
        store: StoreOf<ReviewHistoryFeature>
    ) {
        self.store = store
    }
    
    public var body: some View {
        ScrollView {
            LazyVStack(spacing: 14) {
                ForEach(store.reviewList) { review in
                    ReviewCell(review)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
        }
        .scrollIndicators(.never)
        .navigationSetting()
        .customAlert($store.scope(state: \.alert,
                            action: \.alert))
        .task {
            await send(.onAppear).finish()
        }
        .toolbar {
            BackButtonToolbarItem {
                send(.backButtonTapped)
            }
            TitleToolbarItem(title: "내가 작성한 리뷰")
        }
    }
    
    private func ReviewCell(
        _ review: MyReview
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            ReviewStars(reviewScore: review.starScore,
                        font: .body)
            Text(review.reviewText)
                .textStyler(font: .callout,
                            weight: .medium)
            HStack(spacing: 8) {
                Text(review.noteTitle)
                    .textStyler(color: .gray2,
                                font: .footnote)
                Text(review.createDate,
                     format: .yearMonthDay)
                .textStyler(color: .gray3,
                            font: .footnote)
                Spacer()
                Text("삭제")
                    .textStyler(color: .gray3,
                                font: .footnote)
                    .onTapGesture {
                        send(.deleteButtonTapped(review))
                    }
            }
        }
    }
}

#Preview {
    @Shared(.currentUser) var currentUser
    currentUser = .mock
    return NavigationStack {
        ReviewHistoryView(
            store: .init(
                initialState: .init(),
                reducer: { ReviewHistoryFeature() }
            )
        )
    }
}

