// Coinverter/SignupView.swift
//
//  SignupView.swift
//  Coinverter
//
//  Created by home user17 on 12/8/24.
//

// SignUpView.swift

import SwiftUI
import Firebase
import FirebaseAuth

struct SignupView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var errorMessage: String = ""
    @Binding var showSignUpView: Bool // Add binding to toggle views

    var body: some View {
        VStack {
            Text("Create Account")
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

            Button(action: signup) {
                Text("Sign Up")
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
                showSignUpView = false // Toggle state back to show login view
            }) {
                Text("Already have an account? Login")
                    .foregroundColor(.blue)
            }
            .padding(.top, 10)
        }
        .padding()
    }

    func signup() {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                errorMessage = error.localizedDescription
            }
        }
    }
}

// Update Preview to provide a sample binding
struct SignupView_Previews: PreviewProvider {
    static var previews: some View {
        SignupView(showSignUpView: .constant(true))
    }
}
