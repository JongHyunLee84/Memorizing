import AuthClient
import ComposableArchitecture
import CommonUI
import EditProfileFeature
import Models
import NoteClient
import PurchaseHistoryFeature
import ReviewHistoryFeature
import SwiftUI
import Shared
import URLClient
import WriteReviewFeature

@Reducer
public struct ProfileFeature {
    @ObservableState
    public struct State: Equatable {
        @Shared(.currentUser) public var currentUser
        public var myNoteList: NoteList
        public var versionInfo: String
        @Presents public var destination: Destination.State?
        public var path: StackState<Path.State>
        public var introduceURL: URL?
        public var privacyPolicyURL: URL?
        public var csURL: URL?
        
        public init(
            myNoteList: NoteList = [],
            versionInfo: String = "",
            destination: Destination.State? = nil,
            path: StackState<Path.State> = .init()
        ) {
            self.myNoteList = myNoteList
            self.versionInfo = versionInfo
            self.destination = destination
            self.path = path
        }
        
        public var myNoteCount: Int {
            myNoteList.count
        }
        
        public var myStampCount: Int {
            myNoteList.filter { $0.repeatCount >= 4 }.count
        }
    }
    
    public enum Action: ViewAction {
        case view(View)
        case path(StackActionOf<Path>)
        case destination(PresentationAction<Destination.Action>)
        case noteListResponse(NoteList)
        case webviewURLResponse((intro: URL?, privacy: URL?, cs: URL?))
        
        @CasePathable
        public enum View {
            case onFirstAppear
            case editProfileButtonTapped
            case purchaseHistoryButtonTapped
            case myReviewsButtonTapped
            case aboutMemorizingButtonTapped
            case privacyPolicyButtonTapped
            case csButtonTapped
            case logoutButtonTapped
        }
    }
    
    @Reducer(state: .equatable)
    public enum Destination: Equatable {
        case aboutMemorizing
        case cs
        case privacyPolicy
        case alert(AlertState<Alert>)
        
        @CasePathable
        public enum Alert {
            case logout
        }
    }
    
    @Reducer(state: .equatable)
    public enum Path {
        case editProfile(EditProfileFeature)
        case purchaseHistory(PurchaseHistoryFeature)
        case reviewHistory(ReviewHistoryFeature)
        case writeReview(WriteReviewFeature)
    }
    
    public init() {}
    
    @Dependency(\.noteClient) var noteClient
    @Dependency(\.urlClient) var urlClient
    @Dependency(\.authClient) var authClient
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .view(.onFirstAppear):
                return .run { [userID = state.currentUser?.id] send in
                    guard let userID else { return }
                    let noteList = try await noteClient.getNoteList(userID: userID)
                    await send(.noteListResponse(noteList))
                    async let introduce = urlClient.getIntroduceURL()
                    async let privacy = urlClient.getPrivacyPolicyURL()
                    async let cs = urlClient.getCSURL()
                    await send(.webviewURLResponse((intro: introduce,
                                                    privacy: privacy,
                                                    cs: cs)))
                }
            case let .noteListResponse(noteList):
                state.myNoteList = noteList
                return .none
                
            case .webviewURLResponse(let urls):
                state.introduceURL = urls.intro
                state.privacyPolicyURL = urls.privacy
                state.csURL = urls.cs
                return .none
                
            case .view(.editProfileButtonTapped):
                state.path.append(.editProfile(.init()))
                return .none
                
            case .view(.purchaseHistoryButtonTapped):
                state.path.append(.purchaseHistory(.init(noteList: state.myNoteList)))
                return .none
                
            case let .path(.element(id: id, action: .purchaseHistory(.view(.writeReviewButtonTapped(noteID))))):
                guard let note = state.path[id: id]?.purchaseHistory?.purchaseHistoryNoteList[id: noteID]?.note else {
                    return .none
                }
                state.path.append(.writeReview(.init(note: note)))
                return .none
                
            case .view(.myReviewsButtonTapped):
                state.path.append(.reviewHistory(.init()))
                return .none
                
            case .view(.aboutMemorizingButtonTapped):
                state.destination = .aboutMemorizing
                return .none
                
            case .view(.csButtonTapped):
                state.destination = .cs
                return .none
                
            case .view(.privacyPolicyButtonTapped):
                state.destination = .privacyPolicy
                return .none
                
            case .view(.logoutButtonTapped):
                state.destination = .alert(.logout)
                return .none
                
            case .destination(.presented(.alert(.logout))):
                state.currentUser = nil
                return .run { _ in
                    try await authClient.signOut()
                }
                
            case .path:
                return .none
                
            case .destination:
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
        .forEach(\.path, action: \.path)
    }
}

extension AlertState where Action == ProfileFeature.Destination.Alert {
    public static let logout = Self(
        title: { TextState("로그아웃") },
        actions: {
            ButtonState(role: .cancel) {
                TextState("취소")
            }
            ButtonState(role: .destructive,
                        action: .logout) {
                TextState("확인")
            }
        },
        message: { TextState("정말 로그아웃 하시겠습니까?") }
    )
}


@ViewAction(for: ProfileFeature.self)
public struct ProfileView: View {
    @Bindable public var store: StoreOf<ProfileFeature>
    
    public init(store: StoreOf<ProfileFeature>) {
        self.store = store
    }
    
    public var body: some View {
        NavigationStack(path: $store.scope(state: \.path,
                                           action: \.path)) {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    UserInfoView()
                    ProfileListView()
                        .padding(.top, 24)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
            }
            .customAlert($store.scope(state: \.destination?.alert,
                                      action: \.destination.alert))
            .sheet(item: $store.scope(state: \.destination?.aboutMemorizing,
                                      action: \.destination.aboutMemorizing)) { _ in
                if let introduceURL = store.introduceURL {
                    SheetWebView(introduceURL)
                }
            }
            .sheet(item: $store.scope(state: \.destination?.cs,
                                      action: \.destination.cs)) { _ in
                if let csURL = store.csURL {
                    SheetWebView(csURL)
                }
            }
            .sheet(item: $store.scope(state: \.destination?.privacyPolicy,
                                      action: \.destination.privacyPolicy)) { _ in
                if let privacyPolicyURL = store.privacyPolicyURL {
                    SheetWebView(privacyPolicyURL)
                }
            }
            .scrollIndicators(.never)
            .onFirstTask {
                send(.onFirstAppear)
            }
            .navigationSetting()
            .toolbar {
                AppLogoToolbarItem(placement: .topBarLeading)
                TitleToolbarItem(title: "마이페이지")
            }
        } destination: { store in
            switch store.case {
            case .editProfile(let store):
                EditProfileView(store: store)
                
            case .purchaseHistory(let store):
                PurchaseHistoryView(store: store)
                
            case .reviewHistory(let store):
                ReviewHistoryView(store: store)
                
            case .writeReview(let store):
                WriteReviewView(store: store)
            }
        }
    }
    
    private func UserInfoView() -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("안녕하세요")
                .textStyler(font: .title3,
                            weight: .semibold)
            Text("\(store.currentUser?.nickname ?? "???")님!")
                .textStyler(font: .title,
                            weight: .semibold)
            Text(store.currentUser?.email ?? "")
                .font(.footnote)
                .padding(.bottom, 12)
            HStack {
                MyCountView(title: "내 암기장",
                            count: store.myNoteCount)
                MyCountView(title: "내 도장",
                            count: store.myStampCount)
                Spacer()
                MainButton(title: "내 정보 수정하기",
                           textColor: .black,
                           backgroundColor: .white,
                           borderColor: .mainBlue,
                           font: .footnote,
                           radius: 30,
                           height: 43) {
                    send(.editProfileButtonTapped)
                }
                           .frame(width: 120)
            }
        }
        .padding(.top, 32)
    }
    
    private func MyCountView(
        title: String,
        count: Int
    ) -> some View {
        HStack(spacing: 12) {
            VStack(spacing: 6) {
                Text(title)
                    .textStyler(color: .gray2, font: .footnote)
                Text(count.description)
                    .textStyler(color: .mainBlack,
                                font: .footnote,
                                weight: .semibold)
            }
            Rectangle()
                .fill(Color.gray5)
                .frame(width: 1)
        }
    }
    
    private func ProfileListView() -> some View {
        VStack(spacing: 20) {
            ForEach(profileList, id: \.title) { section in
                VStack(spacing: 12) {
                    HStack {
                        Text(section.title)
                            .textStyler(color: .gray2, font: .footnote)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                    }
                    .contentShape(.rect)
                    .onTapGesture {
                        send(section.action)
                    }
                    CustomDivider()
                }
            }
        }
    }
    
    private var profileList: [ProfileSection] = [
        .init(title: "마켓 거래내역",
              action: .purchaseHistoryButtonTapped),
        .init(title: "내가 작성한 리뷰",
              action: .myReviewsButtonTapped),
        .init(title: "메모라이징 소개",
              action: .aboutMemorizingButtonTapped),
        .init(title: "1:1 문의하기",
              action: .csButtonTapped),
        .init(title: "이용약관 및 개인정보 처리방침",
              action: .privacyPolicyButtonTapped),
        .init(title: "로그아웃하기",
              action: .logoutButtonTapped)
    ]
    
    struct ProfileSection {
        let title: String
        let action: ProfileFeature.Action.View
    }
    
    private func SheetWebView(_ url: URL) -> some View {
        SafariWebView(url: url)
            .ignoresSafeArea()
            .presentationDetents([.fraction(0.95)])
    }
}

#Preview {
    @Shared(.currentUser) var currentUser
    currentUser = .mock
    
    return ProfileView(
        store: .init(
            initialState: .init(),
            reducer: { ProfileFeature()._printChanges() }
        )
    )
}
