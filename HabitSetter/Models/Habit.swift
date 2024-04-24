//
//  Habit.swift
//  HabitSetter
//
//  Created by Mattias Axelsson on 2024-04-24.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

// Definierar kategorierna som en enum för bättre typsäkerhet.
enum HabitCategory: String, Codable {
    case work = "Work"
    case personal = "Personal"
}

// Definierar intervallet för utförande som en enum.
enum HabitInterval: Int, Codable {
    case daily = 1
    case weekly = 7
}

struct Habit: Codable {
    @DocumentID var id: String?
    var name: String = ""
    var description : String = ""
    var category: HabitCategory  // Ändrat till en enum
    var interval: HabitInterval  // Ändrat till en enum
    var lastPerformed: Date?
    var imageLink: String?
    var currentStreakID: String?

    var dateCreated: Timestamp = Timestamp(date: Date())  // Standardvärde till nuvarande tid
    var dateEdited: Timestamp = Timestamp(date: Date())    // Standardvärde till nuvarande tid
    
    // En extra initialisator om du behöver konvertera från Firestore-dokument.
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        category = try container.decode(HabitCategory.self, forKey: .category)
        interval = try container.decode(HabitInterval.self, forKey: .interval)
        lastPerformed = try container.decodeIfPresent(Date.self, forKey: .lastPerformed)
        imageLink = try container.decodeIfPresent(String.self, forKey: .imageLink)
        currentStreakID = try container.decodeIfPresent(String.self, forKey: .currentStreakID)
        dateCreated = try container.decode(Timestamp.self, forKey: .dateCreated)
        dateEdited = try container.decode(Timestamp.self, forKey: .dateEdited)
    }
}

