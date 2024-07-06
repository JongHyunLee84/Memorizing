import SwiftUI

struct EmptyListModifier<T>: ViewModifier {
    let list: [T]
    let message: String
    let maxHeight: CGFloat
    
    init(
        list: [T],
        message: String,
        maxHeight: CGFloat = 200
    ) {
        self.list = list
        self.message = message
        self.maxHeight = maxHeight
    }
    
    func body(content: Content) -> some View {
        if list.isEmpty {
            HStack {
                Spacer()
                VStack(spacing: 16) {
                    Spacer()
                    Image(systemName: "tray")
                        .font(.title2)
                    Text(message)
                    Spacer()
                }
                Spacer()
            }
            .textStyler(color: .gray4,
                        font: .callout)
            .frame(maxHeight: maxHeight)
        } else {
            content
        }
    }
}

extension View {
    public func emptyList<T>(
        list: [T],
        title: String,
        maxHeight: CGFloat = 200
    ) -> some View {
        self.modifier(
            EmptyListModifier(
                list: list,
                message: title,
                maxHeight: maxHeight
            )
        )
    }
}

#Preview {
    VStack {
        ForEach(0..<3, id: \.self) { _ in
            
        }
        .emptyList(list: [], title: "등록된 단어가 없어요.")
    }
}
