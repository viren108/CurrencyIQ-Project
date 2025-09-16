import SwiftUI

struct SplashScreen: View {
    @State private var isActive: Bool = false

    var body: some View {
        if isActive {
            // Navigate to the main content (e.g., LoginView)
            AuthenticationView() // Replace with your main view
        } else {
            VStack {
                Text("Coinverter") // Replace with your app's name or logo
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding()
                
                
                // Optionally, add an image
                Image("CoinverterLogo") // Replace with your logo image name
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200) // Adjust size as needed
                    .padding()
              
                
                Text("Created By: Vikram Renganathan")
                Text("Z23683042")
                
                Spacer()
                
                Text("Attribution:  https://www.exchangerate-api.com - Rates By Exchange Rate API")
            }
            .onAppear {
                // Delay for 2 seconds before navigating
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation {
                        isActive = true
                    }
                }
            }
        }
    }
}

#Preview {
    SplashScreen()
}
