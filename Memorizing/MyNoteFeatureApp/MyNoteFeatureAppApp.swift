import ComposableArchitecture
import MyNoteFeature
import SwiftUI

@main
struct MyNoteFeatureAppApp: App {
    var body: some Scene {
        WindowGroup {
            MyNoteView(store:
                        Store(
                            initialState: MyNoteFeature.State.init(),
                            reducer: { MyNoteFeature()._printChanges() },
                            withDependencies: {
                                $0.noteClient = .testValue
                                @Shared(.currentUser) var currentUser
                                currentUser = .mock
                            }
                        )
            )
        }
    }
}
