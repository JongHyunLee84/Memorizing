import ComposableArchitecture
import LoginFeature
import SwiftUI

@main
struct LoginFeatureApp: App {
    let store: StoreOf<LoginFeature> = .init(
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

    var body: some Scene {
        WindowGroup {
            LoginView(store: store)
        }
    }
}
