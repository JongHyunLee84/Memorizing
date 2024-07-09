import SwiftUI

public struct BackButtonToolbarItem: ToolbarContent {
    let placement: ToolbarItemPlacement
    let color: Color
    let action: () -> Void
    
    public init(
        placement: ToolbarItemPlacement = .topBarLeading,
        color: Color = .mainBlack,
        action: @escaping () -> Void
    ) {
        self.placement = placement
        self.color = color
        self.action = action
    }
    
    public var body: some ToolbarContent {
        ToolbarItem(placement: placement) {
            Button(
                action: {
                    action()
                }, label: {
                    Image(systemName: "chevron.left")
                        .textStyler(color: color,
                                    font: .headline)
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
                BackButtonToolbarItem() {}
            }
    }
}
