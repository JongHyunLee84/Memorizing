import Models
import SwiftUI

extension NoteCategory {
    public var noteColor: Color {
        switch self {
        case .english: .english
        case .history: .history
        case .it: .it
        case .economy: .economy
        case .knowledge: .knowledge
        case .etc: .etc
        }
    }
}

extension Note {
    public var noteColor: Color {
        category.noteColor
    }
}

extension MarketNote {
    public var noteColor: Color {
        category.noteColor
    }
}
