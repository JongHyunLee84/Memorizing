import SwiftUI

public struct CustomDivider: View {
    let color: Color
    let height: CGFloat
    
    public init(
        color: Color = .gray5,
        height: CGFloat = 1
    ) {
        self.color = color
        self.height = height
    }
    
    public var body: some View {
        Divider()
            .overlay {
                color
                    .frame(height: height)
            }
            .frame(height: height)
    }
}

#Preview {
    CustomDivider(height: 8)
}
