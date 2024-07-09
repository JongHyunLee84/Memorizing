import Foundation

extension Array {
    public subscript(safe index: Int) -> Element? {
        get {
            return indices.contains(index) ? self[index] : nil
        }
        set(newValue) {
            if let newValue, indices.contains(index) {
                self[index] = newValue
            }
        }
    }
}
