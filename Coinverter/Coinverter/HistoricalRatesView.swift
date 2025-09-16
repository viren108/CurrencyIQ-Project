import SwiftUI
import Charts

// Data model remains the same as before
struct ForecastDataPoint: Codable, Identifiable {
    let ds: String
    let yhat: Double
    let yhatLower: Double
    let yhatUpper: Double
    let type: String
    var id: String { ds }
    var date: Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: ds) ?? Date()
    }
}

// Enum for time range selection
enum TimeRange: String, CaseIterable, Identifiable {
    case sixMonth = "6M"
    case oneYear = "1Y"
    case fiveYear = "5Y"
    case max = "Max"
    var id: String { self.rawValue }
    
    // Corresponding query parameter value for the API
    var queryValue: String {
        switch self {
        case .sixMonth: return "6m"
        case .oneYear: return "1y"
        case .fiveYear: return "5y"
        case .max: return "max"
        }
    }
}

struct HistoricalRatesView: View {
    // --- State Variables ---
    @State private var targetCurrency: String = "EUR"
    @State private var chartData: [ForecastDataPoint] = []
    @State private var errorMessage: String = ""
    @State private var isLoading: Bool = false
    @State private var supportedCurrencies: [String] = ["EUR", "JPY", "GBP", "CAD", "AUD", "CHF"]
    @State private var selectedTimeRange: TimeRange = .oneYear // <-- New state variable for range

    var body: some View {
        NavigationStack {
            VStack(spacing: 15) {
                // --- Currency Selection ---
                HStack {
                    Text("Select Currency:")
                    Picker("Target Currency", selection: $targetCurrency) {
                        ForEach(supportedCurrencies, id: \.self) { Text($0) }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                }
                .padding(.horizontal)

                // --- NEW: Time Range Selector ---
                Picker("Time Range", selection: $selectedTimeRange) {
                    ForEach(TimeRange.allCases) { range in
                        Text(range.rawValue).tag(range)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .onChange(of: selectedTimeRange) { _ in fetchChartData() } // Re-fetch when range changes

                // --- Chart Display Area ---
                ZStack {
                    if isLoading { ProgressView() }
                    // ... (Chart rendering code remains the same as previous response) ...
                    else if !chartData.isEmpty {
                        Chart(chartData) { dataPoint in
                            let forecastStyle = StrokeStyle(lineWidth: 2, dash: [5, 5])
                            let historyStyle = StrokeStyle(lineWidth: 2)
                            if dataPoint.type == "forecast" {
                                AreaMark(x: .value("Date", dataPoint.date), yStart: .value("Lower", dataPoint.yhatLower), yEnd: .value("Upper", dataPoint.yhatUpper))
                                    .foregroundStyle(Color.blue.opacity(0.2))
                            }
                            LineMark(x: .value("Date", dataPoint.date), y: .value("Rate", dataPoint.yhat))
                                .foregroundStyle(Color.blue)
                                .lineStyle(dataPoint.type == "forecast" ? forecastStyle : historyStyle)
                        }
                        .padding()
                    } else if !errorMessage.isEmpty { Text(errorMessage).foregroundColor(.red) }
                    else { Text("Select currency to see historical trends and future predictions.").padding() }
                }
                .frame(minHeight: 300)
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal)
                
                Spacer() // Pushes content up
            }
            .navigationTitle("Currency Forecast")
            .onAppear { fetchChartData() } // Fetch data on initial view load
        }
    }

    // --- Network Function (UPDATED) ---
    // In HistoricalRatesView.swift

    func fetchChartData() {
        isLoading = true
        errorMessage = ""
        chartData = []

        // --- URL Setup ---
        var components = URLComponents()
        components.scheme = "https"
        components.host = "currencyiq-backend.onrender.com" // Your Render URL
        components.path = "/predict"
        components.queryItems = [
            URLQueryItem(name: "base", value: "USD"),
            URLQueryItem(name: "target", value: targetCurrency),
            URLQueryItem(name: "range", value: selectedTimeRange.queryValue)
        ]

        guard let url = components.url else {
            errorMessage = "Invalid URL created"
            isLoading = false
            return
        }
        
        print("DEBUG: Attempting to fetch data from URL: \(url)")

        // --- Network Request with Detailed Logging ---
        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false

                // 1. Check for explicit network errors (like connection failure)
                if let error = error {
                    print("DEBUG: Network request failed with error: \(error.localizedDescription)")
                    errorMessage = "Network request failed: \(error.localizedDescription)"
                    return
                }

                // 2. Check for empty data payload
                guard let data = data else {
                    print("DEBUG: Network request succeeded but returned no data.")
                    errorMessage = "No data received from server."
                    return
                }
                
                // 3. Attempt to decode the data
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let responseData = try decoder.decode([ForecastDataPoint].self, from: data)
                    self.chartData = responseData
                    print("DEBUG: Successfully decoded \(responseData.count) data points.")
                } catch {
                    print("DEBUG: JSON Decoding Failed!")
                    print("DEBUG: Error details: \(error)")
                    if let responseString = String(data: data, encoding: .utf8) {
                        print("DEBUG: Raw Server Response Text: \(responseString)")
                    } else {
                        print("DEBUG: Raw Server Response: Data could not be converted to string.")
                    }
                    errorMessage = "Failed to decode response. See console for details."
                }
            }
        }.resume()
    }
}
