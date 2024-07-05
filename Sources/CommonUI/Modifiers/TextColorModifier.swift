import SwiftUI

struct TextColorModifier: ViewModifier {
    let color: Color
    
    init(_ color: Color) {
        self.color = color
    }
    
    func body(content: Content) -> some View {
        content
            .foregroundStyle(color)
    }
}

extension View {
    public func textColor(_ color: Color) -> some View {
        modifier(TextColorModifier(color))
    }
}
