//
//  HabitsView.swift
//  HabitSetter
//
//  Created by Mattias Axelsson on 2024-04-24.
//

import SwiftUI

struct HabitsView: View {
    // Mockup data för demonstration
    var habits = ["Read Book", "Workout", "Meditation"]

    var body: some View {
        TabView {
            // Tab 1: Home View
            NavigationStack {
                List(habits, id: \.self) { habit in
                    Text(habit)
                }
                .navigationTitle("Today's Habits")
                .toolbar {
                    // Placera eventuell ytterligare funktionalitet här, som en knapp
                }
            }
            .tabItem {
                Label("Home", systemImage: "house")
            }

            // Tab 2: List of all habits
            NavigationStack {
                List(habits, id: \.self) { habit in
                    Text(habit)
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

#Preview {
    HabitsView()
}
