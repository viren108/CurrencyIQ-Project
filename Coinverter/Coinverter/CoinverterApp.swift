//
//  CoinverterApp.swift
//  Coinverter
//
//  Created by home user17 on 12/9/24.
//
import SwiftUI
import FirebaseCore
import FirebaseMessaging // <-- Import Firebase Messaging
import UserNotifications // <-- Import User Notifications
import FirebaseAuth
import FirebaseFirestore

// --- Firebase Initialization & Notification Delegate ---
class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        FirebaseApp.configure()
        
        // --- Notification Permission Request ---
        UNUserNotificationCenter.current().delegate = self
        
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { _, error in
            if let error = error {
                print("Error requesting authorization for notifications: \(error.localizedDescription)")
            }
        }
        
        application.registerForRemoteNotifications()
        
        // --- Set Messaging Delegate ---
        Messaging.messaging().delegate = self
        
        return true
    }
    
    // --- Get FCM Token ---
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let token = fcmToken else { return }
        print("Firebase registration token: \(token)")
        // Save the token to UserDefaults to be accessed later
        UserDefaults.standard.set(token, forKey: "fcmToken")
    }
}

// --- Main App Structure ---
@main
struct CoinverterApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var authService = AuthenticationService()

    var body: some Scene {
        WindowGroup {
            if authService.userSession != nil {
                ContentView()
                    .environmentObject(authService)
                    .onAppear(perform: saveFCMTokenToFirestore) // <-- Save token when user is logged in
            } else {
                AuthenticationView()
                    .environmentObject(authService)
            }
        }
    }
    
    // --- Save Token to Firestore ---
    private func saveFCMTokenToFirestore() {
        guard let fcmToken = UserDefaults.standard.string(forKey: "fcmToken"),
              let userID = Auth.auth().currentUser?.uid else {
            return
        }
        
        // Save the token to a 'users' collection for the current user
        let db = Firestore.firestore()
        db.collection("users").document(userID).setData(["fcmToken": fcmToken], merge: true) { error in
            if let error = error {
                print("Error saving FCM token to Firestore: \(error.localizedDescription)")
            } else {
                print("Successfully saved FCM token for user.")
            }
        }
    }
}
