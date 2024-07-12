import ComposableArchitecture
import CommonUI
import Models
import Shared
import SwiftUI

@Reducer
public struct MarketFeature {
    @ObservableState
    public struct State: Equatable {
        @Shared(.currentUser) public var currentUser
        private var noteList: IdentifiedArrayOf<MarketNote>
        public var queriedNoteList: IdentifiedArrayOf<MarketNote>
        public var noteQuery: String
        public var marketCategory: MarketCategory
        public var sortType: SortType?
        //        public var destination: Destination.State?
        public init(noteList: MarketNoteList = .init(),
                    noteQuery: String = "",
                    marketCategory: MarketCategory = .all,
                    sortType: SortType? = nil) {
            self.noteList = .init(uniqueElements: noteList)
            self.queriedNoteList = .init(uniqueElements: noteList)
            self.noteQuery = noteQuery
            self.marketCategory = marketCategory
            self.sortType = sortType
        }
    }
    
    public enum Action: ViewAction {
        case view(View)
        
        @CasePathable
        public enum View: BindableAction {
            case binding(BindingAction<State>)
            case onFirstAppear
            case coinButtonTapped
            case searchButtonTapped
            case categoryButtonTapped(MarketCategory)
            case sortButtonTapped(SortType)
            case noteTapped(MarketNote)
            case plusButtonTapped
        }
    }
    //
    //    @Reducer
    //    enum Destination {
    //        case
    //    }
    
    public init() {}
    
    public var body: some ReducerOf<Self> {
        BindingReducer(action: \.view)
    }
}

@ViewAction(for: MarketFeature.self)
public struct MarketView: View {
    @Bindable public var store: StoreOf<MarketFeature>
    
    public var body: some View {
        GeometryReader { proxy in
            LazyVStack {
                HStack {
                    TextField("암기장 이름을 검색해보세요!",
                              text: $store.noteQuery)
                    .textStyler(color: .gray3, font: .caption)
                    Spacer()
                    Button(action: {
                        send(.searchButtonTapped)
                    }, label: {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray2)
                    })
                    .disabled(store.noteQuery.isEmpty)
                }
                .padding(.horizontal, 20)
                .frame(height: 40)
                .background(Color.gray5)
                .cornerRadius(30)
                .padding(.top, 30)
                
                ScrollView(.horizontal) {
                    HStack(spacing: 8) {
                        ForEach(MarketCategory.allCases, id: \.self) { category in
                            Text(category.rawValue)
                                .textStyler(color: category == store.marketCategory
                                            ? .white
                                            : .gray3,
                                            font: .caption2)
                                .frame(width: 30)
                                .border(category == store.marketCategory
                                        ? .clear
                                        : .gray4,
                                        radius: 15,
                                        verticalPadding: 4,
                                        horizontalPadding: 12)
                                .background(category == store.marketCategory
                                            ? category.color
                                            : .clear)
                                .cornerRadius(15)
                                .onTapGesture {
                                    send(.categoryButtonTapped(category))
                                }
                        }
                    }
                }
                .padding(.vertical, 12)
                .scrollIndicators(.never)
                
                HStack(spacing: 12) {
                    Spacer()
                    ForEach(SortType.allCases, id: \.self) { sortType in
                        Text("• \(sortType.rawValue)")
                            .textStyler(color: sortType == store.sortType
                                        ? .gray1
                                        : .gray3,
                                        font: .caption2,
                                        weight: sortType == store.sortType
                                        ? .semibold
                                        : .regular)
                            .onTapGesture {
                                send(.sortButtonTapped(sortType))
                            }
                    }
                }
                
                ScrollView {
                    LazyVGrid(columns: Array(repeating: .init(.flexible()),
                                             count: 2),
                              spacing: 8) {
                        ForEach(store.queriedNoteList) { note in
                            MarketNoteCell(note: note)
                                .onTapGesture {
                                    send(.noteTapped(note))
                                }
                        }
                    }
                    
                }
                .scrollIndicators(.never)
                .emptyList(list: store.queriedNoteList.elements,
                           title: "마켓에 존재하는 암기장이 없어요.")
                .frame(height: proxy.size.height - 150)
            }
        }
        .overlay(alignment: .bottomTrailing) {
            PlusButton {
                send(.plusButtonTapped)
            }
            .padding(.bottom, 60)
        }
        .padding(.horizontal, 16)
        .navigationSetting()
        .toolbar {
            AppLogoToolbarItem(placement: .topBarLeading)
            TitleToolbarItem(title: "암기장 마켓")
            ToolbarItem(placement: .topBarTrailing) {
                Text("\(store.currentUser?.coin ?? 0)P")
                    .border(.mainBlue,
                            radius: 20,
                            verticalPadding: 8,
                            horizontalPadding: 14)
                    .textStyler(color: .mainBlue,
                                font: .caption)
                    .onTapGesture {
                        send(.coinButtonTapped)
                    }
            }
        }
    }
}

public enum MarketCategory: String, CaseIterable {
    case all = "전체"
    case english = "영어"
    case history = "한국사"
    case it = "IT"
    case economy = "경제"
    case knowledge = "시사"
    case etc = "기타"
    
    public var color: Color {
        switch self {
        case .all: .mainBlue
        case .english: .english
        case .history: .history
        case .it: .it
        case .economy: .economy
        case .knowledge: .knowledge
        case .etc: .etc
        }
    }
}

public enum SortType: String, CaseIterable {
    case reviewScore = "평점순"
    case reviewCount = "리뷰순"
    case sellCount = "판매순"
    case new = "최신순"
}

#Preview {
    @Shared(.currentUser) var currentUser
    currentUser = .mock
    return NavigationStack {
        MarketView(store:
                .init(
                    initialState: .init(noteList: .mock),
                    reducer: { MarketFeature()._printChanges() }
                    //                withDependencies: { _ in
                    //
                    //                }
                )
        )
    }
    
}

