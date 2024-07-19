import AddMarketFeature
import ComposableArchitecture
import CommonUI
import Models
import MarketClient
import MarketNoteDetailFeature
import Shared
import SwiftUI

@Reducer
public struct MarketFeature {
    @ObservableState
    public struct State: Equatable {
        @Shared(.currentUser) public var currentUser
        @Presents public var destination: Destination.State?
        public var noteList: IdentifiedArrayOf<MarketNote>
        public var queriedNoteList: IdentifiedArrayOf<MarketNote>
        public var noteQuery: String
        public var marketCategory: MarketCategory
        public var sortType: SortType
        
        public init(noteList: MarketNoteList = .init(),
                    noteQuery: String = "",
                    marketCategory: MarketCategory = .all,
                    sortType: SortType = .reviewScore) {
            self.noteList = .init(uniqueElements: noteList)
            self.queriedNoteList = .init(uniqueElements: noteList)
            self.noteQuery = noteQuery
            self.marketCategory = marketCategory
            self.sortType = sortType
        }
    }
    
    public enum Action: ViewAction {
        case view(View)
        case marketNoteRequest
        case marketNoteListResponse(MarketNoteList)
        case destination(PresentationAction<Destination.Action>)
        
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
    
    @Reducer(state: .equatable)
    public enum Destination {
        case alert(AlertState<Alert>)
        case addMarket(AddMarketFeature)
        case marketNoteDetail(MarketNoteDetailFeature)
        @CasePathable
        public enum Alert {
            case coinButtonTapped
        }
    }
    
    public init() {}
    
    @Dependency(\.marketClient) var marketClient
    
    public var body: some ReducerOf<Self> {
        BindingReducer(action: \.view)
        Reduce { state, action in
            switch action {
                
            case let .marketNoteListResponse(noteList):
                let noteList: IdentifiedArrayOf<MarketNote> = .init(uniqueElements: noteList)
                state.noteList = noteList
                state.queriedNoteList = noteList
                return .none
                
            case .marketNoteRequest:
                return .run { send in
                    await send(.marketNoteListResponse(
                        try await marketClient.getMarketList()
                    ))
                }

            case .view(.onFirstAppear):
                return .send(.marketNoteRequest)
                
            case .view(.coinButtonTapped):
                state.destination = .alert(.coin)
                return .none
                
            case .view(.searchButtonTapped):
                state.queriedNoteList = filtering(state)
                return .none
                
            case let .view(.categoryButtonTapped(category)):
                state.marketCategory = category
                state.queriedNoteList = filtering(state)
                return .none
                
            case .view(.binding(\.noteQuery)):
                if state.noteQuery.isEmpty {
                    state.queriedNoteList = filtering(state)
                }
                return .none
                
            case let .view(.sortButtonTapped(sortType)):
                guard state.sortType != sortType else {
                    return .none
                }
                state.sortType = sortType
                state.queriedNoteList = sorting(state.queriedNoteList,
                                                sortType: state.sortType)
                return .none
            
                // MARK: MarketNoteDetail
            case let .view(.noteTapped(note)):
                state.destination = .marketNoteDetail(
                    MarketNoteDetailFeature.State(note: note)
                )
                return .none
                
                // MARK: - AddMarket
            case .view(.plusButtonTapped):
                state.destination = .addMarket(AddMarketFeature.State())
                return .none
                
            case .destination(.presented(.addMarket(.view(.addButtonTapped)))):
                return .send(.marketNoteRequest)
                
            case .view(.binding):
                return .none
            case .destination:
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
    
    public func filtering(_ state: State) -> IdentifiedArrayOf<MarketNote> {
        state.noteList
            .filter {
                if state.noteQuery.isEmpty { return true }
                else { return $0.noteName.contains(state.noteQuery)
                    || $0.noteCategory.contains(state.noteQuery)
                }
            }
            .filter {
                if state.marketCategory == .all { return true }
                else {
                    return $0.noteCategory == state.marketCategory.rawValue
                }
            }
    }
    
    public func sorting(_ noteList: IdentifiedArrayOf<MarketNote>, sortType: SortType) -> IdentifiedArrayOf<MarketNote> {
        return .init(
            uniqueElements: noteList.sorted {
                switch sortType {
                case .reviewScore:
                    return $0.reviewScoreAverage >= $0.reviewScoreAverage
                case .reviewCount:
                    return $0.reviewCount >= $1.reviewCount
                case .sellCount:
                    return $0.salesCount >= $1.salesCount
                case .new:
                    return $0.updateDate >= $1.updateDate
                }
            }
        )
    }
}

extension AlertState where Action == MarketFeature.Destination.Alert {
    public static let coin = Self(
        title: { TextState("포인트를 얻는 방법") },
        actions: { 
            ButtonState(role: .destructive, action: .coinButtonTapped) {
                TextState("확인")
            }
        },
        message: {
            // TODO: 각 케이스마다 Coin 올려주기
            TextState("""
1. 4번의 확습을 완료하고 도장을 받아봐요~!
2. 사람들에게 나만의 암기장을 판매해봐요~!
3. 구매한 암기장에 리뷰를 작성해봐요~!
""")
        }
    )
}

@ViewAction(for: MarketFeature.self)
public struct MarketView: View {
    @Bindable public var store: StoreOf<MarketFeature>
    
    public var body: some View {
        GeometryReader { proxy in
            LazyVStack {
                SearchBar()
                CategoryList()
                SortList()
                NoteList()
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
        .customAlert($store.scope(state: \.destination?.alert,
                                  action: \.destination.alert))
        .task {
            await send(.onFirstAppear).finish()
        }
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
        .fullScreenCover(
            item: $store.scope(
                state: \.destination?.addMarket,
                action: \.destination.addMarket
            )
        ) { store in
            NavigationStack {
                AddMarketView(store: store)
            }
        }
        .fullScreenCover(
            item: $store.scope(
                state: \.destination?.marketNoteDetail,
                action: \.destination.marketNoteDetail
            )
        ) { store in
                MarketNoteDetailView(store: store)
        }
    }
    
    private func SearchBar() -> some View {
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
        }
        .padding(.horizontal, 20)
        .frame(height: 40)
        .background(Color.gray5)
        .cornerRadius(30)
        .padding(.top, 30)
    }
    
    private func CategoryList() -> some View {
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
    }
    
    private func SortList() -> some View {
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

    }
    
    private func NoteList() -> some View {
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

