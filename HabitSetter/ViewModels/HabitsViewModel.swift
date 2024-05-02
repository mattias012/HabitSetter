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
        
        db.collection("habits").document(habitId).setData([
            "name": habit.name,
            "description": habit.description,
            "category": habit.category.rawValue,  //Assuming category is an enum
            "interval": habit.interval.rawValue,  //Assuming interval is an enum
            "imageLink": habit.imageLink,
            "sendNotification": habit.sendNotification,
            "userId": habit.userId,
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
    
    //Get all habits not completeed
    func loadNotPerformedHabits(fromUserId: String, performed: Bool) {
        habitsListenerRegistration = db.collection("habits")
            .whereField("userId", isEqualTo: fromUserId)
            .whereField("performed", isEqualTo: performed)
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
                        print("Loaded habit with ID: \(String(describing: habit?.id))") //for debuging
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
                        habit?.id = document.documentID // make sure ID is correct
                        print("Loaded habit with ID: \(String(describing: habit?.id))") //for debuging
                        return habit
                    } ?? []
                    
                }
            }
    }
    //Get performed habits (as of now, a seperate function)
    func loadPerformedHabits(fromUserId: String, performed: Bool) {
        performedHabitsListenerRegistration = db.collection("habits")
            .whereField("userId", isEqualTo: fromUserId)
            .whereField("performed", isEqualTo: performed)
            .addSnapshotListener { [weak self] snapshot, error in
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    
                    if let error = error {
                        self.errorMessage = "Error fetching performed habits: \(error.localizedDescription)"
                        return
                    }
                    
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

        habitRef.updateData([
            "performed": newStatus
        ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Document successfully updated")
                if let index = self.listOfNotPerformedHabits.firstIndex(where: { $0.id == habit.id }) {
                    self.listOfNotPerformedHabits[index].performed = newStatus
                }
                if let index = self.listOfPerformedHabits.firstIndex(where: { $0.id == habit.id }) {
                    self.listOfPerformedHabits[index].performed = newStatus
                }
            }
        }
    }
}
