import SwiftUI

public struct CustomTextEditor: View {
    let placeholder: String
    let backgroundColor: Color
    @Binding var text: String
    let textLimit: Int?
    
    public init(
        placeholder: String,
        text: Binding<String>,
        backgroundColor: Color = .gray5,
        textLimit: Int? = nil
    ) {
        self.placeholder = placeholder
        self._text = text
        self.backgroundColor = backgroundColor
        self.textLimit = textLimit
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
            .overlay(alignment: .bottomTrailing) {
                if let textLimit {
                    Text("\(text.count) / \(textLimit)")
                        .textStyler(color: .gray1,
                                    font: .caption)
                        .padding([.bottom, .trailing], 12)
                }
            }
    }
}

#Preview {
    VStack {
        CustomTextEditor(placeholder: "단어를 입력해주세요",
                         text: .constant(""))
        CustomTextEditor(placeholder: "단어를 입력해주세요",
                         text: .constant("단어입력중~~~"),
                         textLimit: 100)
    }
    .padding(.horizontal, 16)
}
