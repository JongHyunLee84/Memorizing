import ComposableArchitecture
import ProfileFeature
import SwiftUI

@main
struct ProfileFeatureAppApp: App {
    @Shared(.currentUser) var currentUser = .mock
    let store = Store(
        initialState: .init(),
        reducer: { ProfileFeature()._printChanges() },
        withDependencies: {
            $0.noteClient = .previewValue
            $0.marketClient = .previewValue
            $0.authClient = .previewValue
            $0.urlClient = .previewValue
            $0.reviewClient = .previewValue
            $0.myReviewClient = .previewValue
        })
    var body: some Scene {
        WindowGroup {
            if store.currentUser != nil {
                ProfileView(store: store)
            } else {
                Text("Login View")
            }
        }
    }
}
