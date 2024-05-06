//
//  HabitsView.swift
//  HabitSetter
//
//  Created by Mattias Axelsson on 2024-04-24.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestoreSwift
import Charts


struct HabitsView: View {
    
    @EnvironmentObject var habitsVM: HabitsViewModel
    
    @StateObject var streakVM = StreakViewModel()
    @StateObject var userVM = UserViewModel()
    @StateObject var notificationVM = NotificationViewModel()
    
    @State var habit : Habit?
    
    @Binding var signedIn: Bool
    
    @State private var showDeleteConfirm = false
    @State private var indexSetToDelete: IndexSet? //keep track of the rows in the list
    
    @State var ourGreeting: String = ""
    
    @State var showGreeting = false
    
    var body: some View {
        
        VStack(alignment: .leading){
            if showGreeting {
                Text(ourGreeting)
                    .font(.title)
                    .padding([.top, .leading, .trailing])
            }
        }
        
        TabView {
            
            //Tab 1: Home View
            homeViewTab
            
            //Tab 2: List of all habits
            allHabitsTab
            
            //Tab 3: Profile View
            profileTab
        }
        .onAppear {
                   checkAndShowGreeting()
                //Start scheduling notifications
//                notificationVM.scheduleNotification()
        }
    }
    
    // Tab 1: Home View
    var homeViewTab: some View {
        

            NavigationStack {
                VStack {
                    List {
                        ForEach(habitsVM.listOfNotPerformedHabits) { habit in
                                    HabitCard(streakVM: streakVM, habitsVM: habitsVM, habit: habit)
                                        .frame(maxHeight: 160)
                                        .padding(.horizontal, -5)
                                        .listRowInsets(EdgeInsets())
                                        .onTapGesture {
                                            
                                            habitsVM.toggleHabitStatus(of: habit)
                                            streakVM.toastMessage = "Good job keeping the streak alive!"
                                            streakVM.showToast = true
                                        }
                                }
                    }
                    .listStyle(PlainListStyle())
                    .navigationTitle("Today's Habits")
                    .font(.subheadline)
    
                }
                .onAppear {
                    
                    userVM.greetUser(id: SessionManager.shared.currentUserId){ result in
                        switch result {
                        case .success(let greeting):
                            ourGreeting = greeting
                        case .failure(let error):
                            print("Error fetching user: \(error.localizedDescription)")
                        }
                        
                    }
                }
                .toast(isShowing: $streakVM.showToast, message: streakVM.toastMessage)
                
                VStack {
                    completedHabitsSection
                }
        }
        .tabItem {
                Label("Home", systemImage: "house")
        }
        
    }
    
    //Tab 2: List of all habits
    var allHabitsTab: some View {
        NavigationStack {
            List {
                ForEach($habitsVM.listOfAllHabits.indices, id: \.self) { index in
                    NavigationLink(destination: AddEditHabitView(habit: Binding($habitsVM.listOfAllHabits[index]))) {
                        Text(habitsVM.listOfAllHabits[index].name)
                    }
                }
                .onDelete(perform: showDeleteConfirmation)
            }
            .onAppear(){
                showGreeting = false
            }
            .navigationTitle("All Habits") //menu/title
            .alert("Confirm Delete", isPresented: $showDeleteConfirm) { //create an alert prior to delete. We send the state of the showDeleteConfirm value to make sure it is not already dispLayed?
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    deleteHabit() //if user wants to delete, go ahead with the deletion
                }
            } message: {
                Text("Are you sure you want to delete this habit?")
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: AddEditHabitView(habit: $habit)) {
                        Image(systemName: "plus")
                    }
                }
            }
        }
        .tabItem {
            Label("Habits", systemImage: "list.bullet")
        }
    }
    
    
    //Tab 3: Profile View
    var profileTab: some View {
        NavigationStack {
                CalenderView()
                .onAppear(){
                    showGreeting = false
                }
                .navigationTitle("Profile")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: logOut) {
                            Label("Log Out", systemImage: "rectangle.portrait.and.arrow.right")
                        }
                    }
                }
        }
        .tabItem {
            Label("Profile & Streak", systemImage: "person.crop.circle")
        }
    }
    
    //Completed Habits Section
    var completedHabitsSection: some View {
        Group {
            Text("Completed Habits Today")
                .font(.headline)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(habitsVM.listOfPerformedHabits) { habit in
                        Text(habit.name)
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(10)
                            .onTapGesture {
                                habitsVM.toggleHabitStatus(of: habit)
                            }
                    }
                }
                .padding(.horizontal)
            }
            .padding(.bottom, 20)
        }
    }
    
    //Function to delete a habit with a confirmation window
    private func showDeleteConfirmation(at indexSet: IndexSet) {
        indexSetToDelete = indexSet //save the index to a variable
        showDeleteConfirm = true //show alert
    }
    
    private func deleteHabit() {
        if let indexSet = indexSetToDelete {
            //Actually delete the habit
            indexSet.forEach { index in
                let habit = habitsVM.listOfAllHabits[index]
                habitsVM.remove(habit: habit)
            }
            
            //delete from firestore
            habitsVM.listOfAllHabits.remove(atOffsets: indexSet)
            
            //restore variables after deletion is complete
            indexSetToDelete = nil
            showDeleteConfirm = false
        }
    }
    private func logOut() {
        do {
            try Auth.auth().signOut()
            signedIn = false  //update auth state
            SessionManager.shared.currentUserId = nil  // reset session manager user ID
            NotificationCenter.default.post(name: .didLogOut, object: nil)
            
        } catch let signOutError {
            print(signOutError)
        }
    }
    
    func checkAndShowGreeting() {
        
        //this is actually just for any person using the app, so the greeting message will not appear if a different user is logged in..
        //perhaps change later on?
        
            let lastOpened = UserDefaults.standard.object(forKey: "LastOpened") as? Date ?? Date.distantPast
            let timeIntervalSinceLastOpened = Date().timeIntervalSince(lastOpened)
            
            //show greet if user has not open the app last hour (in seconds)
            if timeIntervalSinceLastOpened > 3600 {
                showGreeting = true
                UserDefaults.standard.set(Date(), forKey: "LastOpened")
            }
        }
}
    

//#Preview {
//    HabitsView(signedIn: $signedIn)
//}
