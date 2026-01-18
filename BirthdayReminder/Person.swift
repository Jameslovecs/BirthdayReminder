//
//  Person.swift
//  BirthdayReminder
//
//  Created by Ranran Cao on 1/17/26.
//

import Foundation
import SwiftData

@Model
final class Person {
    var id: UUID
    var name: String
    var birthday: Date
    var relation: String
    var isEnabled: Bool
    var gender: String
    
    init(id: UUID = UUID(), name: String, birthday: Date, relation: String = "", isEnabled: Bool = true, gender: String = "Any") {
        self.id = id
        self.name = name
        self.birthday = birthday
        self.relation = relation
        self.isEnabled = isEnabled
        self.gender = gender
    }
    
    // Computed helpers (non-persisted)
    func nextBirthdayDate(from date: Date = .now) -> Date {
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: date)
        let birthdayComponents = calendar.dateComponents([.month, .day], from: birthday)
        
        var nextBirthdayComponents = DateComponents()
        nextBirthdayComponents.year = currentYear
        nextBirthdayComponents.month = birthdayComponents.month
        nextBirthdayComponents.day = birthdayComponents.day
        
        guard var nextBirthday = calendar.date(from: nextBirthdayComponents) else {
            return date
        }
        
        // If the birthday has already passed this year, move to next year
        if nextBirthday < date {
            nextBirthdayComponents.year = currentYear + 1
            nextBirthday = calendar.date(from: nextBirthdayComponents) ?? date
        }
        
        return nextBirthday
    }
    
    func ageTurning(on nextBirthday: Date) -> Int {
        let calendar = Calendar.current
        let birthYear = calendar.component(.year, from: birthday)
        let nextBirthdayYear = calendar.component(.year, from: nextBirthday)
        return nextBirthdayYear - birthYear
    }
    
    func isKidMilestone(ageTurning: Int) -> Bool {
        return ageTurning < 12 && [3, 5, 10].contains(ageTurning)
    }
    
    func isElderDecadeMilestone(ageTurning: Int) -> Bool {
        return ageTurning >= 45 && ageTurning % 10 == 0
    }
}
