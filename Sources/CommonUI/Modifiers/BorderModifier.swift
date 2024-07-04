import SwiftUI

public struct BorderModifier: ViewModifier {
    let borderColor: Color
    let radius: CGFloat
    
    public init(
        borderColor: Color = .black,
        radius: CGFloat = 10
    ) {
        self.borderColor = borderColor
        self.radius = radius
    }
    
    public func body(content: Content) -> some View {
        content
            .overlay(
                RoundedRectangle(cornerRadius: radius)
                    .strokeBorder(borderColor, lineWidth: 1)
            )
    }
}

extension View {
    public func border(_ color: Color = .black, radius: CGFloat = 10) -> some View {
        modifier(BorderModifier(borderColor: color, radius: radius))
    }
}

#Preview {
    Text("하하하")
        .border()
}
