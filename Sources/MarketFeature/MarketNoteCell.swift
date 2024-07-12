import CommonUI
import Models
import SwiftUI

public struct MarketNoteCell: View {
    let note: MarketNote
    public init(
        note: MarketNote
    ) {
        self.note = note
    }
    
    public var body: some View {
        HStack(spacing: 8) {
            Rectangle()
                .fill(note.category.noteColor)
                .frame(width: 12)
                .cornerRadius(12, corners: [.topLeft, .bottomLeft])
            VStack(alignment: .leading, spacing: 8) {
                Text(note.noteCategory)
                    .border(.gray4,
                            radius: 15,
                            verticalPadding: 4,
                            horizontalPadding: 12)
                    .textStyler(color: .gray3, font: .caption2)
                Text(note.noteName)
                    .lineLimit(2)
                    .frame(maxHeight: .infinity)
                    .textStyler(color: .mainBlack,
                                font: .footnote,
                                weight: .semibold)
                Text("\(note.notePrice)P")
                    .textStyler(color: .mainBlue,
                                font: .callout,
                                weight: .semibold)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 12)
        }
        .frame(height: 120)
        .border(.gray5, radius: 15)
        .contentShape(.rect)
    }
}

#Preview {
    MarketNoteCell(note: .mock)
        .padding(.horizontal, 16)
}
