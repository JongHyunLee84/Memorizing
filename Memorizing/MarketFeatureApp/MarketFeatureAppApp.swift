import ComposableArchitecture
import MarketFeature
import SwiftUI

@main
struct MarketFeatureAppApp: App {
    @Shared(.currentUser) var currentUser = .mock
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                MarketView(
                    store: .init(
                        initialState: .init(),
                        reducer: { MarketFeature()._printChanges() },
                        withDependencies: {
                            $0.marketClient = .testValue
                            $0.reviewClient = .testValue
                        }
                    )
                )
            }
        }
    }
}
