import SwiftUI

struct CornerRadiusModifier: ViewModifier {
    var radius: CGFloat
    
    init(radius: CGFloat = 10) {
        self.radius = radius
    }
    
    func body(content: Content) -> some View {
        content
            .clipShape(RoundedRectangle(cornerRadius: radius))
    }
}

extension View {
    public func cornerRadius(_ radius: CGFloat = 10) -> some View {
        modifier(CornerRadiusModifier(radius: radius))
    }
}

