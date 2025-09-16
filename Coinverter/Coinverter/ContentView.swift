//
//  ContentView.swift
//  Coinverter
//
//  Created by home user17 on 12/8/24.
//
import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore

struct ContentView: View {
    @State private var isUserLoggedIn: Bool = false
    @EnvironmentObject var authService: AuthenticationService
    
    var body: some View {
        NavigationView {
            ZStack {
                
                Color.teal
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    Spacer(minLength: 60) // Add top spacing
                    
                    Text("Currency Converter")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.bottom, 30) // Increase bottom padding
                        .foregroundColor(.yellow)
                    
                    if isUserLoggedIn {
                        CurrencyConversionView()
                    } else {
                        AuthenticationView()
                    }
                    
                    Spacer(minLength: 40) // Add spacing before navigation buttons
                    
                    // Button to navigate to Historical Rates
                    NavigationLink(destination: HistoricalRatesView()) {
                        Text("View Historical Rates")
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.mint)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 12) // Add spacing between buttons
                    
                    //Button to navigate to Set Alerts
                    NavigationLink(destination: AlertsView()) {
                        Text("Set Price Alerts")
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.mint)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 12) // Add spacing between buttons
                    
                    // Button to navigate to Favorites
                    NavigationLink(destination: FavoritesView()) {
                        Text("View Favorites")
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.yellow)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    
                    Button(action: {
                            authService.signOut()
                        }) {
                            Text("Logout")
                                .font(.headline)
                                .foregroundColor(.red)
                        }
                    
                    .padding(.horizontal)
                    
                    Spacer(minLength: 60) // Add bottom spacing
                }
            }
            .navigationBarHidden(true)
        }
        .onAppear {
            checkUserLoginStatus()
        }
    }

    func checkUserLoginStatus() {
        if Auth.auth().currentUser != nil {
            isUserLoggedIn = true
        } else {
            isUserLoggedIn = false
        }
    }
}

struct CurrencyConversionView: View {
    @State private var amount: String = ""
    @State private var startCurrency: String = "USD"
    @State private var endCurrency: String = "EUR"
    @State private var convertedAmount: String = ""
    @State private var errorMessage: String = ""
    @State private var currencies: [String] = []
    @State private var favorites: [FavoriteCurrencyPair] = []

    var body: some View {
        VStack(spacing: 20) { // Add consistent spacing throughout
            TextField("Enter amount", text: $amount)
                .keyboardType(.decimalPad)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())

            VStack(spacing: 20) {
                Picker("From", selection: $startCurrency) {
                    ForEach(currencies, id: \.self) { currency in
                        Text(currency).tag(currency)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .padding()
                .background(Color.white)
                .cornerRadius(8)

                Button(action: {
                    toggleFavorite(base: startCurrency, target: endCurrency)
                }) {
                    Image(systemName: isFavorite(base: startCurrency, target: endCurrency) ? "star.fill" : "star")
                        .foregroundColor(.yellow)
                }

                Picker("To", selection: $endCurrency) {
                    ForEach(currencies, id: \.self) { currency in
                        Text(currency).tag(currency)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .padding()
                .background(Color.white)
                .cornerRadius(8)
            }

            Button("Convert") {
                convertCurrency()
            }
            .font(.headline)
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            .padding(.top, 10)

            Text("Converted Amount: \(convertedAmount)")
                .fontWeight(.bold)
                .padding(.top, 10)
                .foregroundColor(.yellow)
            
            if !errorMessage.isEmpty {
                Text("Error: \(errorMessage)")
                    .foregroundColor(.red)
                    .padding(.top, 5)
            }
        }
        .padding(.horizontal, 20) // Add horizontal padding
        .onAppear {
            fetchCurrencies()
            fetchFavorites()
        }
    }

    func fetchCurrencies() {
        let urlString = "https://api.exchangerate-api.com/v4/latest/USD"
        guard let url = URL(string: urlString) else {
            errorMessage = "Invalid URL."
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    errorMessage = "Error fetching currencies: \(error.localizedDescription)"
                }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async {
                    errorMessage = "No data received."
                }
                return
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let rates = json["rates"] as? [String: Double] {
                    DispatchQueue.main.async {
                        currencies = Array(rates.keys).sorted()
                    }
                } else {
                    DispatchQueue.main.async {
                        errorMessage = "Invalid response format."
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    errorMessage = "Error parsing data: \(error.localizedDescription)"
                }
            }
        }
        task.resume()
    }

    func convertCurrency() {
        guard let amountValue = Double(amount) else {
            errorMessage = "Please enter a valid amount."
            return
        }
        
        let urlString = "https://api.exchangerate-api.com/v4/latest/\(startCurrency)"
        guard let url = URL(string: urlString) else {
            errorMessage = "Invalid URL."
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    errorMessage = "Error fetching data: \(error.localizedDescription)"
                }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async {
                    errorMessage = "No data received."
                }
                return
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let rates = json["rates"] as? [String: Double],
                   let rate = rates[endCurrency] {
                    let convertedValue = amountValue * rate
                    DispatchQueue.main.async {
                        convertedAmount = String(format: "%.2f", convertedValue)
                        errorMessage = ""
                    }
                } else {
                    DispatchQueue.main.async {
                        errorMessage = "Invalid response format."
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    errorMessage = "Error parsing data: \(error.localizedDescription)"
                }
            }
        }
        task.resume()
    }

    func toggleFavorite(base: String, target: String) {
        if let index = favorites.firstIndex(where: { $0.baseCurrency == base && $0.targetCurrency == target }) {
            favorites.remove(at: index)
            removeFavoriteFromFirestore(base: base, target: target)
        } else {
            let favorite = FavoriteCurrencyPair(baseCurrency: base, targetCurrency: target)
            favorites.append(favorite)
            addFavoriteToFirestore(favorite: favorite)
        }
    }

    func isFavorite(base: String, target: String) -> Bool {
        return favorites.contains(where: { $0.baseCurrency == base && $0.targetCurrency == target })
    }

    func addFavoriteToFirestore(favorite: FavoriteCurrencyPair) {
        let db = Firestore.firestore()
        db.collection("favorites").addDocument(data: [
            "baseCurrency": favorite.baseCurrency,
            "targetCurrency": favorite.targetCurrency
        ])
    }

    func removeFavoriteFromFirestore(base: String, target: String) {
        let db = Firestore.firestore()
        // Implement logic to remove the favorite from Firestore
    }

    func fetchFavorites() {
        let db = Firestore.firestore()
        db.collection("favorites").getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error fetching favorites: \(error)")
                return
            }
            favorites = querySnapshot?.documents.compactMap { document in
                let data = document.data()
                let baseCurrency = data["baseCurrency"] as? String ?? ""
                let targetCurrency = data["targetCurrency"] as? String ?? ""
                return FavoriteCurrencyPair(baseCurrency: baseCurrency, targetCurrency: targetCurrency)
            } ?? []
        }
    }
}

#Preview {
    ContentView()
}
