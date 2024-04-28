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
    private var performedHabitsListenerRegistration: ListenerRegistration?
    
    private var auth = Auth.auth()
    private var currentUserId = ""
    
    @Published var listOfHabits = [Habit]()
    @Published var listOfPerformedHabits = [Habit]()
    @Published var errorMessage: String?
    
    @Published var habitAddedSuccessfully = false
    
    
    deinit {
        //When we do not need to listen anymore
        habitsListenerRegistration?.remove()
        performedHabitsListenerRegistration?.remove()
    }
    
    init() {
        //On start load all habits from firestore with the correct user data
        if (auth.currentUser?.uid != nil) {
            
            currentUserId = auth.currentUser?.uid ?? ""
            
            loadHabits(fromUserId: currentUserId, performed: false)
            loadPerformedHabits(fromUserId: currentUserId)
        }
    }
    
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
    
    func loadHabits(fromUserId: String, performed: Bool) {
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
                    
                    self.listOfHabits = snapshot?.documents.compactMap { document in
                        var habit = try? document.data(as: Habit.self)
                        habit?.id = document.documentID // make sure ID is correct
                        print("Loaded habit with ID: \(String(describing: habit?.id))") //for debuging
                        return habit
                    } ?? []
                    
                }
            }
    }
    func loadPerformedHabits(fromUserId: String) {
        performedHabitsListenerRegistration = db.collection("habits")
            .whereField("userId", isEqualTo: fromUserId)
            .whereField("performed", isEqualTo: true)
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
}
