import AuthClient
import CommonUI
import ComposableArchitecture
import Models
import Shared
import SwiftUI

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

// MARK: - View

@ViewAction(for: LoginFeature.self)
public struct LoginView: View {
    
    @Bindable public var store: StoreOf<LoginFeature>
    
    public init(store: StoreOf<LoginFeature>) {
        self.store = store
    }
    
    public var body: some View {
        VStack {
            Image.loginTitle
                .padding(.top, 100)
            
            Spacer()
            
            VStack(spacing: 10) {
                OauthButton(
                    image: .appleIcon,
                    title: "Apple로 로그인",
                    textColor: .white,
                    backgroundColor: .mainBlack
                ) {
                    send(.appleLoginButtonTapped)
                }
                OauthButton(
                    image: .kakaoIcon,
                    title: "Kakao로 로그인",
                    textColor: .mainBlack,
                    backgroundColor: .kakaoBackground
                ) {
                    send(.kakaoLoginButtonTapped)
                }
                OauthButton(
                    image: .googleIcon,
                    title: "Google로 로그인",
                    textColor: .mainBlack,
                    backgroundColor: .mainWhite
                ) {
                    send(.googleLoginButtonTapped)
                }
                .border(.gray4, radius: 20)
            }
            .padding(.horizontal, 50)
            
            Spacer()
        }
        .allowsHitTesting(!store.loginProcessInFlight)
        .overlay {
            if store.loginProcessInFlight {
                ProgressView()
            }
        }
        .toastMessage(messsage: $store.toastMessage)
    }
}

#Preview {
    LoginView(store:
            .init(
                initialState: .init(),
                reducer: {
                    LoginFeature()
                        ._printChanges()
                },
                withDependencies: { dependency in
                    dependency.authClient = .testValue
                    dependency.authClient.appleSignIn = {
                        try await Task.sleep(nanoseconds: 2_000_000_000)
                        return .mock
                    }
                    dependency.authClient.kakaoSignIn = {
                        try await Task.sleep(nanoseconds: 2_000_000_000)
                        enum PreViewError: Error { case error }
                        throw PreViewError.error
                    }
                }
            )
    )
}

