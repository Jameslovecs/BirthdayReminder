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
    private let identifierPrefix = "br_"
    
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
        let center = UNUserNotificationCenter.current()
        
        // Clear existing notifications with br_ prefix
        center.getPendingNotificationRequests { requests in
            let identifiersToRemove = requests
                .filter { $0.identifier.hasPrefix(self.identifierPrefix) }
                .map { $0.identifier }
            
            if !identifiersToRemove.isEmpty {
                center.removePendingNotificationRequests(withIdentifiers: identifiersToRemove)
            }
            
            // Schedule new notifications for enabled people
            let enabledPeople = people.filter { $0.isEnabled }
            let now = Date()
            let calendar = Calendar.current
            let oneYearFromNow = calendar.date(byAdding: .year, value: 1, to: now) ?? now
            
            for person in enabledPeople {
                let nextBirthday = person.nextBirthdayDate(from: now)
                let ageTurning = person.ageTurning(on: nextBirthday)
                let personIdString = person.id.uuidString
                
                // Schedule normal birthday reminders (30 days and 2 days before)
                self.scheduleBirthdayReminder(
                    for: person,
                    nextBirthday: nextBirthday,
                    daysBefore: 30,
                    personId: personIdString,
                    now: now,
                    oneYearFromNow: oneYearFromNow
                )
                
                self.scheduleBirthdayReminder(
                    for: person,
                    nextBirthday: nextBirthday,
                    daysBefore: 2,
                    personId: personIdString,
                    now: now,
                    oneYearFromNow: oneYearFromNow
                )
                
                // Schedule gift reminders for kid milestones
                if person.isKidMilestone(ageTurning: ageTurning) {
                    self.scheduleGiftReminder(
                        for: person,
                        nextBirthday: nextBirthday,
                        daysBefore: 30,
                        ageTurning: ageTurning,
                        personId: personIdString,
                        now: now,
                        oneYearFromNow: oneYearFromNow
                    )
                    
                    self.scheduleGiftReminder(
                        for: person,
                        nextBirthday: nextBirthday,
                        daysBefore: 2,
                        ageTurning: ageTurning,
                        personId: personIdString,
                        now: now,
                        oneYearFromNow: oneYearFromNow
                    )
                }
                
                // Schedule milestone reminders for elder decade milestones
                if person.isElderDecadeMilestone(ageTurning: ageTurning) {
                    self.scheduleMilestoneReminder(
                        for: person,
                        nextBirthday: nextBirthday,
                        daysBefore: 30,
                        ageTurning: ageTurning,
                        personId: personIdString,
                        now: now,
                        oneYearFromNow: oneYearFromNow
                    )
                    
                    self.scheduleMilestoneReminder(
                        for: person,
                        nextBirthday: nextBirthday,
                        daysBefore: 2,
                        ageTurning: ageTurning,
                        personId: personIdString,
                        now: now,
                        oneYearFromNow: oneYearFromNow
                    )
                }
            }
        }
    }
    
    private func scheduleBirthdayReminder(
        for person: Person,
        nextBirthday: Date,
        daysBefore: Int,
        personId: String,
        now: Date,
        oneYearFromNow: Date
    ) {
        let calendar = Calendar.current
        guard let reminderDate = calendar.date(byAdding: .day, value: -daysBefore, to: nextBirthday) else {
            return
        }
        
        // Skip if in the past or beyond one year
        if reminderDate < now || reminderDate > oneYearFromNow {
            return
        }
        
        let identifier = "\(identifierPrefix)\(personId)_bday_\(daysBefore)"
        let content = UNMutableNotificationContent()
        content.title = "\(person.name)'s Birthday in \(daysBefore) day\(daysBefore == 1 ? "" : "s")"
        content.body = "\(person.name) will be turning \(person.ageTurning(on: nextBirthday)) on \(formatDate(nextBirthday))"
        content.sound = .default
        
        let trigger = createDateTrigger(for: reminderDate)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling birthday reminder: \(error.localizedDescription)")
            }
        }
    }
    
    private func scheduleGiftReminder(
        for person: Person,
        nextBirthday: Date,
        daysBefore: Int,
        ageTurning: Int,
        personId: String,
        now: Date,
        oneYearFromNow: Date
    ) {
        let calendar = Calendar.current
        guard let reminderDate = calendar.date(byAdding: .day, value: -daysBefore, to: nextBirthday) else {
            return
        }
        
        if reminderDate < now || reminderDate > oneYearFromNow {
            return
        }
        
        let identifier = "\(identifierPrefix)\(personId)_gift_\(daysBefore)"
        let content = UNMutableNotificationContent()
        content.title = "Gift Reminder: \(person.name)'s \(ageTurning)th Birthday"
        content.body = "\(person.name) is turning \(ageTurning)! Gift ideas: \(giftIdeas(for: ageTurning, gender: person.gender))"
        content.sound = .default
        
        let trigger = createDateTrigger(for: reminderDate)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling gift reminder: \(error.localizedDescription)")
            }
        }
    }
    
    private func scheduleMilestoneReminder(
        for person: Person,
        nextBirthday: Date,
        daysBefore: Int,
        ageTurning: Int,
        personId: String,
        now: Date,
        oneYearFromNow: Date
    ) {
        let calendar = Calendar.current
        guard let reminderDate = calendar.date(byAdding: .day, value: -daysBefore, to: nextBirthday) else {
            return
        }
        
        if reminderDate < now || reminderDate > oneYearFromNow {
            return
        }
        
        let identifier = "\(identifierPrefix)\(personId)_milestone_\(daysBefore)"
        let content = UNMutableNotificationContent()
        content.title = "Important Milestone: \(person.name)'s \(ageTurning)th Birthday"
        content.body = "\(person.name) is turning \(ageTurning)! This is a special decade milestone."
        content.sound = .default
        
        let trigger = createDateTrigger(for: reminderDate)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling milestone reminder: \(error.localizedDescription)")
            }
        }
    }
    
    private func createDateTrigger(for date: Date) -> UNCalendarNotificationTrigger? {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        
        // Set time to 9:00 AM
        var triggerComponents = DateComponents()
        triggerComponents.year = components.year
        triggerComponents.month = components.month
        triggerComponents.day = components.day
        triggerComponents.hour = 9
        triggerComponents.minute = 0
        
        return UNCalendarNotificationTrigger(dateMatching: triggerComponents, repeats: false)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    private func giftIdeas(for age: Int, gender: String) -> String {
        switch age {
        case 3:
            return gender == "Girl" ? "Building blocks, dolls, or art supplies" : "Building blocks, toy cars, or art supplies"
        case 5:
            return gender == "Girl" ? "Puzzles, books, or dress-up items" : "Puzzles, books, or action figures"
        case 10:
            return gender == "Girl" ? "Craft kits, books, or sports gear" : "Building sets, books, or sports gear"
        default:
            return "Consider their interests and hobbies"
        }
    }
    
    func scheduleTestNotification() {
        let center = UNUserNotificationCenter.current()
        
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
        center.getPendingNotificationRequests { requests in
            let identifiersToRemove = requests
                .filter { $0.identifier.hasPrefix(self.identifierPrefix) }
                .map { $0.identifier }
            center.removePendingNotificationRequests(withIdentifiers: identifiersToRemove)
        }
        center.removePendingNotificationRequests(withIdentifiers: [testNotificationIdentifier])
    }
}
