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
        case loginResponse(Result<CurrentUser, Error>)
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
                    await send(
                        .loginResponse(
                            Result {
                                try await authClient.appleSignIn()
                            }
                        )
                    )
                }
                
            case .view(.googleLoginButtonTapped):
                state.loginProcessInFlight = true
                return .run { send in
                    await send(
                        .loginResponse(
                            Result {
                                try await authClient.googleSignIn()
                            }
                        )
                    )
                }
                
            case .view(.kakaoLoginButtonTapped):
                state.loginProcessInFlight = true
                return .run { send in
                    await send(
                        .loginResponse(
                            Result {
                                try await authClient.kakaoSignIn()
                            }
                        )
                    )
                }
                
            case let .loginResponse(.success(currentUser)):
                state.currentUser = currentUser
                state.loginProcessInFlight = false
                return .none
                
            case .loginResponse(.failure):
                state.toastMessage = "로그인에 실패했어요"
                state.loginProcessInFlight = false
                return .none
            
            case .view(.binding):
                return .none
            }
        }
    }
    
}
