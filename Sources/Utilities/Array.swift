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
    
    public func tryMap<T>(_ transform: (Element) throws -> T) throws -> [T] {
        var result: [T] = []
        for element in self {
            result.append(try transform(element))
        }
        return result
    }
}
