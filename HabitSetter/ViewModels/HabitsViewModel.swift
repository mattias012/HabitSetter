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
    
    let db = Firestore.firestore()
    
    @Published var listOfHabits = [Habit]()
    
    func add(habit: Habit){
        
        let myHabit = habit
        
        //Add habit to database
        do {
            try db.collection("habits").addDocument(from: myHabit)
            print("habit added")
        } catch {
            //Add alert or something for user?
            print("Error saving document to firestore")
        }
        
    }
    
    
}
