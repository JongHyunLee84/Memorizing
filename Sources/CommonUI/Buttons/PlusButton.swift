import SwiftUI

public struct PlusButton: View {
    let action: () -> Void
    
    public init(action: @escaping () -> Void) {
        self.action = action
    }
    
    public var body: some View {
        Button(
            action: {
                action()
            }, label: {
                Image(systemName: "plus")
                    .resizable()
                    .foregroundStyle(.white)
                    .frame(width: 24, height: 24)
                    .frame(width: 64, height: 64)
                    .background(Color.mainBlue)
                    .clipShape(Circle())
            }
        )
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    ScrollView {
        ForEach(0...5, id: \.self) { _ in
            Rectangle()
                .frame(height: 100)
        }
    }
    .overlay(alignment: .bottomTrailing) {
        PlusButton {}
            .padding(.bottom, 60)
    }
    .padding(.horizontal, 16)
}
