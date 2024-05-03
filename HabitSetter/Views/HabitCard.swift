//
//  HabitCard.swift
//  HabitSetter
//
//  Created by Mattias Axelsson on 2024-05-03.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestoreSwift

//This is my habit card, perhaps move it outside of this file?
struct HabitCard: View {
    
    @ObservedObject var streakVM: StreakViewModel
    @ObservedObject var habitsVM: HabitsViewModel
    var habit: Habit
    
    var body: some View {
        VStack {
        HStack(alignment: .center, spacing: 10) {
            VStack(alignment: .leading) {
                Image("habit")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 40, height: 40)
                    .cornerRadius(40)
            }
            VStack(alignment: .leading) {
                Text(habit.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                    
                
            }
            Spacer()
            
        }
        Spacer()
        HStack {
                if !habit.description.isEmpty {
                    Text(habit.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(nil)
                }
                Spacer()
                ChartView(streakVM: streakVM, habit: habit)
            }
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
