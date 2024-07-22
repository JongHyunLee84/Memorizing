import ComposableArchitecture
import MyNoteFeature
import SwiftUI

@main
struct MyNoteFeatureAppApp: App {
    @Shared(.currentUser) var currentUser = .mock
    var body: some Scene {
        WindowGroup {
            MyNoteView(store:
                        Store(
                            initialState: MyNoteFeature.State.init(),
                            reducer: { MyNoteFeature()._printChanges() },
                            withDependencies: {
                                $0.noteClient = .testValue
                            }
                        )
            )
        }
    }
}
