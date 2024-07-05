import SwiftUI

struct TextStylerModifier: ViewModifier {
    
    let font: Font
    let color: Color
    let weight: Font.Weight
    
    init(
        color: Color = .mainBlack,
        font: Font = .title3,
        weight: Font.Weight = .regular
    ) {
        self.color = color
        self.font = font
        self.weight = weight
    }
    
    func body(content: Content) -> some View {
        content
            .font(font)
            .fontWeight(weight)
            .textColor(color)
    }
}

extension View {
    public func textStyler(
        color: Color = .mainBlack,
        font: Font = .title3,
        weight: Font.Weight = .regular
    ) -> some View {
        modifier(TextStylerModifier(color: color, font: font, weight: weight))
    }
}
