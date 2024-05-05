//
//  Streak.swift
//  HabitSetter
//
//  Created by Mattias Axelsson on 2024-05-02.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct Streak: Codable, Identifiable {
    
    @DocumentID var id: String?
    var userId: String
    var habitId: String?
    var habitColor: String?
    var firstDayOfStreak: Date
    var lastDayPerformed: Date
    var currentStreakCount: Int
    var interval: HabitInterval
    
}

