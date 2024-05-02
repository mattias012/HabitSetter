//
//  StreakViewModel.swift
//  HabitSetter
//
//  Created by Mattias Axelsson on 2024-05-02.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

class StreakViewModel : ObservableObject {
    
    private var db = Firestore.firestore()
    
    func addOrUpdateStreak(habit: Habit, performedDate: Date, isUndo: Bool = false) {
        guard let habitId = habit.id, let userId = habit.userId else { return }
        
        let streaksCollection = db.collection("streaks")
        
        //Search for habit streak
        streaksCollection.whereField("userId", isEqualTo: userId)
            .whereField("habitId", isEqualTo: habitId)
            .getDocuments { (snapshot, error) in
                if let error = error {
                    print("Error fetching streak: \(error.localizedDescription)")
                    return
                }
                
                if let documents = snapshot?.documents, let document = documents.first {
                    if isUndo {
                        //we need to handle the undo action..
                        self.handleUndoAction(for: document, with: performedDate)
                    } else {
                        //update or create a new streak
                        
                       
                        self.updateOrCreateStreak(document: document, habit: habit, performedDate: performedDate)
                    }
                } else if !isUndo {
                    
                    //Ok so it is not an undo action, lets create a streak
                    self.createStreak(for: habit, performedDate: performedDate)
                }
            }
    }

    private func updateOrCreateStreak(document: DocumentSnapshot, habit: Habit, performedDate: Date) {
        
        //Set the snapshot to a variabel
        var existingStreak = try? document.data(as: Streak.self)
        
        //Check if the habit's interval aligns with the streak
        let intervalMatches = habit.interval.days() == (existingStreak?.interval.days() ?? 0)
        
        // Check if the performed date falls within the streak's interval
        let performedDateWithinInterval = isPerformedDateWithinInterval(performedDate, lastPerformed: existingStreak?.lastDayPerformed ?? Date(), interval: habit.interval)
        
        // Update streak only if interval matches and performed date falls within interval
        if intervalMatches && performedDateWithinInterval {
            existingStreak?.lastDayPerformed = performedDate
            existingStreak?.currentStreakCount += 1
            
            if let streak = existingStreak {
                document.reference.updateData([
                    "lastDayPerformed": streak.lastDayPerformed,
                    "currentStreakCount": streak.currentStreakCount
                ])
            }
        }
    }

    //Make sure it is a streak
    private func isPerformedDateWithinInterval(_ performedDate: Date, lastPerformed: Date, interval: HabitInterval) -> Bool {
        let calendar = Calendar.current
        let lowerBound = calendar.date(byAdding: .day, value: -interval.days(), to: lastPerformed)!
        let upperBound = lastPerformed
        
        let result = performedDate >= lowerBound && performedDate <= upperBound
        
        return result
    }



    private func handleUndoAction(for document: DocumentSnapshot, with performedDate: Date) {
        if var streak = try? document.data(as: Streak.self), streak.lastDayPerformed == performedDate {
            //reduce by 1, if this is the first streak it wil be 0... hm..
            streak.currentStreakCount = max(streak.currentStreakCount - 1, 0)
            document.reference.updateData([
                "currentStreakCount": streak.currentStreakCount
            ])
        }
    }

    private func createStreak(for habit: Habit, performedDate: Date) {
        let newStreak = Streak(
            userId: habit.userId!,
            habitId: habit.id!,
            firstDayOfStreak: performedDate,
            lastDayPerformed: performedDate,
            currentStreakCount: 1,
            interval: habit.interval
        )
        
        let streaksCollection = db.collection("streaks")
        
        do {
            try streaksCollection.addDocument(from: newStreak)
        } catch let error {
            //need to handle error..
        }
    }


}
