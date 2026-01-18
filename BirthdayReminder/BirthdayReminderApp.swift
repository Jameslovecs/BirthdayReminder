//
//  BirthdayReminderApp.swift
//  BirthdayReminder
//
//  Created by Ranran Cao on 1/17/26.
//

import SwiftUI
import SwiftData

@main
struct BirthdayReminderApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Person.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .task {
                    await NotificationManager.shared.requestAuthorizationIfNeeded()
                }
        }
        .modelContainer(sharedModelContainer)
    }
}
