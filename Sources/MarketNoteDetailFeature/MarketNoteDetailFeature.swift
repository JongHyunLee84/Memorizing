import ComposableArchitecture
import CommonUI
import MarketClient
import Models
import SwiftUI
import Shared

@Reducer
public struct MarketNoteDetailFeature {
    @ObservableState
    public struct State: Equatable {
        //        public var path: StackState<Path.State>
        @Shared(.currentUser) var currentUser
        public let note: MarketNote
        public init(
            note: MarketNote
        ) {
            self.note = note
        }
        
    }
    
    public enum Action: ViewAction {
        //        case path(StackActionOf<Path>)
        case view(View)
        
        @CasePathable
        public enum View {
            case xButtonTapped
            case purchaseButtonTapped
        }
    }
    
    //    @Reducer(state: .equatable)
    //    public enum Path {
    //        case study(StudyFeature)
    //    }
    
    @Dependency(\.marketClient) var marketClient
    
    public init() {}
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .view(.xButtonTapped):
                return .none
            case .view(.purchaseButtonTapped):
                return .none
                
            }
        }
    }
}

@ViewAction(for: MarketNoteDetailFeature.self)
public struct MarketNoteDetailView: View {
    public var store: StoreOf<MarketNoteDetailFeature>
    
    public init(store: StoreOf<MarketNoteDetailFeature>) {
        self.store = store
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(store.note.noteCategory)
                .textStyler(color: .white,
                            font: .caption,
                            weight: .black)
                .border(store.note.noteColor,
                        backgroundColor: store.note.noteColor,
                        radius: 30,
                        verticalPadding: 6,
                        horizontalPadding: 20)
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
            
            // TODO: Review List
            
            CustomDivider(height: 5)
                .padding(.horizontal, -16)
            
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
            
            MainButton(title: "\(store.note.notePrice.description)P으로 지식 구매하기!",
                       font: .caption,
                       weight: .heavy,
                       radius: 20,
                       height: 50) {
                send(.purchaseButtonTapped)
            }
        }
        .padding(.horizontal, 16)
        .navigationSetting()
        .toolbar {
            TitleToolbarItem(title: "암기장 구매하기")
            XToolbarItem {
                send(.xButtonTapped)
            }
        }
    }
    
    private var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"  // 또는 원하는 형식으로 지정
        return formatter
    }()
}

#Preview {
    @Shared(.currentUser) var currentUser
    currentUser = .mock
    return NavigationStack {
        MarketNoteDetailView(
            store: .init(
                initialState: .init(note: .mock),
                reducer: { MarketNoteDetailFeature() }
            )
        )
    }
}


