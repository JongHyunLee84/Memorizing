import ComposableArchitecture
import LoginFeature
import SwiftUI

@main
struct LoginFeatureApp: App {
    let store = Store(initialState: LoginFeature.State(),
                      reducer: { LoginFeature() },
                      withDependencies: { $0.authClient = .testValue })

    var body: some Scene {
        WindowGroup {
            VStack {
                if store.currentUser != nil {
                    Text("Login Success")
                } else {
                    LoginView(store: store)
                }
            }
        }
    }
}
