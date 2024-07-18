import Foundation

public var dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"  // 또는 원하는 형식으로 지정
    return formatter
}()
