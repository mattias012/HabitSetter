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
    
    @Published var showToast: Bool = false
    @Published var toastMessage: String?
        
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
                
                //handle result, get the first document in case of any duplicates (unlikely?)
                if let documents = snapshot?.documents, let document = documents.first {
                    if isUndo {
                        //we need to handle the undo action..
                        self.handleUndoAction(for: document, with: performedDate)
                    } else {
                        
                        //update or create a new streak, we
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
        
        //Check if the habit's interval aligns with the streak, so if a user changes intervall on a selected habit it can still remain a streak.
        let intervalMatches = habit.interval.days() == (existingStreak?.interval.days() ?? 0)
        
        //After that we check if the performed date falls within the streak's interval (which can have changed)
        let performedDateWithinInterval = isPerformedDateWithinInterval(performedDate, lastPerformed: existingStreak?.lastDayPerformed ?? Date(), interval: habit.interval)
        
        //Update streak only if interval matches and performed date falls within interval
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
        
        //otherwise we do something else?
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
        
        let streaksCollection = db.collection("streaks")
        
        let newStreakRef = streaksCollection.document()
        
        //Create Streak
        let newStreak = Streak(
            userId: habit.userId!,
            habitId: habit.id!,
            firstDayOfStreak: performedDate,
            lastDayPerformed: performedDate,
            currentStreakCount: 1,
            interval: habit.interval
        )
        
        do {
            //Save
            try newStreakRef.setData(from: newStreak)
            
            //Get this new ID to save it to the habit
            let streakId = newStreakRef.documentID
            
            //Update habit with streak ID
            self.updateHabitWithStreakId(habit: habit, streakId: streakId)
            
        } catch {
            
            //error handling.. toast or what is this called in iOS?
        }
    }
    
    
    private func updateHabitWithStreakId(habit: Habit, streakId: String) {
        
        let habitRef = db.collection("habits").document(habit.id!)
        habitRef.updateData([
            "currentStreakID": streakId
        ]) { err in
            if let err = err {
                self.toastMessage = "Error: \(err.localizedDescription)"
            } else {
                self.toastMessage = "Good job, keeping the streak alive!"
            }
        }
    }
    
    // Function to fetch the current streak for a habit
    // Fetch the current streak for a specific habit and return it via completion handler
        func getCurrentStreak(habit: Habit, completion: @escaping (Result<Int, Error>) -> Void) {
            guard let habitId = habit.id, let userId = habit.userId else {
                let error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid habit or user ID"])
                completion(.failure(error))
                return
            }

            let streaksCollection = db.collection("streaks")
            
            streaksCollection
                .whereField("userId", isEqualTo: userId)
                .whereField("habitId", isEqualTo: habitId)
                .getDocuments { snapshot, error in
                    if let error = error {
                        completion(.failure(error))
                        return
                    }

                    if let document = snapshot?.documents.first,
                       let streakCount = document.data()["currentStreakCount"] as? Int {
                        completion(.success(streakCount))
                    } else {
                        let error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Streak data not found"])
                        completion(.failure(error))
                    }
                }
        }
}


