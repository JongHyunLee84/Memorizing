import SwiftUI
import Extensions

struct SwiftUIView: View {
    var body: some View {
        ZStack {
            Color.kakaoBackground
            Image.appleIcon
        }
        
    }
}

#Preview {
    SwiftUIView()
}
