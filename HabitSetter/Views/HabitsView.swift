//
//  HabitsView.swift
//  HabitSetter
//
//  Created by Mattias Axelsson on 2024-04-24.
//

import SwiftUI

struct HabitsView: View {
    // Mockup data för demonstration
    //    var habits = ["Read Book", "Workout", "Meditation", "Run", "Do not code Android apps", "something else", "more test data", "Need to code in swift", "test data2", "Need to code in swift", "test data2"]
    
    @ObservedObject var habits = HabitsViewModel()
    
    let columns: [GridItem] = Array(repeating: GridItem(.flexible(), spacing: 10), count: 2) // Definiera antalet kolumner och avståndet mellan dem
    
    var body: some View {
        TabView {
            // Tab 1: Home View
            NavigationStack {
                VStack() {  // distance between stuff in the group
                    ScrollView(.horizontal, showsIndicators: true){
                        LazyVGrid(columns: columns, spacing: 0) { // Använd LazyVGrid för att hantera stora dataset effektivt
                            ForEach(habits.listOfHabits) { habit in
                                HabitCard(habit: habit)
                            }
                        }
                    }
                    .padding()
                        
                    Group {
                        Text("Completed Habits Today")
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach (habits.listOfHabits) { habit in
                                    Text(habit.name)
                                        .padding()
                                        .background(Color.gray.opacity(0.2)) //background
                                        .cornerRadius(10) //looks like cards..
                                }
                            }
                            .padding(.horizontal)
                        }.padding(.bottom, 20)
                        
                    }
                    //                    .background(Color.gray.opacity(0.1))
                }
                .navigationTitle("Habits for today")
            }
            .tabItem {
                Label("Home", systemImage: "house")
            }
            .onAppear(){
                //                habits.getHabits()
            }
            
            // Tab 2: List of all habits
            NavigationStack {
                List(){
                    ForEach (habits.listOfHabits) { habit in
                        Text(habit.name)
                    }
                }
                .navigationTitle("All Habits")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        NavigationLink(destination: AddEditHabitView()) {
                            Image(systemName: "plus")
                        }
                    }
                }
            }
            .tabItem {
                Label("Habits", systemImage: "list.bullet")
            }
            
            // Tab 3: Profile View
            NavigationStack {
                Text("Profile Info Here")
                    .navigationTitle("Profile")
            }
            .tabItem {
                Label("Profile", systemImage: "person.crop.circle")
            }
        }
    }
    
    
}
struct HabitCard: View {
    var habit: Habit
    
    var body: some View {
        HStack(spacing: 10) {
            
            Image("habit")
                .resizable()  // Gör bilden skalbar
                .aspectRatio(contentMode: .fill)  // Behåller bildens aspektkvot
                .frame(width: 60, height: 60)  // Ställer in bildens storlek
                .cornerRadius(40)  // Gör bilden cirkulär
            
            VStack (alignment: .leading) {
                Text(habit.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                if !habit.description.isEmpty {
                    Text(habit.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(nil) // Tillåter fler än en rad om nödvändigt
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white) // Ljus bakgrund för kortet
        .cornerRadius(10) // Runda hörn
        .shadow(radius: 5) // Lägger till en liten skugga för att ge djup
        .padding(.horizontal)
        .padding(.vertical, 5)
    }
}


#Preview {
    HabitsView()
}
