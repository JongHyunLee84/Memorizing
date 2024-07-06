import CommonUI
import ComposableArchitecture
import SwiftUI

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
                .border(.gray4, 20)
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
