import SwiftUI

struct BorderModifier: ViewModifier {
    let borderColor: Color
    let radius: CGFloat
    
    init(
        borderColor: Color = .black,
        radius: CGFloat = 10
    ) {
        self.borderColor = borderColor
        self.radius = radius
    }
    
    func body(content: Content) -> some View {
        content
            .overlay(
                RoundedRectangle(cornerRadius: radius)
                    .strokeBorder(borderColor, lineWidth: 1)
            )
    }
}

extension View {
    public func border(_ color: Color = .black, _ radius: CGFloat = 10) -> some View {
        modifier(BorderModifier(borderColor: color, radius: radius))
    }
}

#Preview {
    Text("하하하")
        .border()
}
