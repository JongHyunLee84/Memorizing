import ComposableArchitecture
import CommonUI
import Models
import SwiftUI
import Utilities

@Reducer
public struct ReviewListFeature {
    @ObservableState
    public struct State: Equatable {
        public var note: MarketNote
        public var reviewList: ReviewList
        
        public init(
            note: MarketNote,
            reviewList: ReviewList
        ) {
            self.note = note
            self.reviewList = reviewList
        }
    }
    
    public enum Action: ViewAction {
        case view(View)
        
        @CasePathable
        public enum View {
            case backButtonTapped
        }
    }
    
    public init() {}
    
    @Dependency(\.dismiss) var dismiss
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .view(.backButtonTapped):
                return .run { _ in
                    await dismiss()
                }
            }
        }
    }
}

@ViewAction(for: ReviewListFeature.self)
struct ReviewListView: View {
    let store: StoreOf<ReviewListFeature>
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 12) {
                CategoryText(noteCategory: store.note.noteCategory,
                             noteColor: store.note.noteColor)
                Text(store.note.noteName)
                    .textStyler(font: .title2,
                                weight: .bold)
                Text(store.note.updateDate, format: .yearMonthDay)
                    .textStyler(color: .gray2,
                                font: .footnote)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 12)
            
            CustomDivider(height: 8)
                .padding(.horizontal, -16)
                .padding(.vertical, 24)
            
            ScrollView {
                Text("후기 \(store.reviewList.count)개")
                    .textStyler(font: .title3,
                                weight: .bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                LazyVStack(alignment: .leading, spacing: 18) {
                    ForEach(store.reviewList) { review in
                        ReviewCell(review)
                    }
                }
            }
            .scrollIndicators(.never)
        }
        .padding(.horizontal, 16)
        .navigationSetting()
        .toolbar {
            BackButtonToolbarItem {
                send(.backButtonTapped)
            }
        }
    }
    
    private func ReviewCell(_ review: Review) -> some View {
        VStack(alignment: .leading,
               spacing: 10) {
            ReviewStars(reviewScore: review.starScore,
                        font: .callout)
            Text(review.reviewText)
                .textStyler(font: .body,
                            weight: .semibold)
            Text(review.createDate, format: .yearMonthDay)
                .textStyler(color: .gray4, font: .footnote)
                .frame(maxWidth: .infinity, alignment: .trailing)
            CustomDivider()
        }
    }
}

#Preview {
    NavigationStack {
        ReviewListView(
            store: .init(
                initialState: .init(note: .mock,
                                    reviewList: .mock),
                reducer: { ReviewListFeature()._printChanges() }
            )
        )
    }
}
