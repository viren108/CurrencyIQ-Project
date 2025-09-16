//
//  AlertsView.swift
//  Coinverter
//
//  Created by Home User on 9/15/25.
//
import SwiftUI
import Firebase
import FirebaseAuth

struct AlertsView: View {
    @State private var targetCurrency: String = "EUR"
    @State private var targetPrice: String = ""
    @State private var condition: AlertCondition = .above
    @State private var supportedCurrencies: [String] = ["EUR", "JPY", "GBP", "CAD", "AUD", "CHF"]
    @State private var message: String = ""
    
    enum AlertCondition: String, CaseIterable, Identifiable {
        case above = "Rises Above"
        case below = "Drops Below"
        var id: String { self.rawValue }
    }
    
    var body: some View {
        Form {
            Section(header: Text("Create a New Alert")) {
                Picker("Currency", selection: $targetCurrency) {
                    ForEach(supportedCurrencies, id: \.self) { Text($0) }
                }
                
                Picker("Condition", selection: $condition) {
                    ForEach(AlertCondition.allCases) { c in
                        Text(c.rawValue).tag(c)
                    }
                }
                
                TextField("Target Price", text: $targetPrice)
                    .keyboardType(.decimalPad)
            }
            
            Section {
                Button("Set Alert") {
                    saveAlertToFirestore()
                }
            }
            
            if !message.isEmpty {
                Text(message)
            }
        }
        .navigationTitle("Price Alerts")
    }
    
    func saveAlertToFirestore() {
        guard let userID = Auth.auth().currentUser?.uid,
              let price = Double(targetPrice) else {
            self.message = "Invalid price or not logged in."
            return
        }
        
        let alert: [String: Any] = [
            "userID": userID,
            "targetCurrency": targetCurrency,
            "condition": condition.rawValue == "Rises Above" ? "above" : "below",
            "targetPrice": price,
            "baseCurrency": "USD",
            "createdAt": Timestamp(date: Date())
        ]
        
        let db = Firestore.firestore()
        db.collection("alerts").addDocument(data: alert) { error in
            if let error = error {
                self.message = "Error saving alert: \(error.localizedDescription)"
            } else {
                self.message = "Alert successfully created!"
            }
        }
    }
}
