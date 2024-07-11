import SwiftUI

struct OnFirstTaskModifier: ViewModifier {
    @State private var isFirstTask: Bool = true
    let action: @Sendable () async -> Void
    
    init(action: @escaping @Sendable () async -> Void) {
        self.action = action
    }
    
    func body(content: Content) -> some View {
        content
            .task {
                if isFirstTask {
                    await action()
                    isFirstTask = false
                }
            }
    }
}

extension View {
    public func onFirstTask(_ action: @escaping @Sendable () async -> Void) -> some View {
        modifier(OnFirstTaskModifier(action: action))
    }
}
