//
//  HabitsView.swift
//  HabitSetter
//
//  Created by Mattias Axelsson on 2024-04-24.
//

import SwiftUI

struct HabitsView: View {
    
    @EnvironmentObject var habitsVM: HabitsViewModel
    
    @State var habit : Habit?
    
    @State private var showDeleteConfirm = false
    @State private var indexSetToDelete: IndexSet? //keep track of the rows in the list
    
    var body: some View {
        TabView {
            //Tab 1: Home View
            homeViewTab
            
            // Tab 2: List of all habits
            allHabitsTab
            
            // Tab 3: Profile View
            profileTab
        }
    }
    
    // Tab 1: Home View
    var homeViewTab: some View {
        NavigationStack {
            VStack {
                List {
                    ForEach(habitsVM.listOfHabits) { habit in
                        HabitCard(habit: habit)
                            .frame(maxHeight: 160)
                            .padding(.horizontal, -5)
                            .listRowInsets(EdgeInsets())
                    }
                   
                }
                .listStyle(PlainListStyle())
                .navigationTitle("Habits for Today")
                
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
                ForEach($habitsVM.listOfHabits.indices, id: \.self) { index in
                    NavigationLink(destination: AddEditHabitView(habit: Binding($habitsVM.listOfHabits[index]))) {
                        Text(habitsVM.listOfHabits[index].name)
                    }
                }
                .onDelete(perform: showDeleteConfirmation)
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
            Text("Profile Info Here")
                .navigationTitle("Profile")
        }
        .tabItem {
            Label("Profile", systemImage: "person.crop.circle")
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
                    }
                }
                .padding(.horizontal)
            }
            .padding(.bottom, 20)
        }
    }
    
    // Function to delete a habit with a confirmation window
    private func showDeleteConfirmation(at indexSet: IndexSet) {
            indexSetToDelete = indexSet //save the index to a variable
            showDeleteConfirm = true //show alert
        }

        private func deleteHabit() {
            if let indexSet = indexSetToDelete {
                //Actually delete the habit
                indexSet.forEach { index in
                    let habit = habitsVM.listOfHabits[index]
                    habitsVM.remove(habit: habit)
                }
                
                //delete from firestore
                habitsVM.listOfHabits.remove(atOffsets: indexSet)
                
                //restore variables after deletion is complete
                indexSetToDelete = nil
                showDeleteConfirm = false
            }
        }
}

//This is my habit card, perhaps move it outside of this file?
struct HabitCard: View {
    var habit: Habit
    
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            VStack(alignment: .leading) {
                Image("habit")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 60, height: 60)
                    .cornerRadius(40)
            }
            VStack(alignment: .leading) {
                Text(habit.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                if !habit.description.isEmpty {
                    Text(habit.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(nil)
                }
            }
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 5)
        .padding(.horizontal)
        .padding(.vertical, 5)
    }
}

#Preview {
    HabitsView()
}
