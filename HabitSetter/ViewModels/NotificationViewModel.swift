//
//  NotificationView.swift
//  HabitSetter
//
//  Created by Mattias Axelsson on 2024-05-06.
//

import SwiftUI
import UserNotifications
import Firebase
import FirebaseAuth
import FirebaseFirestoreSwift


//Not thought through this model all the way. At this stage only a daily reminder.. Perhaps change Habits model to include time to remind or something..
//but then the user can receive many alerts in worst case. Very annoying?
class NotificationViewModel: ObservableObject {
    
    let calendar = Calendar.current
    private var db = Firestore.firestore()
    private var habitsListenerRegistration: ListenerRegistration?
    
    init() {
        requestPermissions()
        setupDailyReminder()
    }
    
    func requestPermissions() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                DispatchQueue.main.async {
                    // Notifikationstillstånd beviljat
                }
            } else if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    func setupDailyReminder() {
        
        //set userId
        guard let userId = SessionManager.shared.currentUserId else { return }
        
        let startOfDay = calendar.startOfDay(for: Date())
        
        //remove any duplicates
        habitsListenerRegistration?.remove()
        
        //browse database to see if something has been mark as performed
        habitsListenerRegistration = db.collection("habits")
            .whereField("userId", isEqualTo: userId)
            .whereField("nextDue", isLessThanOrEqualTo: startOfDay)
            .whereField("sendNotification", isEqualTo: true)
            .addSnapshotListener { snapshot, error in
                
                if error != nil {
                }
                
                do {
                    let listOfNotPerformedHabits = try snapshot?.documents.compactMap { document -> Habit? in
                        return try document.data(as: Habit.self)
                    } ?? []
                    
                    //If list is not empy, we schedule the notifications
                    if !listOfNotPerformedHabits.isEmpty {
                        self.scheduleNotification()
                    }
                } catch {
                    print("Error decoding habits: \(error)")
                }
            }
    }
    
    func scheduleNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Daily Reminder"
        content.body = "You have habits to complete today."
        content.sound = .default
        
        //Set time when to notify user
        var dateComponents = DateComponents()
        dateComponents.hour = 10
        dateComponents.minute = 15
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            }
        }
    }
}

