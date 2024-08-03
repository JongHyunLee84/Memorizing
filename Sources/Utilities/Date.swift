import Foundation

extension FormatStyle where Self == Date.FormatStyle {
    public static var yearMonthDay: Date.FormatStyle {
        Date.FormatStyle()
            .year(.defaultDigits)
            .month(.twoDigits)
            .day(.twoDigits)
    }
}

extension Date {
    public static var random: Date {
        let randomTime = TimeInterval(Int32.random(in: 0...Int32.max))
        return Date(timeIntervalSince1970: randomTime)
    }
}
