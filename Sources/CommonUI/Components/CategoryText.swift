import Models
import SwiftUI

public struct CategoryText: View {
    public let noteCategory: String
    public let noteColor: Color
    
    public init(
        noteCategory: String,
        noteColor: Color
    ) {
        self.noteCategory = noteCategory
        self.noteColor = noteColor
    }
    
    public var body: some View {
        Text(noteCategory)
            .textStyler(color: .white,
                        font: .caption,
                        weight: .black)
            .border(noteColor,
                    backgroundColor: noteColor,
                    radius: 30,
                    verticalPadding: 6,
                    horizontalPadding: 20)

    }
}

#Preview {
    CategoryText(noteCategory: "식품",
                 noteColor: .mainDarkBlue)
}
