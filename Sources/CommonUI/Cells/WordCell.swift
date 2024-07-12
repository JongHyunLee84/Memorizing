import Models
import SwiftUI

public struct WordCell: View {
    let wordList: WordList
    let height: CGFloat
    let onDelete: (IndexSet) -> Void
    
    public init(
        wordList: WordList,
        height: CGFloat = 200,
        onDelete: @escaping (IndexSet) -> Void
    ) {
        self.wordList = wordList
        self.height = height
        self.onDelete = onDelete
    }
    
    public var body: some View {
        List {
            ForEach(wordList) {
                word in
                HStack(alignment: .top) {
                    Group {
                        Text(word.wordString)
                        Text("|")
                        Text(word.wordMeaning)
                    }
                    .textStyler(font: .callout, weight: .semibold)
                    .frame(maxWidth: .infinity)
                }
                .listRowSeparator(.hidden)
            }
            .onDelete { indexSet in
                onDelete(indexSet)
            }
        }
        .frame(height: height)
        .emptyList(list: wordList, title: "등록된 단어가 없어요.")
        .listStyle(.plain)
    }
}

#Preview {
    ScrollView {
        LazyVStack {
            WordCell(wordList: .mock) { _ in }
        }
    }
}

#Preview("NO List") {
    WordCell(wordList: []) { _ in }
}
