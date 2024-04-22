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
    
    var body: some View {
        
        //add group to allow if statement of views
        Group {
            //If not signed in, show sign in view
            if !signedIn{
                SignInView(signedIn: $signedIn)
            }
            else {
                //Otherwise show the root view of the app
                HabitSetterRootView()
            }
        }
    }
}



struct HabitSetterRootView : View {
    var body: some View {
        Text("Logged in and showing habits")
    }
}

#Preview {
    ContentView(signedIn: false)
}
