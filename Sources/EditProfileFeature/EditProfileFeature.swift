import AuthClient
import CommonUI
import ComposableArchitecture
import Models
import SwiftUI
import Shared

@Reducer
public struct EditProfileFeature {
    
    @ObservableState
    public struct State: Equatable {
        @Shared(.currentUser) public var currentUser
        @Presents public var alert: AlertState<Action.Alert>?
        public var nicknameStr: String
        public var toastMessage: String?
        public init(
            nicknameStr: String = "",
            toastMessage: String? = nil
        ) {
            self.nicknameStr = nicknameStr
            self.toastMessage = toastMessage
        }
    }
    
    public enum Action: ViewAction {
        case view(View)
        case alert(PresentationAction<Alert>)
        case toastMessage(String)
        case resetNicknameStr
        
        @CasePathable
        public enum View: BindableAction {
            case binding(BindingAction<State>)
            case backButtonTapped
            case changeButtonTapped
            case withdrawalButtonTapped
        }
        @CasePathable
        public enum Alert: Equatable {
            case confirmWithdrawal
        }
    }
    
    public init() {}
    
    @Dependency(\.authClient) var authClient
    @Dependency(\.dismiss) var dismiss
    
    public var body: some ReducerOf<Self> {
        BindingReducer(action: \.view)
        Reduce { state, action in
            switch action {
            case .view(.backButtonTapped):
                return .run { _ in
                    await dismiss()
                }
                
            case .view(.changeButtonTapped):
                return .run { [currentUser = state.$currentUser,
                               nickname = state.nicknameStr] send in
                    try await authClient.changeNickname(nickname)
                    await currentUser.withLock { $0?.nickname = nickname }
                    await send(.toastMessage("이름이 변경되었어요."))
                    await send(.resetNicknameStr)
                }
                
            case .resetNicknameStr:
                state.nicknameStr = ""
                return .none
                
            case let .toastMessage(message):
                state.toastMessage = message
                return .none
                
            case .view(.withdrawalButtonTapped):
                state.alert = AlertState(
                    title: TextState("탈퇴하기"),
                    message: TextState("삭제된 회원정보는 복구할 수 없어요!"),
                    buttons: [
                        .init(role: .cancel,
                              label: { TextState("취소") }),
                        .init(role: .destructive,
                              action: .confirmWithdrawal,
                              label: { TextState("탈퇴하기") })
                    ]
                )
                return .none
                
            case .alert(.presented(.confirmWithdrawal)):
                return .run { [currentUser = state.$currentUser] _ in
                    try await authClient.deleteUser()
                    await currentUser.withLock { $0 = nil }
                    await dismiss()
                }
                
            case .view(.binding(\.nicknameStr)):
                if state.nicknameStr.count > 5 {
                    state.nicknameStr = String(state.nicknameStr.prefix(5))
                }
                return .none
                
            case .view:
                return .none
                
            case .alert:
                return .none
            }
        }
        .ifLet(\.$alert, action: \.alert)
    }
}

@ViewAction(for: EditProfileFeature.self)
public struct EditProfileView: View {
    @Bindable public var store: StoreOf<EditProfileFeature>
    
    public init(
        store: StoreOf<EditProfileFeature>
    ) {
        self.store = store
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("이름 변경")
                .frame(maxWidth: .infinity, alignment: .leading)
                .textStyler(weight: .semibold)
                .padding(.vertical, 12)
            
            VStack(spacing: 2) {
                CustomTextEditor(placeholder: "이름을 입력해주세요 (최대 5글자)",
                                 text: $store.nicknameStr,
                                 backgroundColor: .clear)
                .frame(height: 35)
                CustomDivider()
            }
            
            MainButton(title: "변경하기",
                       font: .callout,
                       isAvailable: !store.nicknameStr.isEmpty) {
                send(.changeButtonTapped)
            }
                       .padding(.vertical, 12)
            
            Spacer()
            
            Text("탈퇴하기")
                .textStyler(color: .gray3,
                            font: .callout)
                .onTapGesture {
                    send(.withdrawalButtonTapped)
                }
        }
        .padding(.horizontal, 16)
        .customAlert($store.scope(state: \.alert,
                                  action: \.alert))
        .toastMessage(messsage: $store.toastMessage)
        .navigationSetting()
        .toolbar {
            BackButtonToolbarItem {
                send(.backButtonTapped)
            }
            TitleToolbarItem(title: "내 정보 수정")
        }
    }
}

#Preview {
    @Shared(.currentUser) var currentUser
    currentUser = .mock
    return NavigationStack {
        EditProfileView(store:
                .init(initialState: .init(),
                      reducer: { EditProfileFeature()._printChanges() }
                     )
        )
    }
}
