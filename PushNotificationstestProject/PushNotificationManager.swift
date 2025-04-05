//
//  PushNotificationManager.swift
//  PushNotificationstestProject
//
//  Created by Michael Novosad on 05.04.2025.
//

import UserNotifications
import UIKit // Import UIKit to access UIApplication for badge count

class NotificationManager {

    // Shared instance for easy access (Singleton pattern)
    static let shared = NotificationManager()

    private init() {} // Private initializer to enforce singleton usage

    let notificationCenter = UNUserNotificationCenter.current()

    // MARK: - Authorization

    /// Requests authorization from the user to send notifications.
    /// Best practice: Call this early in your app's lifecycle or before the first notification attempt.
    func requestAuthorization(completion: @escaping (Bool, Error?) -> Void) {
        let options: UNAuthorizationOptions = [.alert, .sound, .badge] // Customize options as needed
        notificationCenter.requestAuthorization(options: options) { granted, error in
            if let error = error {
                print("Error requesting notification authorization: \(error.localizedDescription)")
            } else if granted {
                print("Notification permission granted.")
                // Optional: You might want to register for remote notifications here if needed later
                // DispatchQueue.main.async {
                //     UIApplication.shared.registerForRemoteNotifications()
                // }
            } else {
                print("Notification permission denied.")
                // Optional: Guide user to settings if they denied previously
            }
            // Call the completion handler on the main thread
            DispatchQueue.main.async {
                completion(granted, error)
            }
        }
    }

    /// Checks the current notification authorization status.
    func checkAuthorizationStatus(completion: @escaping (UNAuthorizationStatus) -> Void) {
        notificationCenter.getNotificationSettings { settings in
            DispatchQueue.main.async {
                completion(settings.authorizationStatus)
            }
        }
    }

    // MARK: - Scheduling Local Notifications

    /// Schedules a basic local notification immediately or after a short delay.
    /// - Parameters:
    ///   - title: The title of the notification.
    ///   - body: The main text content of the notification.
    ///   - timeInterval: Delay in seconds before the notification is delivered. Defaults to 1 second for immediate effect.
    ///   - identifier: A unique identifier for this notification. Defaults to a new UUID.
    func scheduleNotification(title: String, body: String, timeInterval: TimeInterval = 1, identifier: String = UUID().uuidString) {

        // 1. Check authorization status first
        checkAuthorizationStatus { [weak self] status in
            guard let self = self else { return }

            guard status == .authorized else {
                print("Cannot schedule notification: Not authorized.")
                // Optionally: Request authorization again or guide user to settings
                // self.requestAuthorization { _, _ in } // Be careful not to annoy the user
                return
            }

            // 2. Create Notification Content
            let content = UNMutableNotificationContent()
            content.title = title
            content.body = body
            content.sound = UNNotificationSound.default // Use default sound
            UNUserNotificationCenter.current().setBadgeCount(1) // Increment badge number
            // You can add userInfo dictionary for custom data:
            // content.userInfo = ["customDataKey": "your_value"]

            // 3. Create Trigger
            // For a button press, a short time interval trigger demonstrates it immediately.
            // Set repeats to false for a one-time notification.
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: max(timeInterval, 1), repeats: false) // Ensure minimum 1 second

            // 4. Create Request
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

            // 5. Schedule the Request
            self.notificationCenter.add(request) { error in
                if let error = error {
                    print("Error scheduling notification \(identifier): \(error.localizedDescription)")
                } else {
                    print("Notification scheduled successfully (ID: \(identifier)) with title: \(title)")
                }
            }
        }
    }

    // MARK: - Optional: Managing Notifications

    /// Cancels a specific pending notification.
    func cancelPendingNotification(identifier: String) {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [identifier])
        print("Cancelled pending notification with ID: \(identifier)")
    }

    /// Cancels all pending notifications.
    func cancelAllPendingNotifications() {
        notificationCenter.removeAllPendingNotificationRequests()
        print("Cancelled all pending notifications.")
    }

    /// Resets the application's badge count to 0.
    func resetBadgeCount() {
        DispatchQueue.main.async {
            UNUserNotificationCenter.current().setBadgeCount(0)
            // Also clear delivered notifications that contributed to the badge
            // notificationCenter.removeAllDeliveredNotifications() // Use if needed
        }
    }
}
