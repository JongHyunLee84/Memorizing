import SwiftUI

public struct TitleToolbarItem: ToolbarContent {
    let title: String
    
    public init(title: String) {
        self.title = title
    }
    
    public var body: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
        }
    }
}
