//
//  HabitsViewModel.swift
//  HabitSetter
//
//  Created by Mattias Axelsson on 2024-04-25.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestoreSwift

class HabitsViewModel : ObservableObject {
    private var db = Firestore.firestore()
    
    private var habitsListenerRegistration: ListenerRegistration?
    private var habitsAllListenerRegistration: ListenerRegistration?
    private var performedHabitsListenerRegistration: ListenerRegistration?
    
    private var auth = Auth.auth()
    @Published var currentUserId = ""
    
    @Published var listOfNotPerformedHabits = [Habit]()
    @Published var listOfPerformedHabits = [Habit]()
    @Published var listOfAllHabits = [Habit]()
    @Published var errorMessage: String?
    
    @Published var habitAddedSuccessfully = false
    @Published var habitRemovedSuccessfully = false
    @Published var habitUpdatedSuccessfully = false
    
    @Published var streakVM = StreakViewModel()
    
    @Published var toastMessage: String? = ""

    
    let calendar = Calendar.current
    
    deinit {
        //When we do not need to listen anymore
        habitsListenerRegistration?.remove()
        performedHabitsListenerRegistration?.remove()
        habitsAllListenerRegistration?.remove()
    }
    
    init() {
        
        //On start load all habits from firestore with the correct user data
        NotificationCenter.default.addObserver(self, selector: #selector(handleUserChange), name: .didUpdateUserId, object: nil)
        
        if let uid = SessionManager.shared.currentUserId {
            self.currentUserId = uid
            self.loadHabits()
        }
    }
    
    @objc private func handleUserChange() {
        if let uid = SessionManager.shared.currentUserId {
            self.currentUserId = uid
            self.loadHabits()
        }
    }
    
    private func loadHabits() {
        loadNotPerformedHabits(fromUserId: currentUserId)
        loadPerformedHabits(fromUserId: currentUserId)
        loadAllHabits(fromUserId: currentUserId)
    }
    
    //add habit to firestore
    func add(habit: Habit) {
        do {
            try db.collection("habits").addDocument(from: habit) { [weak self] error in
                DispatchQueue.main.async {
                    if let error = error {
                        self?.errorMessage = "Error adding habit: \(error.localizedDescription)"
                        self?.habitAddedSuccessfully = false
                    } else {
                        //It was possible to add it
                        self?.habitAddedSuccessfully = true
                    }
                }
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Error encoding habit: \(error.localizedDescription)"
            }
        }
    }
    
    //Delete the habit from firestore
    func remove(habit: Habit) {
        guard let habitId = habit.id else {
            DispatchQueue.main.async {
                self.errorMessage = "Error: Habit has no ID"
            }
            return
        }
        
        db.collection("habits").document(habitId).delete { [weak self] error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.errorMessage = "Error removing habit: \(error.localizedDescription)"
                    self?.habitRemovedSuccessfully = false
                } else {
                    // It was possible to remove it
                    self?.habitRemovedSuccessfully = true
                }
            }
        }
    }
    
    //Update habit in Firestore
    func update(habit: Habit) {
        guard let habitId = habit.id else { return }
        guard let habitImageLink = habit.imageLink else { return }
        guard let habitUserId = habit.userId else { return }
        
        db.collection("habits").document(habitId).setData([
            "name": habit.name,
            "description": habit.description,
            "category": habit.category.rawValue,
            "interval": habit.interval.rawValue,
            "imageLink": habitImageLink,
            "sendNotification": habit.sendNotification,
            "userId": habitUserId,
            "dateCreated": habit.dateCreated,  //Firestore Timestamp
            "dateEdited": Timestamp(date: Date())  //Current date as Firestore Timestamp
        ], merge: true) { error in
            DispatchQueue.main.async {
                if let error = error {
                    self.errorMessage = "Error updating habit: \(error.localizedDescription)"
                    self.habitUpdatedSuccessfully = false
                } else {
                    self.habitUpdatedSuccessfully = true
                    //add a toast or similar to show that the habit was updated?
                }
            }
        }
    }
    func updateStreaks(for habitId: String?, withNewColor hexColor: String) {
        
        //guard id as usual
        guard let habitId = habitId else { return }
        
        db.collection("streaks").whereField("habitId", isEqualTo: habitId).getDocuments { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                
                //after we got the streaks documents, update the color for these with the new color
                for document in querySnapshot!.documents {
                    self.db.collection("streaks").document(document.documentID).updateData([
                        "habitColor": hexColor //Update color
                    ]) { err in
                        if let err = err {
                            print("Error updating document: \(err)")
                        }
                    }
                }
            }
        }
    }
    
    //Get all habits not completed for day
    //Make sure to only pick the ones with nextDue on todays date.
    func loadNotPerformedHabits(fromUserId: String) {
        let startOfDay = calendar.startOfDay(for: Date())  // Today at midnight
        
        habitsListenerRegistration = db.collection("habits")
            .whereField("userId", isEqualTo: fromUserId)
            .whereField("nextDue", isLessThanOrEqualTo: startOfDay)
            .addSnapshotListener { [weak self] snapshot, error in
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    
                    if let error = error {
                        self.errorMessage = "Error fetching habits: \(error.localizedDescription)"
                        return
                    }
                    
                    self.listOfNotPerformedHabits = snapshot?.documents.compactMap { document in
                        if var habit = try? document.data(as: Habit.self) {
                            habit.id = document.documentID  // Assign the ID to our mutable habit
                            // Check if the habit was performed today
                            if let performedDate = habit.performed, self.calendar.isDate(performedDate, inSameDayAs: startOfDay) {
                                return nil  // Skip this habit as it was already performed today
                            }
                            return habit  // Include this habit as it has not been performed today
                        }
                        return nil
                    } ?? []
                }
            }
    }
    
    
    func loadAllHabits(fromUserId: String) {
        habitsAllListenerRegistration = db.collection("habits")
            .whereField("userId", isEqualTo: fromUserId)
            .addSnapshotListener { [weak self] snapshot, error in
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    
                    if let error = error {
                        self.errorMessage = "Error fetching habits: \(error.localizedDescription)"
                        return
                    }
                    
                    //compactmap is new for me..
                    self.listOfAllHabits = snapshot?.documents.compactMap { document in
                        var habit = try? document.data(as: Habit.self)
                        habit?.id = document.documentID //make sure ID is correct
                        
                        return habit
                    } ?? []
                    
                }
            }
    }
    //Get performed habits (as of now, a seperate function)
    func loadPerformedHabits(fromUserId: String) {
        let startOfDay = calendar.startOfDay(for: Date()) // Today at midnight
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else { return }
        
        performedHabitsListenerRegistration = db.collection("habits")
            .whereField("userId", isEqualTo: fromUserId)
            .whereField("performed", isGreaterThanOrEqualTo: startOfDay)
            .whereField("performed", isLessThan: endOfDay)
            .addSnapshotListener { [weak self] snapshot, error in
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    
                    if let error = error {
                        self.errorMessage = "Error fetching performed habits: \(error.localizedDescription)"
                        return
                    }
                    
                    self.listOfPerformedHabits = snapshot?.documents.compactMap { document in
                        if var habit = try? document.data(as: Habit.self) {
                            habit.id = document.documentID  // Set the document ID to the habit
                            return habit
                        }
                        return nil
                    } ?? []
                }
            }
    }
    
    
    //Handle all toggle functions (streak and completed habits)
    func toggleHabitStatus(of habit: Habit) {
        guard let habitId = habit.id else { return }
        
        let habitRef = db.collection("habits").document(habitId)
        let today = Calendar.current.startOfDay(for: Date())

        //Check if the habit was performed today already
        let wasPerformedToday: Bool
        if let performedDate = habit.performed {
            wasPerformedToday = Calendar.current.isDate(performedDate, inSameDayAs: today)
        } else {
            wasPerformedToday = false
        }

        //Lets update status depending if the habit is in the bottom or top section (performed or not)
        let newStatus: Date?
        let newNextDue: Date
        if wasPerformedToday {

            //ok so this is an undo action, we need to set date to nil to indicate that this habit has not been performed
            newStatus = nil
            newNextDue = today  //next due is back to todays date
            
            //also, this affect the streak for this habit, lets undo that as well
            streakVM.addOrUpdateStreak(habit: habit, performedDate: today, isUndo: true)
        } else {
            //was not perform already, new status update
            newStatus = today
            newNextDue = calculateNextDueDate(from: today, interval: habit.interval)
            //update or create streak
            streakVM.addOrUpdateStreak(habit: habit, performedDate: today, isUndo: false)
        }

        //update firestore
        habitRef.updateData([
            "performed": newStatus ?? FieldValue.delete(),
            "nextDue": newNextDue,
            "lastPerformed": today
        ]) { err in
            if let err = err {
                print("Error updating habit: \(err)")
            } else {
                self.updateLocalHabitsList(habit: habit, newPerformedDate: newStatus, newNextDue: newNextDue)
                
            }
        }
    }

    func calculateNextDueDate(from date: Date, interval: HabitInterval) -> Date {
        let calendar = Calendar.current
        return calendar.date(byAdding: .day, value: interval.days(), to: date)!
    }
    
    func calculatePreviousDueDate(from date: Date, interval: HabitInterval) -> Date {
        let calendar = Calendar.current
        return calendar.date(byAdding: .day, value: -interval.days(), to: date)!
    }
    func updateLocalHabitsList(habit: Habit, newPerformedDate: Date?, newNextDue: Date) {
        if let index = self.listOfNotPerformedHabits.firstIndex(where: { $0.id == habit.id }) {
            self.listOfNotPerformedHabits[index].performed = newPerformedDate
            self.listOfNotPerformedHabits[index].nextDue = newNextDue
        }
        if let index = self.listOfPerformedHabits.firstIndex(where: { $0.id == habit.id }) {
            self.listOfPerformedHabits[index].performed = newPerformedDate
            self.listOfPerformedHabits[index].nextDue = newNextDue
        }
    }
    
}
