//
//  AuthenticationService.swift
//  Coinverter
//
//  Created by Home User on 9/7/25.
//

import Foundation
import Firebase
import FirebaseAuth

class AuthenticationService: ObservableObject {
    // @Published notifies all views listening to this service when userSession changes.
    @Published var userSession: FirebaseAuth.User?
    private var authStateHandler: AuthStateDidChangeListenerHandle?

    init() {
        listenForAuthStateChanges()
    }

    func listenForAuthStateChanges() {
        // This listener fires whenever a user logs in or logs out.
        authStateHandler = Auth.auth().addStateDidChangeListener { [weak self] auth, user in
            // Update userSession on the main thread to trigger UI changes.
            DispatchQueue.main.async {
                self?.userSession = user
            }
        }
    }
    
    // Function to sign out
    func signOut() {
        do {
            try Auth.auth().signOut()
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
}
