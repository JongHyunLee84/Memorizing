import AuthClient
import ComposableArchitecture
import Models
import Shared

@Reducer
public struct LoginFeature {
    @ObservableState
    public struct State: Equatable {
        @Shared(.toastMessage) public var toastMessage
        @Shared(.currentUser) public var currentUser
        public var loginProcessInFlight: Bool
        
        public init() {
            self.loginProcessInFlight = false
        }
    }
    
    public enum Action: ViewAction {
        case loginSuccessResponse(CurrentUser)
        case loginFailResponse
        case view(View)
        
        @CasePathable
        public enum View: BindableAction {
            case binding(BindingAction<State>)
            case appleLoginButtonTapped
            case kakaoLoginButtonTapped
            case googleLoginButtonTapped
        }
    }
    
    public init() {}
    
    @Dependency(\.authClient) var authClient
    
    public var body: some Reducer<State, Action> {
        BindingReducer(action: \.view)
        Reduce { state, action in
            switch action {
                
            case .view(.appleLoginButtonTapped):
                state.loginProcessInFlight = true
                return .run { send in
                    if let currentUser = try? await authClient.appleSignIn() {
                        await send(.loginSuccessResponse(currentUser))
                    } else {
                        await send(.loginFailResponse)
                    }
                }
                
            case .view(.googleLoginButtonTapped):
                state.loginProcessInFlight = true
                return .run { send in
                    if let currentUser = try? await authClient.googleSignIn() {
                        await send(.loginSuccessResponse(currentUser))
                    } else {
                        await send(.loginFailResponse)
                    }
                }
                
            case .view(.kakaoLoginButtonTapped):
                state.loginProcessInFlight = true
                return .run { send in
                    if let currentUser = try? await authClient.kakaoSignIn() {
                        await send(.loginSuccessResponse(currentUser))
                    } else {
                        await send(.loginFailResponse)
                    }
                }
                
            case let .loginSuccessResponse(currentUser):
                state.currentUser = currentUser
                state.loginProcessInFlight = false
                return .none
                
            case .loginFailResponse:
                state.toastMessage = "로그인에 실패했어요"
                state.loginProcessInFlight = false
                return .none
            
            case .view(.binding):
                return .none
            }
        }
    }
    
}
