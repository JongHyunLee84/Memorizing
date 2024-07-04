import AuthClient
import ComposableArchitecture
import LoginFeature
import XCTest

final class LoginFeatureTest: XCTestCase {
    @MainActor
    func testLoginSuccessCase() async {
        let store = TestStore(
            initialState: LoginFeature.State(),
            reducer: { LoginFeature() },
            withDependencies: { $0.uuid = .incrementing }
        )
        
        // MARK: - Apple
        await store.send(\.view.appleLoginButtonTapped) {
            $0.loginProcessInFlight = true
        }
        await store.receive(\.loginSuccessResponse) {
            $0.currentUser = .mock
            $0.loginProcessInFlight = false
        }
        
        // MARK: - Kakao
        await store.send(\.view.kakaoLoginButtonTapped) {
            $0.loginProcessInFlight = true
        }
        await store.receive(\.loginSuccessResponse) {
            $0.currentUser = .mock
            $0.loginProcessInFlight = false
        }
        
        // MARK: - Google
        await store.send(\.view.googleLoginButtonTapped) {
            $0.loginProcessInFlight = true
        }
        await store.receive(\.loginSuccessResponse) {
            $0.currentUser = .mock
            $0.loginProcessInFlight = false
        }
    }
    
    @MainActor
    func testLoginFailCase() async {
        let clock = TestClock()
        let store = TestStore(
            initialState: LoginFeature.State(),
            reducer: { LoginFeature() },
            withDependencies: {
                $0.continuousClock =  clock
                $0.authClient.appleSignIn = {
                    try await clock.sleep(for: .seconds(1))
                    throw NSError()
                }
                $0.authClient.kakaoSignIn = {
                    try await clock.sleep(for: .seconds(1))
                    throw NSError()
                }
                $0.authClient.googleSignIn = {
                    try await clock.sleep(for: .seconds(1))
                    throw NSError()
                }
            }
        )
        
        // MARK: - Apple
        await store.send(.view(.appleLoginButtonTapped)) {
            $0.loginProcessInFlight = true
        }
        await clock.advance(by: .seconds(1))
        await store.receive(\.loginFailResponse) {
            $0.loginProcessInFlight = false
            $0.toastMessage = "로그인에 실패했어요"
        }
        await clock.advance(by: .seconds(2.5))
        await store.send(\.view.binding.toastMessage, nil) {
            $0.toastMessage = nil
        }
        // MARK: - Kakao
        await store.send(.view(.kakaoLoginButtonTapped)) {
            $0.loginProcessInFlight = true
        }
        await clock.advance(by: .seconds(1))
        await store.receive(\.loginFailResponse) {
            $0.loginProcessInFlight = false
            $0.toastMessage = "로그인에 실패했어요"
        }
        await clock.advance(by: .seconds(2.5))
        await store.send(\.view.binding.toastMessage, nil) {
            $0.toastMessage = nil
        }
        
        // MARK: - Google
        await store.send(.view(.googleLoginButtonTapped)) {
            $0.loginProcessInFlight = true
        }
        await clock.advance(by: .seconds(1))
        await store.receive(\.loginFailResponse) {
            $0.loginProcessInFlight = false
            $0.toastMessage = "로그인에 실패했어요"
        }
        await clock.advance(by: .seconds(2.5))
        await store.send(\.view.binding.toastMessage, nil) {
            $0.toastMessage = nil
        }
    }

}
