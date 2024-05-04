//
//  CalenderView.swift
//  HabitSetter
//
//  Created by Mattias Axelsson on 2024-05-04.
//

import SwiftUI
import SwiftUICalendar
import Firebase
import FirebaseFirestoreSwift

extension YearMonthDay: Comparable {
    public static func < (lhs: SwiftUICalendar.YearMonthDay, rhs: SwiftUICalendar.YearMonthDay) -> Bool {
        if lhs.year != rhs.year {
                    return lhs.year < rhs.year
                } else if lhs.month != rhs.month {
                    return lhs.month < rhs.month
                } else {
                    return lhs.day < rhs.day
                }
    }
    static func == (lhs: YearMonthDay, rhs: YearMonthDay) -> Bool {
           return lhs.year == rhs.year && lhs.month == rhs.month && lhs.day == rhs.day
       }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.year)
        hasher.combine(self.month)
        hasher.combine(self.day)
    }
}

import SwiftUI
import Firebase

struct CalenderView: View {
    private var db = Firestore.firestore()
        @State var informations = [YearMonthDay: [(String, Color)]]()
        @State var habits = [String: Habit]()  // Dictionary för att spara habits med id som key.
        @ObservedObject var controller: CalendarController = CalendarController()


        
    var body: some View {
        GeometryReader { reader in
            VStack {
                Text("\(controller.yearMonth.monthShortString), \(String(controller.yearMonth.year))")
                    .font(.title)
                    .padding(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))

                CalendarView(controller, startWithMonday: true, headerSize: .fixHeight(50.0)) { week in
                    Text("\(week.shortString)")
                        .font(.headline)
                        .frame(width: reader.size.width / 7)
                } component: { date in
                    GeometryReader { geometry in
                        VStack(alignment: .leading, spacing: 2) {
                            if date.isToday {
                                Text("\(date.day)")
                                    .font(.system(size: 10, weight: .bold, design: .default))
                                    .padding(4)
                                    .foregroundColor(.white)
                                    .background(Color.red.opacity(0.95))
                                    .cornerRadius(14)
                            } else {
                                Text("\(date.day)")
                                    .font(.system(size: 10, weight: .light, design: .default))
                                    .opacity(date.isFocusYearMonth == true ? 1 : 0.4)
                                    .foregroundColor(getColor(date))
                                    .padding(4)
                            }
                            if let infos = informations[date] {
                                ForEach(infos.indices, id: \.self) { index in
                                    let info = infos[index]
                                    Text(info.0)
                                        .lineLimit(1)
                                        .foregroundColor(.white)
                                        .font(.system(size: 8, weight: .bold, design: .default))
                                        .padding(EdgeInsets(top: 2, leading: 4, bottom: 2, trailing: 4))
                                        .frame(width: geometry.size.width, alignment: .center)
                                        .background(info.1.opacity(0.75))
                                        .cornerRadius(4)
                                        .opacity(date.isFocusYearMonth == true ? 1 : 0.4)
                                }
                            }
                        }
                        .frame(width: geometry.size.width, height: geometry.size.height, alignment: .topLeading)
                    }
                }
            }
        }
        .onAppear {
            loadAllData()
        }

        
    }
    
    private func getColor(_ date: YearMonthDay) -> Color {
        if date.dayOfWeek == .sun {
            return Color.red
        } else if date.dayOfWeek == .sat {
            return Color.blue
        } else {
            return Color.black
        }
    }
    
    func loadAllData() {
        loadHabits { habits in
            self.loadStreaks(with: habits) { updatedInformations in
                self.informations = updatedInformations
            }
        }
    }

    private func loadHabits(completion: @escaping ([String: Habit]) -> Void) {
            var habitsDict = [String: Habit]()
            
            db.collection("habits").getDocuments {
                (querySnapshot, err) in
                guard let documents = querySnapshot?.documents else {
                    print("No documents in 'habits'")
                    completion([:])
                    return
                }
                for document in documents {
                    do {
                        let habit = try document.data(as: Habit.self)
                        if let id = habit.id {
                            habitsDict[id] = habit
                        }
                    } catch let error {
                        print("Error decoding habit: \(error)")
                    }
                }
                completion(habitsDict)
            }
        }

    func loadStreaks(with habits: [String: Habit], completion: @escaping ([YearMonthDay: [(String, Color)]]) -> Void) {
        guard let userId = SessionManager.shared.currentUserId else { return }
        
        db.collection("streaks").whereField("userId", isEqualTo: userId)
            .getDocuments { querySnapshot, err in
                var newInformations = [YearMonthDay: [(String, Color)]]()
                if let err = err {
                    print("Error getting documents: \(err)")
                    completion([:])
                } else if let querySnapshot = querySnapshot {
                    for document in querySnapshot.documents {
                        do {
                            let data = document.data()
                            let habitId = data["habitId"] as? String ?? ""
                            let habitColor = habits[habitId]?.habitColor ?? "#FFFFFF" // Default to white if no color found.

                            guard let firstDayOfStreak = data["firstDayOfStreak"] as? Timestamp,
                                  let lastDayPerformed = data["lastDayPerformed"] as? Timestamp,
                                  let currentStreakCount = data["currentStreakCount"] as? Int else {
                                    throw NSError(domain: "", code: 100, userInfo: [NSLocalizedDescriptionKey: "Missing data in document"])
                            }
                            
                            let startDateComponents = Calendar.current.dateComponents([.year, .month, .day], from: firstDayOfStreak.dateValue())
                            let endDateComponents = Calendar.current.dateComponents([.year, .month, .day], from: lastDayPerformed.dateValue())
                            
                            var date = YearMonthDay(year: startDateComponents.year!, month: startDateComponents.month!, day: startDateComponents.day!)
                            let end = YearMonthDay(year: endDateComponents.year!, month: endDateComponents.month!, day: endDateComponents.day!)
                            
                            while date <= end {
                                if newInformations[date] == nil {
                                    newInformations[date] = []
                                }
                                if newInformations[date]!.count < 4 {
                                    DispatchQueue.main.async {
                                        
                                        newInformations[date]?.append(("\(currentStreakCount) days", Color(hex: habitColor)))
                                    }
                                }
                                date = date.addDay(value: 1)
                            }
                        } catch let error {
                            print("Error processing document: \(error.localizedDescription)")
                        }
                    }
                    completion(newInformations)
                }
            }
    }

}
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255, opacity: Double(a) / 255)
    }
}
