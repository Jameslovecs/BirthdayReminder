//
//  NotificationManager.swift
//  BirthdayReminder
//
//  Created by Ranran Cao on 1/17/26.
//

import Foundation
import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()
    
    private let testNotificationIdentifier = "birthdayReminderTest"
    
    private init() {}
    
    func requestAuthorizationIfNeeded() async {
        let center = UNUserNotificationCenter.current()
        let granted = try? await center.requestAuthorization(options: [.alert, .sound, .badge])
        if granted == true {
            print("Notification authorization granted")
        } else {
            print("Notification authorization denied")
        }
    }
    
    func scheduleAll(for people: [Person]) {
        clearAllScheduled()
        
        // For now, schedule only a TEST notification 10 seconds later
        scheduleTestNotification()
    }
    
    func scheduleTestNotification() {
        let center = UNUserNotificationCenter.current()
        
        // Clear previous test notification to avoid duplicates
        center.removePendingNotificationRequests(withIdentifiers: [testNotificationIdentifier])
        
        let content = UNMutableNotificationContent()
        content.title = "BirthdayReminder Test"
        content.body = "If you see this, notifications work."
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)
        let request = UNNotificationRequest(
            identifier: testNotificationIdentifier,
            content: content,
            trigger: trigger
        )
        
        center.add(request) { error in
            if let error = error {
                print("Error scheduling test notification: \(error.localizedDescription)")
            } else {
                print("Test notification scheduled for 10 seconds from now")
            }
        }
    }
    
    func clearAllScheduled() {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [testNotificationIdentifier])
        center.removeAllPendingNotificationRequests()
    }
}
