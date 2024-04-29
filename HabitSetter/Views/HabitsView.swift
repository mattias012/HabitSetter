//
//  HabitsView.swift
//  HabitSetter
//
//  Created by Mattias Axelsson on 2024-04-24.
//

//import SwiftUI
//
//struct HabitsView: View {
//    
//    @Environment(\.presentationMode) var presentationMode
//    @EnvironmentObject var habitsVM : HabitsViewModel
//    
//    @State var habit : Habit
//    
//    var body: some View {
//        
//        TabView {
//            // Tab 1: Home View
//            NavigationStack {
//                Spacer()
//                VStack() {  //set distance between stuff in the group
//                    List(){
//                        ForEach(habitsVM.listOfHabits) { habit in
//                            HabitCard(habit: habit)
//                                .frame(maxHeight: 160)
//                                .padding(.horizontal, -5)
//                                .listRowInsets(EdgeInsets())
//                        }
//                    }
//                    .listStyle(PlainListStyle())
//                    
//                    Spacer()
//                    
//                    Group {
//                        Text("Completed Habits Today")
//                            .font(.headline)
//                            .padding()
//                            .frame(maxWidth: .infinity, alignment: .leading)
//                        ScrollView(.horizontal, showsIndicators: false) {
//                            HStack(spacing: 10) {
//                                ForEach (habitsVM.listOfPerformedHabits) { habit in
//                                    Text(habit.name)
//                                        .padding()
//                                        .background(Color.gray.opacity(0.2)) //background
//                                        .cornerRadius(10) //looks like cards..
//                                }
//                            }
//                            .padding(.horizontal)
//                        }.padding(.bottom, 20)
//                        
//                    }
//                    Spacer()
//                }
//                .navigationTitle("Habits for today")
//            }
//            .tabItem {
//                Label("Home", systemImage: "house")
//            }
//            .onAppear(){
//                //                habits.getHabits()
//            }
//            
//            
//            // Tab 2: List of all habits
//            NavigationStack {
//                List {
//                    ForEach(habitsVM.listOfHabits) { habit in
//                        Text(habit.name)
//                    }
//                }
//            }
//            .navigationTitle("All Habits")
//            .toolbar {
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    // Passing an empty Habit for creation
//                    Image(systemName: "plus")
//                }
//            }
//        }
//        
//        .tabItem {
//            Label("Habits", systemImage: "list.bullet")
//        }
//        // Tab 3: Profile View
//        // Not sure what to have here yet..
//        NavigationStack {
//            Text("Profile Info Here")
//                .navigationTitle("Profile")
//        }
//        .tabItem {
//            Label("Profile", systemImage: "person.crop.circle")
//        }
//        
//        
//        // Function to delete a habit
//        func deleteHabit(at offsets: IndexSet) {
//            offsets.forEach { index in
//                // Get the habit to be deleted
//                let habit = habitsVM.listOfHabits[index]
//                // Call the remove function in your view model with the habit
//                habitsVM.remove(habit: habit)
//            }
//            
//            // Remove from local data array
//            habitsVM.listOfHabits.remove(atOffsets: offsets)
//        }
//        
//        
//    }
//}
//struct HabitCard: View {
//    var habit: Habit
//    
//    var body: some View {
//        HStack(alignment: .top, spacing: 10) {
//            VStack (alignment: .leading){
//                Image("habit")
//                    .resizable()  //make it resizeable
//                    .aspectRatio(contentMode: .fill)
//                    .frame(width: 60, height: 60)  //size
//                    .cornerRadius(40)  //make it round
//            }
//            
//            VStack (alignment: .leading) {
//                Text(habit.name)
//                    .font(.headline)
//                    .foregroundColor(.primary)
//                if !habit.description.isEmpty {
//                    Text(habit.description)
//                        .font(.subheadline)
//                        .foregroundColor(.secondary)
//                        .lineLimit(nil) //allow more lines
//                }
//            }
//            Spacer()
//        }
//        .padding()
//        .frame(maxWidth: .infinity)
//        .background(Color.white)
//        .cornerRadius(10) // make round corneres looks nicer
//        .shadow(radius: 5) //add shadow
//        .padding(.horizontal)
//        .padding(.vertical, 5)
//    }
//}

import SwiftUI

struct HabitsView: View {
    
    @EnvironmentObject var habitsVM: HabitsViewModel
    
    @State var habit : Habit?
    
    var body: some View {
        TabView {
            // Tab 1: Home View
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
                    .onDelete(perform: deleteHabit)
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
    
    // Tab 2: List of all habits
    var allHabitsTab: some View {
        NavigationStack {
            List {
                ForEach($habitsVM.listOfHabits.indices, id: \.self) { index in
                    NavigationLink(destination: AddEditHabitView(habit: Binding($habitsVM.listOfHabits[index]))) {
                        Text(habitsVM.listOfHabits[index].name)
                    }
                }
            }
            .navigationTitle("All Habits")
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
    
    // Tab 3: Profile View
    var profileTab: some View {
        NavigationStack {
            Text("Profile Info Here")
                .navigationTitle("Profile")
        }
        .tabItem {
            Label("Profile", systemImage: "person.crop.circle")
        }
    }
    
    // Completed Habits Section
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
    
    // Function to delete a habit
    func deleteHabit(at offsets: IndexSet) {
        offsets.forEach { index in
            let habit = habitsVM.listOfHabits[index]
            habitsVM.remove(habit: habit)
        }
        habitsVM.listOfHabits.remove(atOffsets: offsets)
    }
}

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
