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
enum HabitCategory: String, Codable, CaseIterable {
 
    
    case work = "Work"
    case personal = "Personal"
}

// Definierar intervallet för utförande som en enum.
enum HabitInterval: Int, Codable, CaseIterable {
    case daily = 1
    case weekly = 7
}

struct Habit: Codable, Identifiable {
    
    @DocumentID var id: String?
    var name: String = ""
    var description : String = ""
    var category: HabitCategory  // enum
    var interval: HabitInterval  // enum
    var lastPerformed: Date?
    var imageLink: String?
    var currentStreakID: String?
    var userId: String?
    var performed: Bool = false
    var sendNotification: Bool = true

    var dateCreated: Timestamp = Timestamp(date: Date())  // standard value current time
    var dateEdited: Timestamp = Timestamp(date: Date())    // standard value current time
    
    
    //Normal constructor
    init(id: String? = nil,
             name: String,
             description: String,
             category: HabitCategory,
             interval: HabitInterval,
             lastPerformed: Date? = nil,
             imageLink: String? = nil,
             currentStreakID: String? = nil,
             userId: String? = nil,
             performed: Bool = false,
             sendNotification: Bool,
             dateCreated: Timestamp,
             dateEdited: Timestamp) {
            self.id = id
            self.name = name
            self.description = description
            self.category = category
            self.interval = interval
            self.lastPerformed = lastPerformed
            self.imageLink = imageLink
            self.currentStreakID = currentStreakID
            self.userId = userId
            self.performed = performed
            self.sendNotification = sendNotification
            self.dateCreated = dateCreated
            self.dateEdited = dateEdited
        }
    
    // En extra initialisator to convert from Firestore.
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        category = try container.decode(HabitCategory.self, forKey: .category)
        interval = try container.decode(HabitInterval.self, forKey: .interval)
        lastPerformed = try container.decodeIfPresent(Date.self, forKey: .lastPerformed)
        imageLink = try container.decodeIfPresent(String.self, forKey: .imageLink)
        currentStreakID = try container.decodeIfPresent(String.self, forKey: .currentStreakID)
        userId = try container.decodeIfPresent(String.self, forKey: .userId)
        performed = try container.decode(Bool.self, forKey: .performed)
        sendNotification = try container.decode(Bool.self, forKey: .sendNotification)
        dateCreated = try container.decode(Timestamp.self, forKey: .dateCreated)
        dateEdited = try container.decode(Timestamp.self, forKey: .dateEdited)
    }
}

