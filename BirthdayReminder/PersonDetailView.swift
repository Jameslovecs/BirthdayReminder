//
//  PersonDetailView.swift
//  BirthdayReminder
//
//  Created by Ranran Cao on 1/17/26.
//

import SwiftUI

struct PersonDetailView: View {
    let person: Person
    
    var body: some View {
        let nextBirthday = person.nextBirthdayDate()
        let ageTurning = person.ageTurning(on: nextBirthday)
        let isKidMilestone = person.isKidMilestone(ageTurning: ageTurning)
        let isElderMilestone = person.isElderDecadeMilestone(ageTurning: ageTurning)
        
        Form {
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text(person.name)
                        .font(.title2)
                        .fontWeight(.bold)
                    if !person.relation.isEmpty {
                        Text(person.relation)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Section("Birthday Information") {
                HStack {
                    Text("Birthday")
                    Spacer()
                    Text(formatBirthday(person.birthday))
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("Next Birthday")
                    Spacer()
                    Text(formatDate(nextBirthday))
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("Turning Age")
                    Spacer()
                    Text("\(ageTurning)")
                        .foregroundColor(.secondary)
                        .fontWeight(.medium)
                }
            }
            
            if isKidMilestone {
                Section("Gift Ideas") {
                    let ideas = giftIdeas(ageTurning: ageTurning, gender: person.gender)
                    ForEach(ideas, id: \.self) { idea in
                        Text(idea)
                    }
                }
            }
            
            if isElderMilestone {
                Section("Important Milestone") {
                    Text("This is a special decade milestone birthday!")
                        .foregroundColor(.secondary)
                }
            }
        }
        .navigationTitle("Person Details")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func formatBirthday(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy"
        return formatter.string(from: date)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

func giftIdeas(ageTurning: Int, gender: String) -> [String] {
    switch ageTurning {
    case 3:
        if gender == "Girl" {
            return ["Building blocks", "Dolls and accessories", "Art supplies", "Play kitchen toys", "Picture books"]
        } else if gender == "Boy" {
            return ["Building blocks", "Toy cars and vehicles", "Art supplies", "Construction toys", "Picture books"]
        } else {
            return ["Building blocks", "Art supplies", "Picture books", "Stacking toys", "Musical instruments"]
        }
    case 5:
        if gender == "Girl" {
            return ["Puzzles (50-100 pieces)", "Chapter books", "Dress-up costumes", "Craft kits", "Board games"]
        } else if gender == "Boy" {
            return ["Puzzles (50-100 pieces)", "Chapter books", "Action figures", "Construction sets", "Board games"]
        } else {
            return ["Puzzles (50-100 pieces)", "Chapter books", "Board games", "Craft kits", "Building sets"]
        }
    case 10:
        if gender == "Girl" {
            return ["Advanced craft kits", "Young adult books", "Sports equipment", "STEM kits", "Art supplies"]
        } else if gender == "Boy" {
            return ["Building sets (Lego/others)", "Young adult books", "Sports equipment", "STEM kits", "Video games (age-appropriate)"]
        } else {
            return ["STEM kits", "Young adult books", "Sports equipment", "Board games", "Art or craft kits"]
        }
    default:
        return []
    }
}

#Preview {
    NavigationStack {
        PersonDetailView(person: Person(
            name: "Sample Person",
            birthday: Date(),
            relation: "Friend",
            isEnabled: true,
            gender: "Any"
        ))
    }
}
