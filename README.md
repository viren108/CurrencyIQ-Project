# CurrencyIQ 💱

> A comprehensive iOS currency conversion app with intelligent forecasting and personalized user experience.

## ✨ Features

**🔒 Secure Authentication**
- User registration and login system
- Secure user data management with Firebase Authentication

**💰 Smart Currency Conversion**
- Real-time exchange rates for multiple currencies
- Intuitive conversion interface
- Support for popular global currencies

**⭐ Personalized Experience**
- Save favorite currency pairs for quick access
- Customizable user preferences
- Personalized dashboard

**📊 Historical Data & Visualization**
- Interactive Swift charts showing exchange rate trends
- Historical exchange rate data analysis
- Visual representation of currency performance over time

**🔮 AI-Powered Forecasting**
- Flask backend integration with Prophet forecasting model
- Predictive analytics for currency trends
- Data-driven insights for better decision making

**🔔 Real-Time Notifications**
- Firebase-powered alert system
- Personalized notifications for rate changes
- Stay updated on your favorite currencies

## 🛠️ Tech Stack

| Frontend | Backend | Database | ML/Analytics |
|----------|---------|----------|--------------|
| Swift | Flask | Firebase Firestore | Facebook Prophet |
| SwiftUI | Python | Firebase Auth | Real-time Analytics |
| Swift Charts | Cloud Messaging | Predictive Modeling |


## Project Structure

```
CurrencyIQ-Project/
├── Coinverter/                 # iOS Swift application
├── CurrencyIQ-Backend/         # Flask backend with Prophet forecasting
└── CurrencyIQ-Functions/       # Firebase Cloud Functions
```

## 📱 Screenshots

*Screenshots coming soon - app currently in development*

## 🚀 Quick Start

### Prerequisites
- Xcode 14.0+
- iOS 15.0+
- Python 3.8+
- Node.js 16+

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/viren108/CurrencyIQ-Project.git
   cd CurrencyIQ-Project
   ```

2. **Firebase Setup**
   ```bash
   # Create Firebase project at https://console.firebase.google.com/
   # Enable Authentication, Firestore, and Cloud Messaging
   # Download GoogleService-Info.plist to Coinverter/ directory
   ```

3. **Run iOS App**
   ```bash
   cd Coinverter
   open Coinverter.xcodeproj
   # Build and run in Xcode
   ```

4. **Start Backend Server**
   ```bash
   cd CurrencyIQ-Backend
   pip install -r requirements.txt
   python app.py
   ```

5. **Deploy Cloud Functions**
   ```bash
   cd CurrencyIQ-Functions
   npm install -g firebase-tools
   firebase login
   firebase deploy --only functions
   ```

## 📋 Roadmap

- [x] Core currency conversion functionality
- [x] Firebase authentication integration
- [x] Real-time exchange rate data
- [x] Interactive Swift Charts
- [x] Prophet ML forecasting model
- [x] Push notification system


## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the project
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
