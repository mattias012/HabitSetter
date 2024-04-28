//
//  AddEditHabitView.swift
//  HabitSetter
//
//  Created by Mattias Axelsson on 2024-04-25.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct AddEditHabitView: View {
    @Environment(\.presentationMode) var presentationModeAddEdit
    @State private var name: String = ""
    @State private var description: String = ""
    @State private var selectedCategory: HabitCategory = .personal
    @State private var selectedInterval: HabitInterval = .daily
    @State private var imageLink: String = ""
    @State private var sendNotification: Bool = true
    @State private var showErrorAlert = false
    
    let db = Firestore.firestore()
    let auth = Auth.auth()
    
    var habit: Habit?
    
    //
    @EnvironmentObject var habitsVM : HabitsViewModel
    
    var body: some View {
        
        
        NavigationStack {
            Form {
                VStack {
                    Section(header: Text("Habit Details")) {
                        TextField("Habit Name", text: $name)
                        TextField("Description", text: $description)
                        Picker("Category", selection: $selectedCategory) {
                            ForEach(HabitCategory.allCases, id: \.self) { category in
                                Text(category.rawValue).tag(category)
                            }
                        }
                        Picker("Interval", selection: $selectedInterval) {
                            ForEach(HabitInterval.allCases, id: \.self) { interval in
                                Text(interval == .daily ? "Daily" : "Weekly").tag(interval)
                            }
                        }
                        
                        TextField("Image URL", text: $imageLink)
                        Toggle("Send Notification", isOn: $sendNotification)
                    }
                }
                Button("Save") {
                    habitsVM.errorMessage = nil // Rensa gamla felmeddelanden innan ett nytt försök görs
                    saveHabit()
                }
                .buttonStyle(.borderedProminent)
            }
            .navigationTitle(habit == nil ? "Add Habit" : "Edit Habit")
            .onAppear {
                loadHabitData()
            }
            .alert("Error", isPresented: $showErrorAlert) {
                Button("OK", role: .cancel) { showErrorAlert = false }
            } message: {
                Text(habitsVM.errorMessage ?? "Unknown error")
            }
        }
        .onChange(of: habitsVM.habitAddedSuccessfully) {
            presentationModeAddEdit.wrappedValue.dismiss()
            habitsVM.habitAddedSuccessfully = false
            
        }
        .onChange(of: habitsVM.errorMessage) {
            showErrorAlert = true
        }
        
    }
    
    func loadHabitData() {
        if let habit = habit {
            name = habit.name
            description = habit.description
            selectedCategory = habit.category
            selectedInterval = habit.interval
            imageLink = habit.imageLink ?? ""
            sendNotification = habit.sendNotification
        }
    }
    
    func saveHabit() {
        // Create a new instance of Habit
        let newHabit = Habit(
            name: name,
            description: description,
            category: selectedCategory,
            interval: selectedInterval,
            imageLink: imageLink,          //  default string for image.. perhaps hide it
            currentStreakID: "",           // streak id later on
            userId: auth.currentUser?.uid
            ,                    // Assuming you handle it if it's nil or empty
            sendNotification: sendNotification,
            dateCreated: Timestamp(date: Date()),  // Current date
            dateEdited: Timestamp(date: Date())    // Current date
        )
        
        
        habitsVM.add(habit: newHabit)
    }
    
}


#Preview {
    AddEditHabitView()
}
