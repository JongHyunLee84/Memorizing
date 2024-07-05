import SwiftUI
import PopupView

struct ToastMessageModifier: ViewModifier {
    @Binding private var toastMessage: String?
    
    init(
        toastMessage: Binding<String?>
    ) {
        self._toastMessage = toastMessage
    }
    
    func body(content: Content) -> some View {
        content
            .popup(
                item: $toastMessage,
                itemView: { message in
                    ToastMessageView(message: message)
                },
                customize: {
                    $0
                        .type(.floater(verticalPadding: 30))
                        .position(.top)
                        .animation(.spring())
                        .autohideIn(2.5)
                        .closeOnTapOutside(true)
                    //                .isOpaque(true) // navigationBarTitleDisplayMode(.inline)으로 하면 토스트가 안 보임. navBar까지 무시해주는 설정 필요함.
                }
            )
    }
}

struct ToastMessageView: View {
    let message: String
    var body: some View {
        Text(message)
            .font(.subheadline)
            .foregroundStyle(.white)
            .padding(.vertical, 14)
            .padding(.horizontal, 16)
            .background {
                RoundedRectangle(cornerRadius: 40)
                    .fill(.black)
            }
    }
}

extension View {
    public func toastMessage(messsage: Binding<String?>) -> some View {
        self.modifier(ToastMessageModifier(toastMessage: messsage))
    }
}

struct TestView: View {
    @State private var message: String? = "로그인에 실패했어요."
    var body: some View {
        VStack {
            
        }
        .toastMessage(messsage: $message)
    }
}

#Preview {
    TestView()
}
