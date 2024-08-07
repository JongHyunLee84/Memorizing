import ComposableArchitecture
import CoreApp
import SwiftUI

@main
struct CorePreviewAppApp: App {
    var body: some Scene {
        WindowGroup {
            CoreAppView(
                store: .init(
                    initialState: .init(),
                    reducer: { CoreApp()._printChanges() },
                    withDependencies: {
                        $0.noteClient = .previewValue
                        $0.marketClient = .previewValue
                        $0.reviewClient = .previewValue
                        $0.urlClient = .previewValue
                        $0.urlClient = .previewValue
                        $0.authClient = .previewValue
                        $0.myReviewClient = .previewValue
                    }
                )
            )
        }
    }
}
