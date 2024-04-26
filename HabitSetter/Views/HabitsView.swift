//
//  HabitsView.swift
//  HabitSetter
//
//  Created by Mattias Axelsson on 2024-04-24.
//

import SwiftUI

struct HabitsView: View {
    // Mockup data för demonstration
    var habits = ["Read Book", "Workout", "Meditation", "Run", "Do not code Android apps", "something else", "more test data", "Need to code in swift", "test data2", "Need to code in swift", "test data2"]
    
    var body: some View {
        TabView {
            // Tab 1: Home View
            NavigationStack {
                VStack(spacing: 10) {  // distance between stuff in the group
                    List(habits, id: \.self) { habit in
                        Text(habit)
                            .padding(.vertical, 5)
                    }
                    .listStyle(PlainListStyle())
                    
                    Group { Text("Completed Habits Today")
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(habits, id: \.self) { habit in
                                    Text(habit)
                                        .padding()
                                        .background(Color.gray.opacity(0.2)) //background
                                        .cornerRadius(10) //looks like cards..
                                }
                            }
                            .padding(.horizontal)
                        }.padding(.bottom, 20)
                        
                    }
                    .background(Color.gray.opacity(0.1))
                }
                 .navigationTitle("Habits for today")
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
