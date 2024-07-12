import SwiftUI

struct BorderModifier: ViewModifier {
    let borderColor: Color
    let radius: CGFloat
    let verticalPadding: CGFloat
    let horizontalPadding: CGFloat
    
    init(
        borderColor: Color = .black,
        radius: CGFloat = 10,
        verticalPadding: CGFloat = 0,
        horizontalPadding: CGFloat = 0
    ) {
        self.borderColor = borderColor
        self.radius = radius
        self.verticalPadding = verticalPadding
        self.horizontalPadding = horizontalPadding
    }
    
    func body(content: Content) -> some View {
        content
            .padding(.vertical, verticalPadding)
            .padding(.horizontal, horizontalPadding)
            .cornerRadius(radius)
            .overlay(
                RoundedRectangle(cornerRadius: radius)
                    .strokeBorder(borderColor, lineWidth: 1)
            )
    }
}

extension View {
    public func border(
        _ color: Color = .black,
        radius: CGFloat = 10,
        verticalPadding: CGFloat = 0,
        horizontalPadding: CGFloat = 0
    ) -> some View {
        modifier(
            BorderModifier(
                borderColor: color,
                radius: radius,
                verticalPadding: verticalPadding,
                horizontalPadding: horizontalPadding
            )
        )
    }
}

#Preview {
    Text("하하하")
        .border(.gray,
                radius: 20,
                verticalPadding: 8,
                horizontalPadding: 12)
}
