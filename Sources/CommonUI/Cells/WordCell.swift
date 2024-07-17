import Models
import SwiftUI

public struct WordCell: View {
    let wordString: String
    let wordMeaning: String
    
    public init(
        wordString: String,
        wordMeaning: String
    ) {
        self.wordString = wordString
        self.wordMeaning = wordMeaning
    }
    
    public var body: some View {
        HStack(alignment: .top) {
            Group {
                Text(wordString)
                Text("|")
                Text(wordMeaning)
            }
            .textStyler(font: .callout, weight: .semibold)
            .frame(maxWidth: .infinity)
        }
    }
}

#Preview {
    ScrollView {
        LazyVStack {
            WordCell(wordString: "Apple",
                     wordMeaning: "사과")
        }
    }
}
