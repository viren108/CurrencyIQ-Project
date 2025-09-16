// Coinverter/FavoriteCurrencyPair.swift

import Foundation

struct FavoriteCurrencyPair: Identifiable {
    var id = UUID()
    var baseCurrency: String
    var targetCurrency: String
}
