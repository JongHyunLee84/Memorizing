import ComposableArchitecture
import CommonUI
import Models
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
        
        public init(
            myNoteList: NoteList = [],
            versionInfo: String = "",
            destination: Destination.State? = nil
        ) {
            self.myNoteList = myNoteList
            self.versionInfo = versionInfo
            self.destination = destination
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

        @CasePathable
        public enum View {
            case onFirstAppear
            case editProfileButtonTapped
            case purchaseHistoryButtonTapped
            case myReviewsButtonTapped
            case aboutMemorizingButtonTapped
            case csButtonTapped
            case termsOfServiceButtonTapped
            case privacyPolicyButtonTapped
        }
    }
    
    @Reducer(state: .equatable)
    public enum Destination {
        
    }
    
    public init() {}
    
    public var body: some ReducerOf<Self> {
        EmptyReducer()
    }
    
}

public struct ProfileView: View {
    var store: StoreOf<ProfileFeature>
    
    public init(store: StoreOf<ProfileFeature>) {
        self.store = store
    }
    
    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                UserInfoView()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16)
        }
        .scrollIndicators(.never)
        .navigationSetting()
        .toolbar {
            AppLogoToolbarItem(placement: .topBarLeading)
            TitleToolbarItem(title: "마이페이지")
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
                           backgroundColor: .white,
                           font: .footnote,
                           radius: 30,
                           height: 43) {
                    
                }
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
}

#Preview {
    @Shared(.currentUser) var currentUser
    currentUser = .mock
    
    return NavigationStack {
        ProfileView(
            store: .init(
                initialState: .init(),
                reducer: { ProfileFeature() }
            )
        )
    }
}
