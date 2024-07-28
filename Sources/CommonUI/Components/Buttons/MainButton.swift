import SwiftUI

public struct MainButton: View {
    
    let title: String
    let textColor: Color
    let backgroundColor: Color
    let borderColor: Color
    let font: Font
    let weight: Font.Weight
    let radius: CGFloat
    let height: CGFloat
    let isAvailable: Bool
    let action: () -> Void
    
    public init(
        title: String,
        textColor: Color = .white,
        backgroundColor: Color = .mainBlue,
        borderColor: Color = .mainBlue,
        font: Font = .caption2,
        weight: Font.Weight = .semibold,
        radius: CGFloat = 10,
        height: CGFloat = 40,
        isAvailable: Bool = true,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.textColor = textColor
        self.backgroundColor = backgroundColor
        self.borderColor = borderColor
        self.font = font
        self.weight = weight
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
                                font: font,
                                weight: weight)
                    .frame(height: height)
                    .frame(maxWidth: .infinity)
                    .background(backgroundColor)
                    .cornerRadius(radius)
                    .border(
                        backgroundColor == .white || backgroundColor == .clear
                        ? borderColor
                        : .clear
                        
                    )
            }
        )
        .buttonStyle(PlainButtonStyle())
        .disabled(!isAvailable)
    }
}

#Preview {
    VStack {
        MainButton(title: "확인",
                   isAvailable: true) {}
            .frame(width: 200)
        MainButton(title: "확인",
                   isAvailable: false) {}
            .frame(width: 200)
        MainButton(title: "확인",
                   isAvailable: false) {}
            .frame(width: 200)
    }

}
