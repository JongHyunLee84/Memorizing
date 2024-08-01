import ComposableArchitecture
import CommonUI
import EditProfileFeature
import Models
import NoteClient
import SwiftUI
import Shared

@Reducer
public struct ProfileFeature {
    @ObservableState
    public struct State: Equatable {
        @Shared(.currentUser) public var currentUser
        public var myNoteList: NoteList
        public var versionInfo: String
        @Presents var destination: Destination.State?
        public var path: StackState<Path.State>
        
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
        case destination(PresentationAction<Destination.Action>)
        case path(StackActionOf<Path>)
        case noteListResponse(NoteList)
        
        @CasePathable
        public enum View {
            case onFirstAppear
            case editProfileButtonTapped
            case purchaseHistoryButtonTapped
            case myReviewsButtonTapped
            case aboutMemorizingButtonTapped
            case csButtonTapped
            case logoutButtonTapped
            case privacyPolicyButtonTapped
        }
    }
    
    @Reducer(state: .equatable)
    public enum Destination {
        
    }
    
    @Reducer(state: .equatable)
    public enum Path {
        case editProfile(EditProfileFeature)
    }
    
    public init() {}
    
    @Dependency(\.noteClient) var noteClient
    
    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .view(.onFirstAppear):
                return .run { [userID = state.currentUser?.id] send in
                    guard let userID else { return }
                    let noteList = try await noteClient.getNoteList(userID: userID)
                    await send(.noteListResponse(noteList))
                }
            case let .noteListResponse(noteList):
                state.myNoteList = noteList
                return .none
            case .view(.editProfileButtonTapped):
                state.path.append(.editProfile(.init()))
                return .none
            case .view(.purchaseHistoryButtonTapped):
                return .none
            case .view(.myReviewsButtonTapped):
                return .none
            case .view(.aboutMemorizingButtonTapped):
                return .none
            case .view(.csButtonTapped):
                return .none
            case .view(.logoutButtonTapped):
                return .none
            case .view(.privacyPolicyButtonTapped):
                return .none
            case .destination:
                return .none
            case .path:
                return .none
            }
        }
        .forEach(\.path, action: \.path)
    }

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
            case let .editProfile(store):
                EditProfileView(store: store)
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
