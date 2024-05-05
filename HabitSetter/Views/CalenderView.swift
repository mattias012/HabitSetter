//
//  CalenderView.swift
//  HabitSetter
//
//  Created by Mattias Axelsson on 2024-05-04.
//

import SwiftUI
import SwiftUICalendar

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

struct CalenderView: View {
       
//    @State var informations = [YearMonthDay: [StreakInfo]]()
    @ObservedObject var streakVM = StreakViewModel()
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
                            if let infos = streakVM.informations[date] {
                                ForEach(infos) { info in
                                    Text(" ")
                                        .lineLimit(1)
                                        .foregroundColor(.white)
                                        .font(.system(size: 8, weight: .bold, design: .default))
                                        .padding(EdgeInsets(top: 2, leading: 4, bottom: 2, trailing: 4))
                                        .frame(width: geometry.size.width, alignment: .center)
                                        .background(info.color.opacity(0.75))
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
            streakVM.loadStreaks()
            }
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
    
//To get help with hex colors
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
