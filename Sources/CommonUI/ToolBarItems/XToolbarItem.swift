import SwiftUI

public struct XToolbarItem: ToolbarContent {
    let placement: ToolbarItemPlacement
    let font: Font
    let color: Color
    let action: () -> Void
    
    public init(
        placement: ToolbarItemPlacement = .topBarTrailing,
        font: Font = .headline,
        color: Color = .mainBlack,
        action: @escaping () -> Void
    ) {
        self.placement = placement
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
                    Image(systemName: "xmark")
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
                XToolbarItem {}
            }
    }
}
