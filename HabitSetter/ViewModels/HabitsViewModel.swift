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
        loadNotPerformedHabits(fromUserId: currentUserId, performed: false)
        loadPerformedHabits(fromUserId: currentUserId, performed: true)
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
        guard let habitId = habit.id else {
            errorMessage = "Error: Habit has no ID"
            return
        }
        guard let habitImageLink = habit.imageLink else { return }
        guard let habitUserId = habit.userId else { return }
        
        db.collection("habits").document(habitId).setData([
            "name": habit.name,
            "description": habit.description,
            "category": habit.category.rawValue,  //Assuming category is an enum
            "interval": habit.interval.rawValue,  //Assuming interval is an enum
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
    
    //Get all habits not completed for day
    //Make sure to only pick the ones with nextDue on todays date.
    func loadNotPerformedHabits(fromUserId: String, performed: Bool) {
        
        let startOfDay = calendar.startOfDay(for: Date()) //Gets today's date at midnight
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)! //Gets the end of today
        
        habitsListenerRegistration = db.collection("habits")
            .whereField("userId", isEqualTo: fromUserId)
            .whereField("performed", isEqualTo: performed)
            .whereField("nextDue", isLessThanOrEqualTo: endOfDay)
            .addSnapshotListener { [weak self] snapshot, error in
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    
                    if let error = error {
                        self.errorMessage = "Error fetching habits: \(error.localizedDescription)"
                        return
                    }
                    
                    self.listOfNotPerformedHabits = snapshot?.documents.compactMap { document in
                        var habit = try? document.data(as: Habit.self)
                        habit?.id = document.documentID // make sure ID is correct

                        return habit
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
                    
                    self.listOfAllHabits = snapshot?.documents.compactMap { document in
                        var habit = try? document.data(as: Habit.self)
                        habit?.id = document.documentID //make sure ID is correct
                        
                        return habit
                    } ?? []
                    
                }
            }
    }
    //Get performed habits (as of now, a seperate function)
    func loadPerformedHabits(fromUserId: String, performed: Bool) {
        
        let startOfDay = calendar.startOfDay(for: Date()) //Gets today's date at midnight
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)! //Gets the end of today
        
        performedHabitsListenerRegistration = db.collection("habits")
            .whereField("userId", isEqualTo: fromUserId)
            .whereField("performed", isEqualTo: performed)
            .whereField("lastPerformed", isGreaterThanOrEqualTo: startOfDay)
            .whereField("lastPerformed", isLessThan: endOfDay)
            .addSnapshotListener { [weak self] snapshot, error in
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    
                    if let error = error {
                        self.errorMessage = "Error fetching performed habits: \(error.localizedDescription)"
                        return
                    }
                    
                    //Compactmap is something new for me..
                    self.listOfPerformedHabits = snapshot?.documents.compactMap { document in
                        var habit = try? document.data(as: Habit.self)
                        habit?.id = document.documentID
                        return habit
                    } ?? []
                }
            }
    }
    
    func toggleHabitStatus(of habit: Habit) {
        
        let newStatus = !habit.performed //opposite of what is right now
        guard let habitId = habit.id  else { return } //lets guard in case of nil
        
        let habitRef = db.collection("habits").document(habitId)
        
        //Calculate new nextDue date
        //Determine new nextDue date based on whether the habit is being marked performed or undone
            let newNextDue: Date
            if newStatus {
                //If marking as performed, set next due date to future based on interval in Habit category
                newNextDue = calculateNextDueDate(from: Date(), interval: habit.interval)
            } else {
                //trying to catch if a habit is undone..calculate previous due date based on interval, best way?
                newNextDue = calculatePreviousDueDate(from: Date(), interval: habit.interval)
            }
        
        //Update the habit in Firestore
        habitRef.updateData([
            "performed": newStatus,
            "nextDue": newNextDue
        ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
                }
                else {
                    print("Document successfully updated")
                    //Update local lists to reflect changes
                    self.updateLocalHabitsList(habit: habit, newStatus: newStatus, newNextDue: newNextDue)
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
    func updateLocalHabitsList(habit: Habit, newStatus: Bool, newNextDue: Date) {
        // Assume there are two lists: one for performed and one for not performed habits
        if let index = self.listOfNotPerformedHabits.firstIndex(where: { $0.id == habit.id }) {
            self.listOfNotPerformedHabits[index].performed = newStatus
            self.listOfNotPerformedHabits[index].nextDue = newNextDue
        }
        if let index = self.listOfPerformedHabits.firstIndex(where: { $0.id == habit.id }) {
            self.listOfPerformedHabits[index].performed = newStatus
            self.listOfPerformedHabits[index].nextDue = newNextDue
        }
    }
    
}
