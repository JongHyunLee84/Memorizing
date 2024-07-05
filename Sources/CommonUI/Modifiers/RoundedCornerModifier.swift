import SwiftUI

struct RoundedCornerModifier: ViewModifier {
    var radius: CGFloat
    var corners: UIRectCorner
    
    func body(content: Content) -> some View {
        content
            .clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect,
                                byRoundingCorners: corners,
                                cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

extension View {
    public func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        modifier(RoundedCornerModifier(radius: radius, corners: corners))
    }
}

#Preview {
    VStack {
        Rectangle()
            .cornerRadius(10, corners: [.topLeft, .bottomLeft])
            .frame(width: 100, height: 100)
    }
}
