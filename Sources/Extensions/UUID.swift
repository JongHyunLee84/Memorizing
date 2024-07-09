import Dependencies
import Foundation

extension UUID {
    public static var zero: Self {
        .init(uuidString: "00000000-0000-0000-0000-000000000000")!
    }
}
