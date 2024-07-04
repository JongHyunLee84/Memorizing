import AuthClient
import ComposableArchitecture
import Models
import Shared

@Reducer
public struct LoginFeature {
    @ObservableState
    public struct State: Equatable {
        
        @Shared(.currentUser) var currentUser
        var loginProcessInFlight: Bool
        
        public init() {
            self.loginProcessInFlight = false
        }
    }
    
    public enum Action: ViewAction {
        case loginSuccessResponse(CurrentUser)
        case view(View)
        
        @CasePathable
        public enum View {
            case appleLoginButtonTapped
            case kakaoLoginButtonTapped
            case googleLoginButtonTapped
        }
    }
    
    public init() {}
    
    @Dependency(\.authClient) var authClient
    
    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .view(.appleLoginButtonTapped):
                state.loginProcessInFlight = true
                return .run { send in
                    let currentUser = try await authClient.appleSignIn()
                    await send(.loginSuccessResponse(currentUser))
                }
            case .view(.googleLoginButtonTapped):
                state.loginProcessInFlight = true
                return .run { send in
                    let currentUser = try await authClient.googleSignIn()
                    await send(.loginSuccessResponse(currentUser))
                }
            case .view(.kakaoLoginButtonTapped):
                state.loginProcessInFlight = true
                return .run { send in
                    let currentUser = try await authClient.kakaoSignIn()
                    await send(.loginSuccessResponse(currentUser))
                }            case let .loginSuccessResponse(currentUser):
                state.currentUser = currentUser
                state.loginProcessInFlight = false
                return .none
            }
        }
    }
    
}
