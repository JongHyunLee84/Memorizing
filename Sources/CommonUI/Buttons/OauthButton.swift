import SwiftUI

public struct OauthButton: View {
    let image: Image
    let title: String
    let textColor: Color
    let backgroundColor: Color
    let action: () -> Void
    
    public init(
        image: Image,
        title: String,
        textColor: Color,
        backgroundColor: Color,
        action: @escaping () -> Void
    ) {
        self.image = image
        self.title = title
        self.textColor = textColor
        self.backgroundColor = backgroundColor
        self.action = action
    }
    
    public var body: some View {
        Button(
            action: {
                action()
            }, label: {
                HStack {
                    image
                        .resizable()
                        .frame(width: 13, height: 15)
                        .padding(.leading, 100)
                    Text(title)
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(textColor)
                    Spacer()
                }
                .frame(width: 300, height: 35)
                .background(backgroundColor)
                .clipShape(.rect(cornerRadius: 20))
            }
        )
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    VStack {
        OauthButton(
            image: .appleIcon,
            title: "Apple로 로그인",
            textColor: .white,
            backgroundColor: .mainBlack) {
                
            }
        OauthButton(
            image: .kakaoIcon,
            title: "*******로 로그인",
            textColor: .mainBlack,
            backgroundColor: .kakaoBackground) {
                
            }
    }
    .padding(.horizontal, 50)
}
