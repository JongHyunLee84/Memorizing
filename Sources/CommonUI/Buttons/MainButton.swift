import SwiftUI

public struct MainButton: View {
    
    let title: String
    let textColor: Color
    let backgroundColor: Color
    let radius: CGFloat
    let height: CGFloat?
    let isAvailable: Bool
    let action: () -> Void
    
    public init(
        title: String,
        textColor: Color = .white,
        backgroundColor: Color = .mainBlue,
        radius: CGFloat = 10,
        height: CGFloat? = nil,
        isAvailable: Bool = true,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.textColor = textColor
        self.backgroundColor = backgroundColor
        self.radius = radius
        self.height = height
        self.isAvailable = isAvailable
        self.action = action
    }

    public var body: some View {
        Button(
            action: {
                action()
            }, label: {
                Text(title)
                    .textStyler(color: textColor,
                                font: .caption2,
                                weight: .semibold)
                    .frame(height: height)
                    .frame(maxWidth: .infinity, maxHeight: 40)
                    .background(backgroundColor)
                    .cornerRadius(radius)
            }
        )
        .buttonStyle(PlainButtonStyle())
        .disabled(!isAvailable)
    }
}

#Preview {
    MainButton(title: "확인") {}
        .frame(width: 200)
}
