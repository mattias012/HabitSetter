//
//  ContentView.swift
//  HabitSetter
//
//  Created by Mattias Axelsson on 2024-04-21.
//

import SwiftUI
import Firebase

//First view, what should be displayed
struct ContentView: View {
    
    @State var signedIn = false //Remember the state, we need to keep track of it
    @State private var isLoading = false  // Lägg till denna rad
    
    
    var body: some View {
        
        //add group to allow if statement of views
        Group {
            if isLoading {
                ProgressView()  // Visa en snurrande indikator
                    .progressViewStyle(CircularProgressViewStyle())
                    .scaleEffect(2)  // Gör den större för synlighet
            } else if !signedIn {
                SignInView(signedIn: $signedIn, isLoading: $isLoading)
            } else {
                HabitsView()
            }
        }
    }
}




#Preview {
    ContentView(signedIn: false)
}
