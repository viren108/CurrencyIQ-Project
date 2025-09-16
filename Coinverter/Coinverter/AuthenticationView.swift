//
//  AuthenticationView.swift
//  Coinverter
//
//  Created by Home User on 9/7/25.
//

import SwiftUI

struct AuthenticationView: View {
    @State private var showSignUpView: Bool = false

    var body: some View {
        if showSignUpView {
            SignupView(showSignUpView: $showSignUpView)
        } else {
            LoginView(showSignUpView: $showSignUpView)
        }
    }
}
