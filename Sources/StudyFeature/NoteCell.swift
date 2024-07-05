import CommonUI
import Models
import SwiftUI

public struct SwiftUIView: View {
    let note: Note
    
    public var body: some View {
        Rectangle()
            .fill(.white)
            .cornerRadius(12)
            .border(.gray5, 12)
            .frame(height: 120)
            .overlay {
                HStack {
                    note.category.noteColor
                        .frame(width: 10)
                        .cornerRadius(12, corners: [.topLeft, .bottomLeft])
                    
                    VStack(alignment: .leading) {
                        Text(note.noteCategory)
                            .font(.caption2)
                            .textColor(.gray3)
                            .padding(.all, 4)
                            .border(note.category.noteColor)
                        Spacer()
                        Text(note.noteName)
                            .font(.callout)
                        Spacer()
                        MainButton(title: "단어 등록하러 가기",
                                   backgroundColor: note.category.noteColor) {
                            
                        }
                    }
                    .padding(.vertical, 12)
                    
                    Spacer()
                }
            }
    }
}

#Preview {
    SwiftUIView(note: .mock)
        .padding(.horizontal, 16)
}
