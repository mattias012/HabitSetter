//
//  ChartView.swift
//  HabitSetter
//
//  Created by Mattias Axelsson on 2024-05-03.
//
import SwiftUI
import Charts

struct PostCount {
    var category: String
    var count: Int
}

struct ChartView: View {
    
    @ObservedObject var streakVM : StreakViewModel
    var habit: Habit
    
    let totalDays: Int = 365
    @State private var currentStreak: Int = 0
    
    var result: Int {
        totalDays - currentStreak
    }
    
    var data: [PostCount] {
        [
            .init(category: "Streak", count: currentStreak),
            .init(category: "Year", count: result)
        ]
    }
    
    var body: some View {
        VStack {
            Chart(data, id: \.category) { item in
                SectorMark(
                    angle: .value("Count", item.count),
                    innerRadius: .ratio(0.6),
                    angularInset: 2
                )
                .foregroundStyle(by: .value("Category", item.category))
            }
            .chartBackground { chartProxy in
                GeometryReader { geometry in
                    if let anchor = chartProxy.plotFrame {
                        let frame = geometry[anchor]
                        Text("\(currentStreak)")
                            .position(x: frame.midX, y: frame.midY)
                    }
                }
            }
            .chartLegend(Visibility.hidden)
            .scaledToFit()
        }
        .onAppear {
            streakVM.getCurrentStreak(habit: habit) { result in
                switch result {
                case .success(let streak):
                    currentStreak = streak
                case .failure(let error):
                    print("Error fetching streak: \(error.localizedDescription)")
                }
            }
        }
    }
    
}
