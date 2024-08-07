import ComposableArchitecture
import LoginFeature
import Models
import MyNoteFeature
import MarketFeature
import ProfileFeature
import SwiftUI
import Shared

@Reducer
public struct CoreApp {
    @ObservableState
    public struct State: Equatable {
        @Shared(.currentUser) public var currentUser
        public var currentTab: Tab
        public var myNote: MyNoteFeature.State
        public var market: MarketFeature.State
        public var profile: ProfileFeature.State
        public var login: LoginFeature.State
        
        public init(
            currentTab: Tab = .myNote,
            myNote: MyNoteFeature.State = .init(),
            market: MarketFeature.State = .init(),
            profile: ProfileFeature.State = .init(),
            login: LoginFeature.State = .init()
        ) {
            self.currentTab = currentTab
            self.myNote = myNote
            self.market = market
            self.profile = profile
            self.login = login
        }
    }
    
    public enum Action: BindableAction {
        case binding(BindingAction<State>)
        case myNote(MyNoteFeature.Action)
        case market(MarketFeature.Action)
        case profile(ProfileFeature.Action)
        case login(LoginFeature.Action)
    }
    
    public init() {}
    
    public var body: some ReducerOf<Self> {
        Scope(state: \.myNote, action: \.myNote) {
            MyNoteFeature()
        }
        Scope(state: \.market, action: \.market) {
            MarketFeature()
        }
        Scope(state: \.profile, action: \.profile) {
            ProfileFeature()
        }
        Scope(state: \.login, action: \.login) {
            LoginFeature()
        }
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding:
                return .none
            case .myNote, .market, .profile, .login:
                return .none
            }
        }
    }
}

public enum Tab { case myNote, market, profile }

public struct CoreAppView: View {
    @Bindable public var store: StoreOf<CoreApp>
    
    public init(
        store: StoreOf<CoreApp>
    ) {
        self.store = store
    }
    
    public var body: some View {
        if store.currentUser != nil {
            MainView()
        } else {
            LoginView(store: store.scope(state: \.login,
                                         action: \.login))
        }
    }
    
    private func MainView() -> some View {
        TabView(selection: $store.currentTab) {
            MyNoteView(
                store: store.scope(state: \.myNote,
                                   action: \.myNote)
            )
            .tabItem {
                TabItem(tab: .myNote,
                        imgName: "note.text",
                        title: "내 암기장")
            }
            .tag(Tab.myNote)
            
            NavigationStack{
                MarketView(
                    store: store.scope(state: \.market,
                                       action: \.market)
                )
            }
            .tabItem {
                TabItem(tab: .market,
                        imgName: "cart",
                        title: "마켓")
            }
            .tag(Tab.market)
            
            ProfileView(
                store: store.scope(state: \.profile,
                                   action: \.profile)
            )
            .tabItem {
                TabItem(tab: .profile,
                        imgName: "person.crop.circle",
                        title: "프로필")
            }
            .tag(Tab.profile)
        }

    }
    
    private func TabItem(
        tab: Tab,
        imgName: String,
        title: String
    ) -> some View {
        VStack {
            Image(systemName: imgName)
                .textColor(store.currentTab == tab ? .mainBlue : .gray3)
            Text(title)
        }
    }
}

#Preview {
    @Shared(.currentUser) var currentUser
    currentUser = nil
    return CoreAppView(
        store: .init(
            initialState: .init(),
            reducer: { CoreApp() }
        )
    )
}
