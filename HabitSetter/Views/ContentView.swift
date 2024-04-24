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
                //show loading progress view incicator
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .scaleEffect(2) 
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
