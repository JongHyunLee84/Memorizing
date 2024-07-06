import SwiftUI

public struct TextToolbarItem: ToolbarContent {
    let placement: ToolbarItemPlacement
    let text: String
    let font: Font
    let color: Color
    let action: () -> Void
    
    public init(
        placement: ToolbarItemPlacement = .topBarTrailing,
        text: String,
        font: Font = .headline,
        color: Color = .mainBlack,
        action: @escaping () -> Void
    ) {
        self.placement = placement
        self.text = text
        self.font = font
        self.color = color
        self.action = action
    }
    
    public var body: some ToolbarContent {
        ToolbarItem(placement: placement) {
            Button(
                action: {
                    action()
                }, label: {
                    Text(text)
                        .textStyler(color: color,
                                    font: font)
                }
            )
            .buttonStyle(PlainButtonStyle())
        }
    }
}

#Preview {
    NavigationStack {
        Color.clear
            .toolbar {
                TextToolbarItem(text: "저장하기") {}
            }
    }
}
