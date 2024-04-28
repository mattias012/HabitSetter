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
    private var listenerRegistration: ListenerRegistration?
    private var auth = Auth.auth()
    private var currentUserId = ""
    
    @Published var listOfHabits = [Habit]()
    @Published var errorMessage: String?
    
    deinit {
        //When we do not need to listen anymore
        listenerRegistration?.remove()
    }
    
    init() {
        //On start load all habits from firestore with the correct user data
        if (auth.currentUser?.uid != nil) {
            
            currentUserId = auth.currentUser?.uid ?? ""
            
            loadHabits(fromUserId: currentUserId)
        }
    }
    
    func add(habit: Habit) {
        do {
            try db.collection("habits").addDocument(from: habit) { error in
                if let error = error {
                    DispatchQueue.main.async {
                        self.errorMessage = "Error adding habit: \(error.localizedDescription)"
                    }
                }
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Error encoding habit: \(error.localizedDescription)"
            }
        }
    }
    
    func loadHabits(fromUserId: String) {
        listenerRegistration = db.collection("habits")
            .whereField("userId", isEqualTo: fromUserId)
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
}
