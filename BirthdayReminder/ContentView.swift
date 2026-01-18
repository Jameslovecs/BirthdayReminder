//
//  ContentView.swift
//  BirthdayReminder
//
//  Created by Ranran Cao on 1/17/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var people: [Person]
    @State private var showingAddPerson = false
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some View {
        let enabledPeople = people.filter { $0.isEnabled }
        let sortedPeople = enabledPeople.sorted { person1, person2 in
            person1.nextBirthdayDate() < person2.nextBirthdayDate()
        }
        let previewLines = debugPreviewLines(from: sortedPeople)
        
        return NavigationStack {
            List {
                #if DEBUG
                DebugSectionView(
                    enabledCount: enabledPeople.count,
                    previewLines: previewLines,
                    onReschedule: {
                        NotificationManager.shared.scheduleAll(for: people)
                    }
                )
                #endif
                
                ForEach(sortedPeople) { person in
                    NavigationLink(destination: PersonDetailView(person: person)) {
                        PersonRowView(person: person)
                    }
                }
                .onDelete { offsets in
                    deletePeople(offsets: offsets, sortedPeople: sortedPeople)
                }
            }
            .navigationTitle("Birthday Reminder")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Test Notification") {
                        NotificationManager.shared.scheduleTestNotification()
                    }
                    .font(.caption)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddPerson = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddPerson, onDismiss: {
                NotificationManager.shared.scheduleAll(for: people)
            }) {
                PersonEditView(person: nil, onSave: {
                    Task { @MainActor in
                        try? await Task.sleep(nanoseconds: 100_000_000)
                        NotificationManager.shared.scheduleAll(for: people)
                    }
                })
            }
            .task {
                NotificationManager.shared.scheduleAll(for: people)
            }
            .onChange(of: scenePhase) { oldPhase, newPhase in
                if newPhase == .active {
                    NotificationManager.shared.scheduleAll(for: people)
                }
            }
            .onChange(of: people.map { $0.id }) { _, _ in
                NotificationManager.shared.scheduleAll(for: people)
            }
        }
    }
    
    private func deletePeople(offsets: IndexSet, sortedPeople: [Person]) {
        withAnimation {
            let peopleToDelete = offsets.map { sortedPeople[$0] }
            for person in peopleToDelete {
                modelContext.delete(person)
            }
            NotificationManager.shared.scheduleAll(for: people)
        }
    }
    
    private func birthdayDisplay(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
    
    private func debugPreviewLines(from people: [Person]) -> [String] {
        Array(people.prefix(3)).map { person in
            let dateStr = birthdayDisplay(person.nextBirthdayDate())
            return "\(person.name): \(dateStr)"
        }
    }
}

#if DEBUG
struct DebugSectionView: View {
    let enabledCount: Int
    let previewLines: [String]
    let onReschedule: () -> Void
    
    var body: some View {
        Section("Debug") {
            Text("Enabled people: \(enabledCount)")
            Button("Reschedule Notifications Now") {
                onReschedule()
            }
            if !previewLines.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Next birthdays:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    ForEach(previewLines, id: \.self) { line in
                        Text(line)
                            .font(.caption2)
                    }
                }
            }
        }
    }
}
#endif

struct PersonRowView: View {
    let person: Person
    
    var body: some View {
        let nextBirthday = person.nextBirthdayDate()
        let age = person.ageTurning(on: nextBirthday)
        let birthdayText = monthDayDisplay(nextBirthday)
        
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(person.name)
                    .font(.headline)
                if !person.relation.isEmpty {
                    Text(person.relation)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 4) {
                Text(birthdayText)
                    .font(.subheadline)
                Text("turning \(age)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private func monthDayDisplay(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: date)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Person.self, inMemory: true)
}
