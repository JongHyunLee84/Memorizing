import SwiftUI

public struct CustomTextEditor: View {
    let placeholder: String
    let backgroundColor: Color
    @Binding var text: String
    
    public init(
        placeholder: String,
        text: Binding<String>,
        backgroundColor: Color = .gray5
    ) {
        self.placeholder = placeholder
        self._text = text
        self.backgroundColor = backgroundColor
    }
    public var body: some View {
        TextEditor(text: $text)
            .padding([.leading, .top], 5)
            .overlay(alignment: .topLeading) {
                if text.isEmpty {
                    Text(placeholder)
                        .textStyler(color: .gray2, font: .caption)
                        .padding(.leading, 10)
                        .padding(.top, 15)
                        .allowsHitTesting(false) // 해당 텍스트가 탭 되어도 TextEditor가 탭 되게
                }
            }
            .textStyler(color: .mainBlack, font: .caption)
            .scrollContentBackground(.hidden)
            .background(backgroundColor.cornerRadius(20))
    }
}

#Preview {
    VStack {
        CustomTextEditor(placeholder: "단어를 입력해주세요",
                         text: .constant(""))
    }
    .padding(.horizontal, 16)
}
