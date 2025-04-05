//
//  ContentView.swift
//  PushNotificationstestProject
//
//  Created by Michael Novosad on 05.04.2025.
//

import SwiftUI

struct ContentView: View {

    var body: some View {
        VStack(spacing: 20) {
            Text("Local Notification Demo")
                .font(.title)

            Button("Schedule Notification Now") {
                // Get current date/time for unique content example
                let now = Date()
                let formatter = DateFormatter()
                formatter.timeStyle = .medium

                // Call the shared manager instance to schedule
                NotificationManager.shared.scheduleNotification(
                    title: "Event Happened!",
                    body: "Something important occurred at \(formatter.string(from: now)).",
                    timeInterval: 5 // Deliver after 5 seconds
                )
            }
            .padding()
            .buttonStyle(.borderedProminent)

            Button("Cancel All Pending") {
                NotificationManager.shared.cancelAllPendingNotifications()
            }
            .padding()
            .buttonStyle(.bordered)
            .tint(.red)

             Button("Reset Badge Count") {
                NotificationManager.shared.resetBadgeCount()
            }
            .padding()
            .buttonStyle(.bordered)
            .tint(.orange)
        }
        .padding()
        .onAppear {
            // --- IMPORTANT ---
            // Request authorization when the view appears (or earlier in app lifecycle)
            // You only need to *call* requestAuthorization once, ideally at app launch.
            // Subsequent calls won't re-prompt if the user already responded,
            // but it's good practice to check status if needed elsewhere.
             NotificationManager.shared.checkAuthorizationStatus { status in
                 if status == .notDetermined {
                    // Only request if status is undetermined
                     NotificationManager.shared.requestAuthorization { granted, error in
                         if granted {
                             print("Permission granted on view appear.")
                         } else {
                              print("Permission denied on view appear.")
                         }
                     }
                 } else if status == .denied {
                    print("Permission was previously denied. Consider guiding user to settings.")
                 } else {
                    print("Permission already granted.")
                 }
             }

            // Reset badge on app launch/foregrounding if desired
             NotificationManager.shared.resetBadgeCount()
        }
    }
}

// Preview Provider
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
