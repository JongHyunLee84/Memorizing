import Models
import SwiftUI

public struct ReviewStars: View {
    public let reviewScore: Double
    public let font: Font
    
    public init(
        reviewScore: Double,
        font: Font
    ) {
        self.reviewScore = reviewScore
        self.font = font
    }
    public var body: some View {
        HStack(spacing: 0) {
            ForEach(1...5, id: \.self) { idx in
                let intValue = Int(reviewScore)
                if idx <= intValue {
                    Image(systemName: "star.fill")
                        .textStyler(color: .yellow,
                                    font: font)
                } else {
                    Image(systemName: "star")
                        .textStyler(color: .yellow,
                                    font: font)
                }
            }
            Spacer()
        }
    }
}

#Preview {
    VStack {
        ReviewStars(reviewScore: 5, font: .footnote)
        ReviewStars(reviewScore: 4, font: .footnote)
        ReviewStars(reviewScore: 3, font: .footnote)
        ReviewStars(reviewScore: 2, font: .footnote)
        ReviewStars(reviewScore: 1, font: .footnote)
    }
    .padding(.leading)
}
