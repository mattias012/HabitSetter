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
    

//    @ObservedObject var streakVM: StreakViewModel
//    var habit: Habit
//    
//    let currentStreak: Int = 125 // Exempelvärde
//    let totalDays: Int = 365 // Totalt antal dagar (ett år)
//
//    let result: Int // Beräkna återstående dagar
//    var data: [PostCount] // Array för att lagra data
//
//    init() {
//        result = totalDays - currentStreak // Beräkna result
//        data = [
//            .init(category: "Streak", count: currentStreak),
//            .init(category: "Year", count: result)
//        ] // Initialisera data-arrayen korrekt
//    }
//
//    var body: some View {
//        Chart(data, id: \.category) { item in
//            SectorMark(
//                angle: .value("Count", item.count),
//                innerRadius: .ratio(0.6),
//                angularInset: 2
//            )
//            .foregroundStyle(by: .value("Category", item.category))
//        }
//        .chartBackground { chartProxy in
//          GeometryReader { geometry in
//            if let anchor = chartProxy.plotFrame {
//              let frame = geometry[anchor]
//              Text("\(currentStreak)")
//                .position(x: frame.midX, y: frame.midY)
//            }
//          }
//        }
//        .chartLegend(Visibility.hidden)
//        .scaledToFit()
//    }
    
    @ObservedObject var streakVM: StreakViewModel
    var habit: Habit

        let totalDays: Int = 365 // Totalt antal dagar (ett år)

        var result: Int {
            totalDays - streakVM.currentStreak
        }

        var data: [PostCount] {
            [
                .init(category: "Streak", count: streakVM.currentStreak),
                .init(category: "Year", count: result)
            ]
        }

        var body: some View {
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
                        Text("\(streakVM.currentStreak)")
                            .position(x: frame.midX, y: frame.midY)
                    }
                }
            }
            .chartLegend(Visibility.hidden)
            .scaledToFit()
            .onAppear {
                streakVM.getCurrentStreak(habit: habit) { success in
                    // Handle the success or failure
                    if success {
                        print("Streak data fetched successfully.")
                    } else {
                        print("Failed to fetch streak data.")
                    }
                }
            }
        }

}
