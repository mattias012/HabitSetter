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

struct SignInView : View {
    
    @Binding var signedIn : Bool //Bind the state from content view since we need to update it soon
    var auth = Auth.auth()
    
    @State private var email: String = ""
    @State private var password: String = ""
    @FocusState private var isEmailFocused: Bool
    @FocusState private var isPasswordFocused: Bool
    
    var body: some View {
        
        VStack {
            Spacer()
            
            Text("Welcome, please sign in")
                .font(.title)
                .padding(.bottom, 20)
           
            VStack(spacing: 16) {
                TextField("Email", text: $email)
                    .focused($isEmailFocused)
                    .onChange(of: isEmailFocused) { //Perhaps we add something different here later on
                        email = ""
                    }
                    .padding(.horizontal)
                    .frame(height: 50)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                
                SecureField("Password", text: $password)
                    .focused($isPasswordFocused)
                    .onChange(of: isPasswordFocused){
                        password = ""
                    }
                    .padding(.horizontal)
                    .frame(height: 50)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
            }
                .padding(.horizontal)
            
            Button(action: {
                
                auth.signIn(withEmail: email, password: password) { result, error in
                    if let error = error {
                        print("Error signing in: \(error)")
                    } else {
                        signedIn = true
                    }
                }
            }) {
                HStack {
                    Text("Sign in")
                    Image(systemName: "arrow.right")
                }
            }
            .padding()
            .frame(height: 50)
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            .padding(.top, 20)
            
            Spacer()
        }
        .padding()
        
        //        .onAppear {
        //            if Auth.auth().currentUser != nil {
        //                signedIn = true
        //            }
        //        }
        
    }
}

struct HabitSetterRootView : View {
    var body: some View {
        Text("Logged in and showing habits")
    }
}

#Preview {
    ContentView()
}
