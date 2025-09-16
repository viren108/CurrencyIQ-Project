// Coinverter/LoginView.swift
//
//  LoginView.swift
//  Coinverter
//
//  Created by home user17 on 12/8/24.
//

import SwiftUI
import Firebase
import FirebaseAuth

struct LoginView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var errorMessage: String = ""
    @Binding var showSignUpView: Bool // Add binding to toggle views

    var body: some View {
        VStack {
            Text("Welcome Back!")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.bottom, 20)

            TextField("Email", text: $email)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .autocapitalization(.none)
                .padding(.bottom, 10)

            SecureField("Password", text: $password)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.bottom, 20)

            Button(action: login) {
                Text("Login")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.bottom, 10)

            if !errorMessage.isEmpty {
                Text("Error: \(errorMessage)")
                    .foregroundColor(.red)
                    .padding()
            }

            Button(action: {
                showSignUpView = true // Toggle state to show signup view
            }) {
                Text("Don't have an account? Sign up")
                    .foregroundColor(.blue)
            }
            .padding(.top, 10)
        }
        .padding()
    }

    func login() {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                errorMessage = error.localizedDescription
            }
        }
    }
}

// Update Preview to provide a sample binding
struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(showSignUpView: .constant(false))
    }
}
