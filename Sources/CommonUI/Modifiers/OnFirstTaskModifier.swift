import ComposableArchitecture
import SwiftUI

@MainActor
struct OnFirstTaskModifier: ViewModifier {
    @State private var isFirstTask: Bool = true
    let action: () -> StoreTask
    
    init(action: @escaping () -> StoreTask) {
        self.action = action
    }
    
    func body(content: Content) -> some View {
        content
            .task {
                guard isFirstTask else { return }
                isFirstTask = false
                await action().finish()
            }
    }
}

extension View {
    @MainActor 
    public func onFirstTask(_ action: @escaping () -> StoreTask) -> some View {
        modifier(OnFirstTaskModifier(action: action))
    }
}
