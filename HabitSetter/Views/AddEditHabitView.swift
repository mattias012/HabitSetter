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
//    @State private var habitColorString: String = ""
    
    @State private var habitColor: Color = .blue

    
    @State private var showErrorAlert = false
    
    let db = Firestore.firestore()
    let auth = Auth.auth()
    
    @Binding var habit: Habit?
    
    //add environmentobject
    @EnvironmentObject var habitsVM : HabitsViewModel
    
    var body: some View {
        NavigationStack {
            Form {
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
                            Text("\(interval.days()) days").tag(interval)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    TextField("Image URL", text: $imageLink)
//                    TextField("Habit color", text: $habitColor)
                    ColorPicker("Habit color", selection: $habitColor, supportsOpacity: false)

                    Toggle("Send Notification", isOn: $sendNotification)
                }
                Button("Save") {
                    saveOrUpdateHabit()
                }
                .buttonStyle(.borderedProminent)
            }
            .navigationTitle(habit?.id == nil ? "Add Habit" : "Edit Habit")
            .onAppear {
                loadHabitData()
            }
            .alert("Error", isPresented: $showErrorAlert) {
                Button("OK", role: .cancel) { showErrorAlert = false }
            } message: {
                Text(habitsVM.errorMessage ?? "Unknown error")
            }
        }//When a new habit has been entered
        .onChange(of: habitsVM.habitAddedSuccessfully) {
            presentationModeAddEdit.wrappedValue.dismiss()
            
            habitsVM.habitAddedSuccessfully = false
            
        } //in case of updating a habit
        .onChange(of: habitsVM.habitUpdatedSuccessfully) {
            presentationModeAddEdit.wrappedValue.dismiss()
            
            habitsVM.habitUpdatedSuccessfully = false
            
        }
        .onChange(of: habitsVM.errorMessage) {
            showErrorAlert = true
        }
    }
    
    private func loadHabitData() {
        if let habit = habit {
            name = habit.name
            description = habit.description
            selectedCategory = habit.category
            selectedInterval = habit.interval
            imageLink = habit.imageLink ?? ""
            sendNotification = habit.sendNotification
            habitColor = Color.fromHex(habit.habitColor ?? "#0000FF")
        }
    }
    
    private func saveOrUpdateHabit() {
        //Assuming updatedHabit is created here with possibly new or updated values
        
        let hexColor = habitColor.toHex() ?? "#0000FF"
        
        let updatedHabit = Habit(
            id: habit?.id,
            name: name,
            description: description,
            category: selectedCategory,
            interval: selectedInterval,
            imageLink: imageLink,
            userId: SessionManager.shared.currentUserId,
            sendNotification: sendNotification,
            dateCreated: habit?.dateCreated ?? Timestamp(date: Date()), // Use the existing creation date if available
            dateEdited: Timestamp(date: Date()),
            habitColor: hexColor
        )

        //Check to see if the habit already has an ID (then it should be an update)
        if updatedHabit.id != nil {
            // Update an existing habit
            habitsVM.update(habit: updatedHabit)
            
            habitsVM.updateStreaks(for: updatedHabit.id, withNewColor: hexColor)
        } else {
            //otherwise letes create a new habit
            habitsVM.add(habit: updatedHabit)
        }
    }
}



//#Preview {
//    AddEditHabitView()
//}
