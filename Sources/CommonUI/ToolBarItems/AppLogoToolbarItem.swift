import SwiftUI

public struct AppLogoToolbarItem: ToolbarContent {
    let placement: ToolbarItemPlacement
    let action: () -> Void
    
    public init(
        placement: ToolbarItemPlacement,
        action: @escaping () -> Void = {}
    ) {
        self.placement = placement
        self.action = action
    }
    
    public var body: some ToolbarContent {
        ToolbarItem(placement: placement) {
            Image.mainLogo
                .resizable()
                .frame(width: 34, height: 22)
                .onTapGesture {
                    action()
                }
        }
    }
}
