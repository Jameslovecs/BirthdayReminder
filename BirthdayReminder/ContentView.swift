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
    
    private var sortedPeople: [Person] {
        people
            .filter { $0.isEnabled }
            .sorted { person1, person2 in
                person1.nextBirthdayDate() < person2.nextBirthdayDate()
            }
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(sortedPeople) { person in
                    PersonRow(person: person)
                }
                .onDelete(perform: deletePeople)
            }
            .navigationTitle("Birthday Reminder")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddPerson = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddPerson) {
                PersonEditView(person: nil)
            }
        }
    }
    
    private func deletePeople(offsets: IndexSet) {
        withAnimation {
            let peopleToDelete = offsets.map { sortedPeople[$0] }
            for person in peopleToDelete {
                modelContext.delete(person)
            }
        }
    }
}

struct PersonRow: View {
    let person: Person
    
    var body: some View {
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
                Text(person.nextBirthdayDate(), format: .dateTime.month().day())
                    .font(.subheadline)
                let age = person.ageTurning(on: person.nextBirthdayDate())
                Text("turning \(age)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Person.self, inMemory: true)
}
