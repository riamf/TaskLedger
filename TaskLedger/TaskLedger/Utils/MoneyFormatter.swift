import Foundation

final class MoneyFormatter {
    static let formatter = {
        let formatter = NumberFormatter()
        formatter.locale = Locale.current
        formatter.numberStyle = .currency
        return formatter
    }()
    
    static let localeCurrencyCode: String? = {
        Locale.current.currencyCode
    }()
}
