import CommonUI
import SwiftUI

public struct MyNoteView: View {
    public var body: some View {
        ScrollView {
        }
        .toolbar {
            AppLogoToolbarItem(placement: .topBarLeading)
            TitleToolbarItem(title: "내 암기장")
            ToolbarItem(placement: .topBarTrailing) {
                Image(systemName: "list.bullet")
                    .foregroundStyle(Color.mainBlue)
                    .fontWeight(.black)
                    .onTapGesture {
                        // TODO: 노트 리스트 편집
                    }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        MyNoteView()
    }
}
