//
//  PersonEditView.swift
//  BirthdayReminder
//
//  Created by Ranran Cao on 1/17/26.
//

import SwiftUI
import SwiftData

struct PersonEditView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var name: String = ""
    @State private var relation: String = ""
    @State private var birthday: Date = Date()
    @State private var gender: String = "Any"
    @State private var isEnabled: Bool = true
    
    let person: Person?
    
    private let genderOptions = ["Any", "Boy", "Girl"]
    
    init(person: Person?) {
        self.person = person
        if let person = person {
            _name = State(initialValue: person.name)
            _relation = State(initialValue: person.relation)
            _birthday = State(initialValue: person.birthday)
            _gender = State(initialValue: person.gender)
            _isEnabled = State(initialValue: person.isEnabled)
        }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Name", text: $name)
                TextField("Relation", text: $relation)
                DatePicker("Birthday", selection: $birthday, displayedComponents: .date)
                Picker("Gender", selection: $gender) {
                    ForEach(genderOptions, id: \.self) { option in
                        Text(option).tag(option)
                    }
                }
                Toggle("Enabled", isOn: $isEnabled)
            }
            .navigationTitle(person == nil ? "Add Person" : "Edit Person")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        save()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
    
    private func save() {
        if let person = person {
            person.name = name
            person.relation = relation
            person.birthday = birthday
            person.gender = gender
            person.isEnabled = isEnabled
        } else {
            let newPerson = Person(
                name: name,
                birthday: birthday,
                relation: relation,
                isEnabled: isEnabled,
                gender: gender
            )
            modelContext.insert(newPerson)
        }
        dismiss()
    }
}

#Preview {
    PersonEditView(person: nil)
        .modelContainer(for: Person.self, inMemory: true)
}
