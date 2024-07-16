import SwiftUI

struct ProgressModifier: ViewModifier {
    let isProgressing: Bool
    
    func body(content: Content) -> some View {
        content
            .overlay(isProgressing ? ProgressView() : nil)
    }
}

extension View {
    public func isProgressing(_ isProgressing: Bool) -> some View {
        modifier(ProgressModifier(isProgressing: isProgressing))
    }
}
