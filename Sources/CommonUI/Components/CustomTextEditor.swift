import SwiftUI

public struct CustomTextEditor: View {
    let placeholder: String
    @Binding var text: String
    
    public init(
        placeholder: String,
        text: Binding<String>
    ) {
        self.placeholder = placeholder
        self._text = text
    }
    public var body: some View {
        TextEditor(text: $text)
            .overlay(alignment: .topLeading) {
                if text.isEmpty {
                    Text(placeholder)
                        .textStyler(color: .gray2, font: .caption)
                        .padding([.top, .leading], 15)
                        .allowsHitTesting(false) // 해당 텍스트가 탭 되어도 TextEditor가 탭 되게
                }
            }
            .textStyler(color: .mainBlack, font: .caption)
            .scrollContentBackground(.hidden)
            .background(Color.gray5.cornerRadius(20))
    }
}

#Preview {
    VStack {
        CustomTextEditor(placeholder: "단어를 입력해주세요",
                         text: .constant(""))
    }
    .padding(.horizontal, 16)
}
